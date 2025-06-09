package com.javaproject.sistemi_distribuiti.repository;

import com.javaproject.sistemi_distribuiti.entity.*;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository

public interface UserRepository extends JpaRepository<User, Integer> {
    // Metodo per trovare un utente per email
    Optional<User> findByEmail(String email);


    boolean existsByEmail(String email);

    User findByUsername(String username);

    @Query("SELECT u FROM User u LEFT JOIN FETCH u.questions WHERE u.id = :userId")
    User findByIdWithQuestions(int userId);

    @Query("SELECT u FROM User u LEFT JOIN FETCH u.answers WHERE u.id = :userId")
    User findByIdWithAnswers(@Param("userId") int userId);
}
