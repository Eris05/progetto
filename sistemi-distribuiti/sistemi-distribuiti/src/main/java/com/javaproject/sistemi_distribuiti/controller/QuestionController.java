package com.javaproject.sistemi_distribuiti.controller;
import com.javaproject.sistemi_distribuiti.dtos.QuestionDTO;
import com.javaproject.sistemi_distribuiti.service.*;
import com.javaproject.sistemi_distribuiti.entity.*;

import jakarta.persistence.EntityNotFoundException;

import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/questions")
@RequiredArgsConstructor
public class QuestionController {

    private final QuestionService questionService;
    private final JwtService jwtService;
    private String t="Bearer ";

    @PostMapping
    public ResponseEntity<QuestionDTO> createQuestion(
            @RequestHeader("Authorization") String authHeader, // Recupera il token JWT dall'header Authorization
            @RequestBody Question question) {

        // Estrai il token dall'header Authorization
        String token = authHeader.replace(t, "");

        // Estrai il ruolo dal token
        Role role = jwtService.extractRole(token);

        // Verifica che il ruolo sia USER
        if (role != Role.USER) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                    .body(null); // O un messaggio personalizzato
        }

        // Recupera l'utente autenticato dal contesto di sicurezza
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        User authenticatedUser = (User) authentication.getPrincipal();

        // Associa la domanda all'utente autenticato
        question.setUser(authenticatedUser);

        // Crea la domanda
        Question createdQuestion = questionService.createQuestion(question);

        // Mappa l'entità Question a un DTO
        QuestionDTO questionDTO = QuestionDTO.builder()
                .id(createdQuestion.getId())
                .title(createdQuestion.getTitle())
                .textQ(createdQuestion.getTextQ())
                .subject(createdQuestion.getSubject())
                .status(createdQuestion.getStatus())
                .publishDate(createdQuestion.getPublishDate())
                .user(createdQuestion.getUser().getId())
                .build();

