package com.javaproject.sistemi_distribuiti.controller;

import com.javaproject.sistemi_distribuiti.entity.*;
import com.javaproject.sistemi_distribuiti.service.*;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/notifications")
public class NotificationController {

    private final NotificationService notificationService;
    public NotificationController(NotificationService notificationService) {
        this.notificationService = notificationService;
    }

    // Metodo POST per creare una notifica
    @PostMapping
    public ResponseEntity<Notification> createNotification(@RequestBody Notification notification) {
        Notification createdNotification = notificationService.createNotification(notification);

        return new ResponseEntity<>(createdNotification, HttpStatus.CREATED);
    }

    // Metodo GET per recuperare notifiche non lette
    @GetMapping("/unread")
    public ResponseEntity<List<Notification>> getUnreadNotifications(@RequestParam("username") String  username) {
        List<Notification> unreadNotifications = notificationService.getNotificationsByUsername(username)
                .stream()
                .filter(notification -> !notification.isRead())
                .toList();

        return new ResponseEntity<>(unreadNotifications, HttpStatus.OK);
    }

    // Metodo PUT per marcare una notifica come letta e rimuoverla
    @PutMapping("/{id}/read")
    public ResponseEntity<Void> markNotificationAsReadAndDelete(@PathVariable int id) {
        Notification notification = notificationService.getNotificationById(id);

        if (notification == null) {
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        }

        try {
            // Marca la notifica come letta
            notification.setRead(true);
            notificationService.createNotification(notification); // Salva lo stato aggiornato

            // Elimina la notifica
            notificationService.deleteNotificationById(id);
            return new ResponseEntity<>(HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

}
