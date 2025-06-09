package com.javaproject.sistemi_distribuiti.repository;

import com.javaproject.sistemi_distribuiti.entity.*;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface NotificationRepository extends JpaRepository<Notification, Integer> {
    // Metodo per trovare tutte le notifiche inviate a un utente specifico
    List<Notification> findByUsername(String username);





}