        return new ResponseEntity<>(questionDTO, HttpStatus.CREATED);
    }



    @GetMapping("/{id}")
    public ResponseEntity<QuestionDTO> getQuestionById(@PathVariable int id) {
        Question question = questionService.getQuestionById(id);

        if (question == null) {
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        }

        // Convert Question to QuestionDTO
        QuestionDTO questionDTO = new QuestionDTO();
        questionDTO.setId(question.getId());
        questionDTO.setSubject(question.getSubject());
        questionDTO.setPublishDate(question.getPublishDate());
        questionDTO.setStatus(question.getStatus());
        questionDTO.setTextQ(question.getTextQ());
        questionDTO.setTitle(question.getTitle());

        // Extract and set user ID
        if (question.getUser() != null) {
            questionDTO.setUser(question.getUser().getId()); // Set only the user ID
        }

        return new ResponseEntity<>(questionDTO, HttpStatus.OK);
    }



    @GetMapping("/all")
    public ResponseEntity<List<QuestionDTO>> getAllQuestions() { //mi ritorna user null, controlla bene il

        List<QuestionDTO> questions = questionService.getAllQuestions();
        return ResponseEntity.ok(questions);
    }

    @GetMapping("/waiting")
    public ResponseEntity<List<QuestionDTO>> getWaitingQuestions(){//mi ritorna le domande a cui non è ancora stata data risposta

        List<QuestionDTO> questions = questionService.getWaitingQuestion();
        return ResponseEntity.ok(questions);
    }

    //restituire le domande scadute
    @GetMapping("/expired")
    public ResponseEntity<List<QuestionDTO>> getExpiredQuestions(){

        List<QuestionDTO> questions = questionService.getExpiredQuestion();
        return ResponseEntity.ok(questions);
    }

    @DeleteMapping("/{id}") // La domanda viene eliminata solo se è scaduta
    public ResponseEntity<String> deleteQuestion(@RequestHeader("Authorization") String authHeader, @PathVariable int id) {
        try {
            // Estrai il token dall'header Authorization
            String token = authHeader.replace(t, "");

            // Estrai il ruolo dal token
            Role role = jwtService.extractRole(token);

            // Verifica che il ruolo sia USER
            if (role != Role.USER) {
                return ResponseEntity.status(HttpStatus.FORBIDDEN)
                        .body("Accesso negato: solo gli utenti con ruolo USER possono eliminare domande.");
            }

            // Recupera la domanda
            Question question = questionService.getQuestionById(id);

            // Controlla che la domanda sia nello stato "EXPIRED_NO_ANSWER"
            if (question.getStatus() != Question.QuestionStatus.EXPIRED_NO_ANSWER) {
                return ResponseEntity.status(HttpStatus.FORBIDDEN)
                        .body("Accesso negato: solo le domande scadute possono essere eliminate.");
            }

            // Elimina la domanda
            questionService.deleteQuestion(id);

            // Restituisci una risposta vuota con stato 204 (No Content)
            return ResponseEntity.noContent().build();

        } catch (EntityNotFoundException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body("Errore: domanda non trovata.");
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body("Errore di validazione: " + e.getMessage());
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Errore interno del server: " + e.getMessage());
        }
    }


    ////////////////////////////////////////////////
    @PutMapping("/{id}")
    public ResponseEntity<?> updateQuestion(
            @RequestHeader("Authorization") String authHeader,
            @PathVariable int id,
            @RequestBody Map<String, String> updatedData) {

        try {
            // Estrai il token dall'header Authorization
            String token = authHeader.replace(t, "");

            // Estrai il ruolo dal token
            Role role = jwtService.extractRole(token);

            // Verifica che il ruolo sia USER
            if (role != Role.USER) {
                return ResponseEntity.status(HttpStatus.FORBIDDEN)
                        .body("Accesso negato: solo gli utenti con ruolo USER possono modificare domande.");
            }

            // Recupera l'utente autenticato dal contesto di sicurezza
            Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
            User authenticatedUser = (User) authentication.getPrincipal();

            // Recupera la domanda esistente
            Question existingQuestion = questionService.getQuestionById(id);
            if (existingQuestion == null) {
                return ResponseEntity.status(HttpStatus.NOT_FOUND)
                        .body("Domanda non trovata.");
            }

            // Verifica che l'utente autenticato sia il proprietario della domanda
            if (existingQuestion.getUser().getId() != authenticatedUser.getId()) {
                return ResponseEntity.status(HttpStatus.FORBIDDEN)
                        .body("Non sei autorizzato a modificare questa domanda.");
            }

            // Aggiorna i campi della domanda
            String newTitle = updatedData.get("title");
            String newTextQ = updatedData.get("textQ");
            String newSubject = updatedData.get("subject");

            if (newTitle == null || newTextQ == null || newSubject == null) {
                return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                        .body("Dati mancanti: titolo, testo o argomento non forniti.");
            }

            existingQuestion.setTitle(newTitle);
            existingQuestion.setTextQ(newTextQ);
            existingQuestion.setSubject(Subject.valueOf(newSubject)); // Assumendo che 'Subject' sia un enum

            // Aggiorna la data di pubblicazione e scadenza
            existingQuestion.onCreate();

            // Salva la domanda aggiornata
            Question savedQuestion = questionService.updateQuestion(existingQuestion);

            // Mappa l'entità aggiornata a un DTO
            QuestionDTO questionDTO = QuestionDTO.builder()
                    .id(savedQuestion.getId())
                    .title(savedQuestion.getTitle())
                    .textQ(savedQuestion.getTextQ())
                    .subject(savedQuestion.getSubject())
                    .status(savedQuestion.getStatus())
                    .publishDate(savedQuestion.getPublishDate())
                    .user(savedQuestion.getUser().getId())
                    .build();

            return ResponseEntity.ok(questionDTO);

        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body("Errore di validazione: " + e.getMessage());
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Errore durante l'aggiornamento della domanda: " + e.getMessage());
        }
    }



    @PutMapping("/expired/{id}")
    public ResponseEntity<QuestionDTO> updateExpiredQuestion(@RequestHeader("Authorization") String authHeader, // Recupera il token JWT dall'header Authorization
                                                             @PathVariable int id) {
        String token = authHeader.replace(t, "");
        Role role = jwtService.extractRole(token);
        if (role != Role.USER) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                    .body(null); // O un messaggio personalizzato
        }
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        User authenticatedUser = (User) authentication.getPrincipal();
        Question existingQuestion = questionService.getQuestionById(id);
        // Verifica che l'utente autenticato sia il proprietario della domanda
        if (existingQuestion.getUser().getId() != authenticatedUser.getId()) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                    .body(null); // L'utente non è autorizzato a modificare questa domanda
        }

        // Verifica che lo stato della domanda sia EXPIRED_NO_ANSWER
        if (!existingQuestion.getStatus().equals(Question.QuestionStatus.EXPIRED_NO_ANSWER)) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                    .body(null); // La domanda non può essere modificata
        }
        // Aggiorna i campi della domanda
        existingQuestion.setStatus(Question.QuestionStatus.WAITING_FOR_ANSWER);
        existingQuestion.onCreate();
        Question savedQuestion = questionService.updateQuestion(existingQuestion);
        // Mappa l'entità aggiornata a un DTO
        QuestionDTO questionDTO = QuestionDTO.builder()
                .id(savedQuestion.getId())
                .title(savedQuestion.getTitle())
                .textQ(savedQuestion.getTextQ())
                .subject(savedQuestion.getSubject())
                .status(savedQuestion.getStatus())
                .publishDate(savedQuestion.getPublishDate())
                .user(savedQuestion.getUser().getId())
                .build();

        return new ResponseEntity<>(questionDTO, HttpStatus.OK);
    }


}

