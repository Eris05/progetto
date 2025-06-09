package com.javaproject.sistemi_distribuiti.controller;

import com.javaproject.sistemi_distribuiti.dtos.AnswerDTO;
import com.javaproject.sistemi_distribuiti.dtos.CreateAnswerRequest;
import com.javaproject.sistemi_distribuiti.service.*;
import com.javaproject.sistemi_distribuiti.entity.*;

import jakarta.persistence.EntityNotFoundException;


import org.springframework.http.*;
import org.springframework.web.bind.annotation.*;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.net.http.HttpRequest.BodyPublishers;
import java.time.LocalDateTime;
import java.util.List;

import javax.json.Json;
import javax.json.JsonArray;
import javax.json.JsonReader;
import javax.json.JsonObject;

import java.io.StringReader;

@RestController
@RequestMapping("/api/answers")
public class AnswerController {
    private final AnswerService answerService;
    private final QuestionService questionService;
    private final UserService userService;
    private final JwtService jwtService;
    private final NotificationService notificationService;
    private final EmailService emailService;

    // Costruttore con iniezione delle dipendenze
    public AnswerController(AnswerService answerService,
                            QuestionService questionService,
                            UserService userService,
                            JwtService jwtService,
                            NotificationService notificationService,
                            EmailService emailService) {
        this.answerService = answerService;
        this.questionService = questionService;
        this.userService = userService;
        this.jwtService = jwtService;
        this.notificationService = notificationService;
        this.emailService = emailService;
    }

    private String t="Bearer ";



    // Creare una nuova risposta
    @PostMapping
    public ResponseEntity<AnswerDTO> createAnswer(
            @RequestHeader("Authorization") String authHeader,
            @RequestBody CreateAnswerRequest request) {


        try {
            // Estrai il token e verifica il ruolo
            String token = authHeader.replace(t, "");
            Role role = jwtService.extractRole(token);
            if (role != Role.EMPLOYEE) {
                return ResponseEntity.status(HttpStatus.FORBIDDEN).body(null);
            }

            // Trova il dipendente
            String usernameEmployee = jwtService.extractUsername(token);
            User employee = userService.getUserByUsername(usernameEmployee);

            // Verifica la domanda
            Question question = questionService.getQuestionById(request.getQuestionId());
            if (question == null) {
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(null);
            }

            // Crea la risposta
            Answer answer = new Answer();
            answer.setTextA(request.getText());
            answer.setQuestion(question);
            answer.setUser(employee);
            answer.setAnswerDate(LocalDateTime.now());
            Answer createdAnswer = answerService.createAnswer(answer);


            // Crea il DTO
            AnswerDTO answerDTO = AnswerDTO.builder()
                    .id(createdAnswer.getId())
                    .textA(createdAnswer.getTextA())
                    .questionId(question.getId())
                    .answerDate(createdAnswer.getAnswerDate())
                    .userId(employee.getId())
                    .build();

            String message="La tua domanda " + question.getTitle() + " ha ricevuto una risposta.";
            // Crea una notifica
            notificationService.createNotificationForQuestionAuthor(
                    question,
                    message
            );

            String message2="La tua domanda ha ricevuto risposta! Accedi al tuo profilo per visualizzarla";
            //inviare l'email
            String subject = "Nuova notifica ricevuta!";
            User user= userService.getUserById(question.getUser().getId());
            String email = user.getEmail();
            emailService.sendEmail(email, subject, message2);

            return new ResponseEntity<>(answerDTO, HttpStatus.CREATED);

        } catch (EntityNotFoundException e) {
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(null);
        } catch (IllegalArgumentException e) {
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(null);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(null);
        }
    }



    @PostMapping("/generateAI/answer")
    public ResponseEntity<AnswerDTO> generateAIAnswer(@RequestHeader("Authorization") String authHeader, @RequestParam int questionId){
        //Verifica del ruolo
        String token = authHeader.replace(t, "");
        Role role = jwtService.extractRole(token);

        if (role != Role.USER) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body(null);
        }

        //Recupera la domanda
        Question question = questionService.getQuestionById(questionId);
        if(question == null) {
            return ResponseEntity.notFound().build();
        }

