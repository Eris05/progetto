package com.javaproject.sistemi_distribuiti.controller;
import com.javaproject.sistemi_distribuiti.service.PasswordResetService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/password-reset")
public class PasswordResetController {

    private final PasswordResetService passwordResetService;

    public PasswordResetController(PasswordResetService passwordResetService) {
        this.passwordResetService = passwordResetService;
    }

    @PostMapping("/request")
    public ResponseEntity<String> requestReset(@RequestBody Map<String, String> requestBody) {
        try {
            String email = requestBody.get("email");
            if (email == null || email.isEmpty()) {
                throw new IllegalArgumentException("L'email non può essere vuota.");
            }

            // Genera il token di reset
            String token = passwordResetService.generateResetToken(email);

            // Restituisci il token come risposta (solo per test; normalmente non si fa in produzione)
            return ResponseEntity.ok("Token: " + token);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body("Errore: " + e.getMessage());
        } catch (Exception e) {
            return ResponseEntity.status(500).body("Errore interno del server.");
        }
    }



    /** 2️. Endpoint per confermare il reset della password **/
    @PostMapping("/reset")
    public ResponseEntity<String> resetPassword(@RequestHeader("Token") String token, @RequestBody Map<String, String> requestBody) {
        try {
            String newPassword= requestBody.get("newPassword");
            passwordResetService.resetPassword(token, newPassword);
            return ResponseEntity.ok("Password aggiornata con successo.");
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body("Errore: " + e.getMessage());
        } catch (Exception e) {
            return ResponseEntity.status(500).body("Errore interno del server.");
        }
    }
}
