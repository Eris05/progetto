package com.javaproject.sistemi_distribuiti.entity;

import jakarta.persistence.*;
import lombok.*;
import jakarta.validation.constraints.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "question")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Question {

    public enum QuestionStatus {
        WAITING_FOR_ANSWER,
        ANSWER_PROVIDED,
        EXPIRED_NO_ANSWER
    }

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private int id;

    @NotNull
    @Size(min = 5, max = 255, message = "Il titolo deve essere tra 5 e 255 caratteri")
    @Column(name = "title")
    private String title;

    @Size(max = 3000, message = "La domanda non può superare i 3000 caratteri")
    @Column(name = "text_Q")
    private String textQ;

    @NotNull
    @Enumerated(EnumType.STRING)
    @Column(name = "subject", nullable = false)
    private Subject subject;

    @NotNull
    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false)
    private QuestionStatus status = QuestionStatus.WAITING_FOR_ANSWER;

    @Column(name = "publish_date", nullable = false)
    private LocalDateTime publishDate;

    @Column(name = "expiration_date", nullable = false)
    private LocalDateTime expirationDate;

    @ManyToOne
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @PrePersist
    public void onCreate() {
        this.publishDate = LocalDateTime.now();
        this.expirationDate = publishDate.plusMinutes(3); // Calcola la data di scadenza
    }

    // Metodo per aggiornare lo stato della domanda

}
