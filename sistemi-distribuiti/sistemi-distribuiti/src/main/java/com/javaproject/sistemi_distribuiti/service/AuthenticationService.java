package com.javaproject.sistemi_distribuiti.service;


import com.javaproject.sistemi_distribuiti.dtos.LoginUserDto;
import com.javaproject.sistemi_distribuiti.dtos.RegisterUserDto;
import com.javaproject.sistemi_distribuiti.entity.User;

import com.javaproject.sistemi_distribuiti.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.net.InetAddress;

@Service
public class AuthenticationService {
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final AuthenticationManager authenticationManager;

    @Autowired
    public AuthenticationService(
            UserRepository userRepository,
            AuthenticationManager authenticationManager,
            PasswordEncoder passwordEncoder
    ) {
        this.authenticationManager = authenticationManager;
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
    }

    public User signup(RegisterUserDto input) {
        // Verifica se l'utente con la stessa email esiste già
        if (userRepository.existsByEmail(input.getEmail())) {
            throw new IllegalArgumentException("Email già in uso");
        }

        // Verifica il formato dell'email
        if (!isValidEmailFormat(input.getEmail())) {
            throw new IllegalArgumentException("Formato email non valido");
        }

        // Verifica che il dominio dell'email esista
        String domain = input.getEmail().substring(input.getEmail().indexOf("@") + 1);
        if (!isDomainValid(domain)) {
            throw new IllegalArgumentException("Dominio email non valido");
        }

        // Crea un nuovo utente e setta i valori
        User user = new User()
                .setUsername(input.getUsername())
                .setEmail(input.getEmail())
                .setPassword(passwordEncoder.encode(input.getPassword()));  // Codifica la password

        // Salva e restituisci l'utente
        return userRepository.save(user);
    }

    // Funzione per validare il formato dell'email
    private boolean isValidEmailFormat(String email) {
        String emailRegex = "^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$";
        return email.matches(emailRegex);
    }

    // Funzione per verificare la validità del dominio
    @SuppressWarnings("UnusedResult")
    private boolean isDomainValid(String domain) {
        try {
            InetAddress.getByName(domain); // Risolve il dominio
            return true;
        } catch (Exception e) {
            return false; // Il dominio non esiste
        }
    }



    public User authenticate(LoginUserDto input) {
        // Autenticazione tramite email e password
        authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(
                        input.getEmail(),
                        input.getPassword()
                )
        );

        // Restituisce l'utente trovato con la sua email
        return userRepository.findByEmail(input.getEmail())
                .orElseThrow(() -> new IllegalArgumentException("Utente non trovato"));
    }
}
