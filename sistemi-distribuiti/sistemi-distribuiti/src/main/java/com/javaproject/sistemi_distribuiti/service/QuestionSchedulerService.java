package com.javaproject.sistemi_distribuiti.service;

import com.javaproject.sistemi_distribuiti.entity.Notification;
import com.javaproject.sistemi_distribuiti.entity.Question;
import com.javaproject.sistemi_distribuiti.entity.User;
import com.javaproject.sistemi_distribuiti.repository.NotificationRepository;
import com.javaproject.sistemi_distribuiti.repository.QuestionRepository;
import com.javaproject.sistemi_distribuiti.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class QuestionSchedulerService {

    private final QuestionRepository questionRepository;
    private final NotificationRepository notificationRepository;
    private final UserRepository userRepository;
    private final EmailService emailService;

    @Scheduled(fixedRate = 60000) // Esegui ogni 5 minuti (300000 ms)
    public void updateExpiredQuestions() {
        LocalDateTime now = LocalDateTime.now();

        // Trova tutte le domande scadute
        List<Question> expiredQuestions = questionRepository.findByStatusAndExpirationDateBefore(
                Question.QuestionStatus.WAITING_FOR_ANSWER, now
        );

        List<Notification> notifications = new ArrayList<>();

        for (Question question : expiredQuestions) {
            // Aggiorna lo stato della domanda
            question.setStatus(Question.QuestionStatus.EXPIRED_NO_ANSWER);

            // Crea una notifica per l'utente
            Notification notification = new Notification();
            notification.setUsername(question.getUser().getUsername()); // Supponendo che l'utente abbia un campo username
            notification.setMessage("La tua domanda " + question.getTitle() + " è scaduta senza ricevere risposta.");
            notification.setRead(false);
            notification.setCreatedAt(LocalDateTime.now());

            notifications.add(notification);
        }


        // Salva le modifiche alle domande
        questionRepository.saveAll(expiredQuestions);

        // Salva tutte le notifiche
        notificationRepository.saveAll(notifications);

        //va inviata un email per segnalare che le domande sono scadute
        String message2="La tua domanda non ha ricevuto risposta! Accedi al tuo profilo per riproporla!";
        //inviare l'email
        String subject = "Nuova notifica ricevuta!";
        List<Integer> userIds = expiredQuestions.stream()
                .map(q -> q.getUser().getId())
                .distinct()
                .collect(Collectors.toList());

        List<User> users = userRepository.findAllById(userIds);
        Map<Integer, User> userMap = users.stream()
                .collect(Collectors.toMap(User::getId, user -> user));

// Usa la mappa per inviare le email
        for (Question question : expiredQuestions) {
            User user = userMap.get(question.getUser().getId());
            if (user != null) {
                String email = user.getEmail();
                try {
                    emailService.sendEmail(email, subject, message2);
                } catch (Exception e) {
                    System.err.println("Errore durante l'invio dell'email a: " + email + " - " + e.getMessage());
                }
            }
        }

        System.out.println("Scheduler eseguito: Stato delle domande aggiornato e notifiche create.");
    }
}

