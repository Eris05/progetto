package com.javaproject.sistemi_distribuiti.service;
import com.javaproject.sistemi_distribuiti.entity.PasswordResetToken;
import com.javaproject.sistemi_distribuiti.entity.User;
import com.javaproject.sistemi_distribuiti.repository.PasswordResetTokenRepository;
import com.javaproject.sistemi_distribuiti.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;

import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.time.LocalDateTime;
import java.util.Optional;
import java.util.UUID;

@Service
public class PasswordResetService {

    private final PasswordResetTokenRepository tokenRepository;
    private final UserRepository userRepository;
    private final EmailService emailService;
    private final BCryptPasswordEncoder passwordEncoder;

    @Autowired
    public PasswordResetService(PasswordResetTokenRepository tokenRepository,
                                UserRepository userRepository,
                                EmailService emailService,
                                BCryptPasswordEncoder passwordEncoder) { //  Aggiunto
        this.tokenRepository = tokenRepository;
        this.userRepository = userRepository;
        this.emailService = emailService;
        this.passwordEncoder = passwordEncoder; //  Assegna l'encoder
    }

    /**  Genera il token di reset della password **/
    public String generateResetToken(String email) {
        // Verifica se l'email esiste
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new IllegalArgumentException("Utente con questa email non trovato."));

        // Genera il token
        String token = UUID.randomUUID().toString();
        // Calcola la data di scadenza (ad esempio 1 ora dal momento attuale)
        LocalDateTime expiryDate = LocalDateTime.now().plusHours(1);

        // Salva il token nel database
        PasswordResetToken resetToken = new PasswordResetToken(token, user, expiryDate);
        tokenRepository.save(resetToken);

        // Restituisci il token per debug
        return token;
    }


    /** 2️. Reimposta la password usando il token **/
    @Transactional
    public void resetPassword(String token, String newPassword) {
        Optional<PasswordResetToken> tokenOptional = tokenRepository.findByToken(token);
        if (tokenOptional.isEmpty()) {
            throw new RuntimeException("Token non valido o scaduto");
        }

        PasswordResetToken resetToken = tokenOptional.get();

        if (resetToken.isExpired()) {
            throw new RuntimeException("Il token è scaduto");
        }

        User user = resetToken.getUser();

        String encodedPassword = passwordEncoder.encode(newPassword);
        user.setPassword(encodedPassword);

        userRepository.save(user);

        tokenRepository.delete(resetToken);


        // Invio dell'email
        String subject = "Password resettata correttamente";
        String message = "La tua password è stata resettata correttamente. Effettua il login. Se non hai richiesto questo reset, contatta il supporto.";
        emailService.sendEmail(user.getEmail(), subject, message);

    }

}
