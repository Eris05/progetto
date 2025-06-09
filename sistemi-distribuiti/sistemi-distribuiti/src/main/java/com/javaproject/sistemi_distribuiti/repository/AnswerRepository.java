package com.javaproject.sistemi_distribuiti.repository;

import com.javaproject.sistemi_distribuiti.entity.Answer;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface AnswerRepository extends JpaRepository<Answer, Integer> {



    // Metodo per ottenere tutte le risposte fornite da un determinato utente (dipendente)
    // Nota: l'utente deve avere il ruolo 'EMPLOYEE'
    List<Answer> findByUser_IdAndUser_Role(int userId, String role);

    List<Answer> findByQuestionId(int questionId);
}
