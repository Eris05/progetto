package com.javaproject.sistemi_distribuiti.controller;
import com.javaproject.sistemi_distribuiti.dtos.UserDTO;
import com.javaproject.sistemi_distribuiti.dtos.UserWithAnswersDTO;
import com.javaproject.sistemi_distribuiti.dtos.UserWithQuestionsDTO;
import com.javaproject.sistemi_distribuiti.service.*;
import com.javaproject.sistemi_distribuiti.entity.*;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/app_users")
public class UserController {


    private final UserService userService;

    private final JwtService jwtService;

    public UserController(UserService userService, JwtService jwtService) {
        this.userService = userService;
        this.jwtService = jwtService;
    }

    @PostMapping
    public ResponseEntity<User> createUser(@RequestBody User user) {
        User createdUser = userService.createUser(user);
        return new ResponseEntity<>(createdUser, HttpStatus.CREATED);
    }

    @GetMapping("/{id}")
    public ResponseEntity<User> getUserById(@PathVariable int id) {
        User user = userService.getUserById(id);
        return new ResponseEntity<>(user, user != null ? HttpStatus.OK : HttpStatus.NOT_FOUND);
    }

    @GetMapping
    public ResponseEntity<List<User>> getAllUsers() {
        List<User> users = userService.getAllUsers();
        return new ResponseEntity<>(users, HttpStatus.OK);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteUser(@PathVariable int id) {
        userService.deleteUser(id);
        return new ResponseEntity<>(HttpStatus.NO_CONTENT);
    }



    @GetMapping("/me")
    public ResponseEntity<User> authenticatedUser() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();

        User currentUser = (User) authentication.getPrincipal();

        return ResponseEntity.ok(currentUser);
    }

    @GetMapping("/")
    public ResponseEntity<List<User>> allUsers() {
        List <User> users = userService.allUsers();

        return ResponseEntity.ok(users);
    }

    //////////////////////////////////
    @GetMapping("/questions")
    @Transactional
    public ResponseEntity<UserWithQuestionsDTO> getAuthenticatedUserQuestions(@RequestHeader("Authorization") String authHeader) {
        try {


            // Estrai il token dall'header Authorization
            String token = authHeader.replace("Bearer ", "");


            // Estrai il ruolo dal token
            Role role = jwtService.extractRole(token);


            // Verifica che il ruolo sia USER
            if (role != Role.USER) {

                return ResponseEntity.status(HttpStatus.FORBIDDEN).body(null);
            }

            Authentication authentication = SecurityContextHolder.getContext().getAuthentication();


            User currentUser = (User) authentication.getPrincipal();


            // Recupera il DTO con le domande dell'utente
            UserWithQuestionsDTO userWithQuestions = userService.getUserWithQuestions(currentUser.getId());
            return ResponseEntity.ok(userWithQuestions);

        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(null);
        }
    }


//restituisce le risposte alle domande di quell'utente
    @GetMapping("/answers")
    @Transactional
    public ResponseEntity<UserWithAnswersDTO> getAuthenticatedUserAnswers(@RequestHeader("Authorization") String authHeader) {
        //Estrai il token dall'header Authorization
        String token=authHeader.replace("Bearer ","");

        //Estrai il ruolo del token
        Role role=jwtService.extractRole(token);

        //Verifica che il ruolo sia USER
        if(role!=Role.EMPLOYEE){
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                    .body(null);
        }

        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        User currentUser = (User) authentication.getPrincipal();

        // Recupera il DTO con le domande dell'utente
        UserWithAnswersDTO userWithAnswers = userService.getUserWithAnswers(currentUser.getId());

        return ResponseEntity.ok(userWithAnswers);
    }

    @GetMapping("/emoloyee/{id}")
    public ResponseEntity<UserDTO> getEmployeeById(@PathVariable int id) {
        User employee = userService.getUserById(id);

        // Verifica se l'utente è un dipendente
        if (employee == null || employee.getRole() != Role.EMPLOYEE) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(null);
        }

        // Mappa l'entità User in UserDTO
        UserDTO employeeDTO = new UserDTO(
                employee.getId(),
                employee.getUsername(),
                employee.getEmail(),
                employee.getRole().name()
        );

        return ResponseEntity.ok(employeeDTO);
    }
}
