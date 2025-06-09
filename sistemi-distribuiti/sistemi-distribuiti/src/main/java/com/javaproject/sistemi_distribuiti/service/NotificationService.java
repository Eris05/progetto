package com.javaproject.sistemi_distribuiti.service;

import com.javaproject.sistemi_distribuiti.entity.*;
import com.javaproject.sistemi_distribuiti.repository.*;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class NotificationService {


    private final NotificationRepository notificationRepository;


    private final UserRepository userRepository;

    @Autowired
    public NotificationService(NotificationRepository notificationRepository, UserRepository userRepository) {
        this.notificationRepository = notificationRepository;
        this.userRepository = userRepository;
    }

    // Creare una nuova notifica
    public Notification createNotification(Notification notification) {
        // Trova l'utente tramite l'ID
        User user = userRepository.findByUsername(notification.getUsername());

        // Aggiungi la notifica alla lista delle notifiche dell'utente
        notification.setUsername(user.getUsername());
        // Salva la notifica nel repository
        Notification savedNotification = notificationRepository.save(notification);

        // Salva anche l'utente per aggiornare la relazione bidirezionale
        userRepository.save(user);

        return savedNotification;
    }

    // Ottenere tutte le notifiche
    public List<Notification> getAllNotifications() {
        return notificationRepository.findAll();
    }

    // Ottenere una notifica per ID
    public Notification getNotificationById(int id) {
        return notificationRepository.findById(id).orElse(null);
    }

    // Ottenere notifiche per un utente specifico
    public List<Notification> getNotificationsByUsername(String username) {
        return notificationRepository.findByUsername(username);
    }

    // Ottenere notifiche per una domanda specifica


    // Eliminare una notifica
    public void deleteNotification(int id) {
        notificationRepository.deleteById(id);
    }

    public void createNotificationForQuestionAuthor(Question question, String message) {
        // Controlla che la domanda non sia null e abbia un autore valido
        if (question == null || question.getUser() == null) {
            throw new IllegalArgumentException("La domanda o il suo autore non possono essere null");
        }

        // Crea una nuova notifica
        Notification notification = new Notification();
        notification.setUsername(question.getUser().getUsername()); // L'utente che ha posto la domanda
        notification.setMessage(message);
        notification.setRead(false); // Imposta come non letta
        notification.setCreatedAt(LocalDateTime.now());



        // Salva la notifica
        notificationRepository.save(notification);
    }

    // Elimina notifica per ID
    public void deleteNotificationById(int id) {
        notificationRepository.deleteById(id);
    }
}
