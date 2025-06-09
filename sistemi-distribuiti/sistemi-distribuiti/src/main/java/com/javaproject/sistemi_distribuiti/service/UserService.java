package com.javaproject.sistemi_distribuiti.service;
import com.javaproject.sistemi_distribuiti.dtos.QuestionDTO;
import com.javaproject.sistemi_distribuiti.dtos.UserWithAnswersDTO;
import com.javaproject.sistemi_distribuiti.dtos.UserWithQuestionsDTO;
import com.javaproject.sistemi_distribuiti.repository.*;

import com.javaproject.sistemi_distribuiti.entity.*;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;


import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class UserService implements UserDetailsService {


    private final UserRepository userRepository;



    // Creare un nuovo utente
    public User createUser(User user) {
        return userRepository.save(user);
    }

    // Ottenere tutti gli utenti
    public List<User> getAllUsers() {
        return userRepository.findAll();
    }

    // Ottenere un utente per ID
    public User getUserById(int id) {
        return userRepository.findById(id).orElse(null);
    }

    // Ottenere un utente per email
    public User getUserByEmail(String email) {
        return userRepository.findByEmail(email).orElse(null);
    }

    // Eliminare un utente
    public void deleteUser(int id) {
        userRepository.deleteById(id);
    }

    public UserService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    public List<User> allUsers() {
        List<User> users = new ArrayList<>();

        userRepository.findAll().forEach(users::add);

        return users;
    }


    ///////////////////////////////////

    // Recupera un utente con le sue domande (in formato DTO)
    public UserWithQuestionsDTO getUserWithQuestions(int userId) {
        // Recupera l'utente con le domande tramite la query con FETCH
        User user = userRepository.findByIdWithQuestions(userId);

        // Trasformiamo le domande in una lista di QuestionDTO
        List<QuestionDTO> questionDTOs = user.getQuestions().stream()
                .map(question -> new QuestionDTO(
                        question.getId(),               // ID della domanda
                        question.getSubject(),       // Dipartimento della domanda
                        question.getPublishDate(),      // Data di pubblicazione
                        question.getStatus(),           // Stato della domanda
                        question.getTextQ(),            // Testo della domanda
                        question.getTitle(),            // Titolo della domanda
                        question.getUser().getId()      // ID dell'utente che ha creato la domanda
                ))
                .collect(Collectors.toList());

        // Ritorniamo il DTO dell'utente con le domande
        return new UserWithQuestionsDTO(user.getId(), user.getUsername(), questionDTOs);
    }

    public UserWithAnswersDTO getUserWithAnswers(int userId) {//Da modificare come quello su
        // Recupera l'utente con le domande tramite la query con FETCH
        User user = userRepository.findByIdWithAnswers(userId);

        // Trasformiamo le domande in una lista di titoli o altri dettagli
        List<String> answerTexts = user.getAnswers().stream()
                .map(answer -> answer.getTextA()) // Corretto: usa il nome del metodo dell'entità Answer
                .collect(Collectors.toList());


        // Ritorniamo il DTO
        return new UserWithAnswersDTO(user.getId(), user.getUsername(), answerTexts);
    }






    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {

        User user = userRepository.findByUsername(username);
        if (user == null) {
            throw new UsernameNotFoundException("User not found with username: " + username);
        }

        return user;
    }


    public User getUserByUsername(String usernameEmployee) {
        return userRepository.findByUsername(usernameEmployee);
    }
}
