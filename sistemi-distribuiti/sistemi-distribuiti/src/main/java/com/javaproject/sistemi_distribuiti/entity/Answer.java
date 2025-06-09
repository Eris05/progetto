package com.javaproject.sistemi_distribuiti.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import java.time.LocalDateTime;

@Entity
@Table(name="answer")
@Getter
@Setter
public class Answer {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name="id")
    private int id;

    @Column(name="answer_text", columnDefinition = "TEXT")
    private String textA;

    // Relazione con la domanda a cui la risposta è associata
    @ManyToOne
    @JoinColumn(name="question_id", nullable=false) // Foreign key per la domanda
    private Question question;

    // Relazione con l'utente (dipendente) che ha dato la risposta (ha per forza il ruolo employee perché solo gli employee hanno l'autorizzazione a creare Answer)
    @ManyToOne
    @JoinColumn(name="user_id", nullable=false) // Foreign key per l'utente
    private User user;

    @Column(name="answer_date", nullable=false)
    private LocalDateTime answerDate;

    @PrePersist
    protected void onCreate() {
        this.answerDate = LocalDateTime.now();
    }

}