        String content = question.getTextQ();
        JsonObject message=Json.createObjectBuilder()
                .add("role","user")
                .add("content",content)
                .build();
        JsonArray messages = Json.createArrayBuilder()
                .add(message)
                .build();


        //Chiamata all'API
        try{

            String apiToken = System.getenv("HUGGINGFACE_API_TOKEN");
            String apiKey = t+apiToken;
            String endpoint = "https://router.huggingface.co/together/v1/chat/completions";

            JsonObject input = Json.createObjectBuilder()
                    .add("messages",messages)
                    .add("max_tokens",500)
                    .add("model","mistralai/Mistral-7B-Instruct-v0.3")
                    .add("stream",false)
                    .build();
            String inputJson=input.toString();

            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(endpoint))
                    .header("Authorization", apiKey)
                    .header("Content-Type", "application/json")
                    .POST(BodyPublishers.ofString(inputJson))
                    .build();

            HttpClient client = HttpClient.newHttpClient();
            HttpResponse<String> response = client.send(request,HttpResponse.BodyHandlers.ofString());

            /// Parsing della risposta JSON stile chat.completion
            try (JsonReader jsonReader = Json.createReader(new StringReader(response.body()))) {
                JsonObject root = jsonReader.readObject();

                String generatedText = root
                        .getJsonArray("choices")
                        .getJsonObject(0)
                        .getJsonObject("message")
                        .getString("content");


                //creazione e salvataggio dell'oggetto Answer
                Answer answer = new Answer();
                answer.setTextA(generatedText);
                answer.setQuestion(question);
                answer.setUser(question.getUser());
                answer.setAnswerDate(LocalDateTime.now());

                Answer createdAnswer = answerService.createAnswer(answer);

                //mappa su DTO
                AnswerDTO answerDTO = AnswerDTO.builder()
                        .id(createdAnswer.getId())
                        .textA(createdAnswer.getTextA())
                        .questionId(question.getId())
                        .answerDate(createdAnswer.getAnswerDate())
                        .userId(0) // 0 perché è generata dall’AI
                        .build();


            return new ResponseEntity<>(answerDTO, HttpStatus.CREATED);
            }
        } catch (InterruptedException e) {
            // Rilancia l'eccezione dopo aver ripristinato lo stato di interruzione
            Thread.currentThread().interrupt();  // Ripristina stato di interruzione
            throw new IllegalArgumentException("Thread interrotto durante la chiamata API", e);
        } catch (Exception e) {
            // Gestisce altre eccezioni generiche
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(null);
        }
    }

    // Ottenere una risposta per ID
    @GetMapping("/{id}")
    public ResponseEntity<Answer> getAnswerById(@PathVariable int id) {
        Answer answer = answerService.getAnswerById(id);
        return new ResponseEntity<>(answer, answer != null ? HttpStatus.OK : HttpStatus.NOT_FOUND);
    }

    @GetMapping("question/{id}")
    public ResponseEntity<List<AnswerDTO>> getAnswerByQuestionId(@PathVariable int id) {
        List<AnswerDTO> answer = answerService.getAnswersByQuestionId(id);
        return new ResponseEntity<>(answer, answer != null ? HttpStatus.OK : HttpStatus.NOT_FOUND);
    }

    // Ottenere tutte le risposte
    @GetMapping
    public ResponseEntity<List<Answer>> getAllAnswers() {
        List<Answer> answers = answerService.getAllAnswers();
        return new ResponseEntity<>(answers, HttpStatus.OK);
    }

    // Eliminare una risposta
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteAnswer(
            @RequestHeader("Authorization") String authHeader,
            @PathVariable int id) {
        try {
            // Estrai il token dall'header Authorization
            String token = authHeader.replace(t, "");

            // Estrai il ruolo dal token
            Role role = jwtService.extractRole(token);

            // Verifica che il ruolo sia USER
            if (role != Role.USER) {
                return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
            }

            // Procedi con l'eliminazione della risposta
            answerService.deleteAnswer(id);
            return new ResponseEntity<>(HttpStatus.NO_CONTENT);

        } catch (Exception e) {
            // Gestione di eventuali eccezioni
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }



}
