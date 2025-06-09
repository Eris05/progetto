/* User rappresenta gli utenti che pubblicano le domande sulla piattaforma. Attributi potrebbero includere:
- ID Utente
- Nome
- Email
- Ruolo (Employee.java o user)
*/
package com.javaproject.sistemi_distribuiti.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

@Entity
@Table(name = "app_user")
@Getter
@Setter
public class User implements UserDetails {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private int id;

    // Nome dell'utente
    @Column(name = "username", nullable = false)
    @NotNull(message = "L'username non può essere nullo")
    @Size(max = 100, message = "L'username non può superare i 100 caratteri")
    private String username;


    // Email dell'utente
    @Column(name = "email", nullable = false, unique = true)
    @NotNull(message = "L'email non può essere nulla")
    @Email(message = "L'email deve essere valida")
    private String email;

    @Column(nullable = false)
    private String password;

    @NotNull
    @Enumerated(EnumType.STRING)
    @Column(name = "role", nullable = false)
    private Role role = Role.USER; //di default è settato a USER

    // Relazione con le domande: Un utente può pubblicare più domande
    @OneToMany(mappedBy = "user", cascade = CascadeType.ALL)
    private List<Question> questions= new ArrayList<>();


    @OneToMany(mappedBy = "user", fetch = FetchType.LAZY) //cascade = CascadeType.ALL)
    private List<Answer> answers=new ArrayList<>();


    public void addAnswer(Answer answer) {
        this.answers.add(answer);
        answer.setUser(this); // Imposta la relazione anche da parte di Question
    }


    // Metodo per aggiungere una domanda e gestire la relazione
    public void addQuestion(Question question) {
        this.questions.add(question);
        question.setUser(this); // Imposta la relazione anche da parte di Question
    }



    ///////////////////////
    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return List.of();
    }//da implementare




    @Override
    public boolean isAccountNonExpired() {
        return true;
    }//da implementare

    @Override
    public boolean isAccountNonLocked() {
        return true;
    }//da implementare

    @Override
    public boolean isCredentialsNonExpired() {
        return true;
    }//da implementare

    @Override
    public boolean isEnabled() {
        return true;
    }//da implementare

    public User setUsername(String username) {
        this.username = username;
        return this;
    }

    public User setEmail(String email) {
        this.email = email;
        return this;
    }

    public User setPassword(String password) {
        this.password = password;
        return this;
    }

}

