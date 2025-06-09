package com.javaproject.sistemi_distribuiti.repository;

import com.javaproject.sistemi_distribuiti.dtos.QuestionDTO;
import com.javaproject.sistemi_distribuiti.entity.*;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface QuestionRepository extends JpaRepository<Question, Integer> {

    // Query personalizzata per ottenere tutte le domande come DTO
    @Query("SELECT new com.javaproject.sistemi_distribuiti.dtos.QuestionDTO(" +
            "q.id,q.subject, q.publishDate, q.status,  q.textQ, q.title, u.id) " +
            "FROM Question q LEFT JOIN q.user u")
    List<QuestionDTO> findAllQuestionsWithUserDetails();
    @Query("SELECT new com.javaproject.sistemi_distribuiti.dtos.QuestionDTO(" +
            "q.id, q.subject, q.publishDate, q.status, q.textQ, q.title, null) " +
            "FROM Question q")
    List<QuestionDTO> findAllQuestions();

    @Query("SELECT new com.javaproject.sistemi_distribuiti.dtos.QuestionDTO(" +
            "q.id, q.subject, q.publishDate, q.status, q.textQ, q.title, q.user.id) " +
            "FROM Question q WHERE q.status = 'WAITING_FOR_ANSWER'")
    List<QuestionDTO> findByStatusWaiting();

    List<Question> findByStatusAndExpirationDateBefore(Question.QuestionStatus questionStatus, LocalDateTime now);
@Query("SELECT new com.javaproject.sistemi_distribuiti.dtos.QuestionDTO("+
        "q.id, q.subject, q.publishDate, q.status, q.textQ, q.title, null)" +
        "FROM Question q WHERE q.status = 'EXPIRED_NO_ANSWER'")
    List<QuestionDTO> findByStatusExpired();
}
