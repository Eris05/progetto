package com.javaproject.sistemi_distribuiti.service;

import com.javaproject.sistemi_distribuiti.dtos.AnswerDTO;
import com.javaproject.sistemi_distribuiti.mappers.AnswerMapper;
import com.javaproject.sistemi_distribuiti.repository.*;
import com.javaproject.sistemi_distribuiti.entity.*;
import jakarta.persistence.EntityNotFoundException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class AnswerService {


    private final AnswerRepository answerRepository;
    private final UserRepository userRepository;
    private final QuestionRepository questionRepository;


    @Autowired
    public AnswerService(AnswerRepository answerRepository, UserRepository userRepository, QuestionRepository questionRepository) {
        this.answerRepository = answerRepository;
        this.userRepository = userRepository;
        this.questionRepository = questionRepository;
    }
    // Creare una nuova risposta
    public Answer createAnswer(Answer answer) { // Trova l'utente tramite l'ID (controllando che sia un dipendente)

        User employee= answer.getUser();

        // Aggiungi la risposta all'utente (solo dipendenti)
        employee.addAnswer(answer); // Aggiungi la risposta all'utente
        userRepository.save(employee); // Salva l'utente che include anche la risposta

        // Aggiungi lo stato "ANSWER_PROVIDED" alla domanda
        Question question = questionRepository.findById(answer.getQuestion().getId())
                .orElseThrow(() -> new RuntimeException("Question not found"));
        question.setStatus(Question.QuestionStatus.ANSWER_PROVIDED);
        questionRepository.save(question);

        // Salva la risposta
        answerRepository.save(answer);

        // (Eventuale logica per inviare una notifica qui)

        return answer;
    }

    // Ottenere tutte le risposte
    public List<Answer> getAllAnswers() {
        return answerRepository.findAll();
    }

    // Ottenere una risposta per ID
    public Answer getAnswerById(int id) {
        return answerRepository.findById(id).orElse(null);
    }

    // Ottenere risposte per una domanda specifica
    public List<AnswerDTO> getAnswersByQuestionId(int questionId) {
        List<Answer> answers = answerRepository.findByQuestionId(questionId);
        return answers.stream()
                .map(AnswerMapper::toDTO) // Usa il mapper per convertire
                .toList();
    }

    // Ottenere risposte per un dipendente specifico (in base all'ID utente e ruolo)
    public List<Answer> getAnswersByEmployeeId(int userId) {
        return answerRepository.findByUser_IdAndUser_Role(userId, "EMPLOYEE");
    }

    // Eliminare una risposta
    public void deleteAnswer(int id) {
        // Recupera la risposta dal repository
        Answer answer = answerRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Answer not found with id: " + id));

        // Recupera la domanda associata alla risposta
        Question question = answer.getQuestion();


        // Imposta lo stato della domanda a WAITING_FOR_ANSWER
        question.setStatus(Question.QuestionStatus.WAITING_FOR_ANSWER);

        // Salva l'aggiornamento della domanda nel repository
        questionRepository.save(question);

        // Elimina la risposta
        answerRepository.deleteById(id);
    }

}
