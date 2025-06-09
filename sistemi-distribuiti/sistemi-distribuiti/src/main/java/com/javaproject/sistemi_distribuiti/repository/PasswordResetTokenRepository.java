package com.javaproject.sistemi_distribuiti.repository;

import com.javaproject.sistemi_distribuiti.entity.PasswordResetToken;
import com.javaproject.sistemi_distribuiti.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface PasswordResetTokenRepository extends JpaRepository<PasswordResetToken, Long> {
    Optional<PasswordResetToken> findByToken(String token);
    void deleteByUser(User user);
}