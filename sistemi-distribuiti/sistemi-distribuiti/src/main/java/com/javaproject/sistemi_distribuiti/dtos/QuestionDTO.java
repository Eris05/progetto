package com.javaproject.sistemi_distribuiti.dtos;

import com.javaproject.sistemi_distribuiti.entity.Subject;
import com.javaproject.sistemi_distribuiti.entity.Question;
import lombok.*;

import java.time.LocalDateTime;

@Data
@Getter
@Setter
@Builder
public class QuestionDTO {
    private int id;
    private Subject subject;
    private LocalDateTime publishDate;
    private Question.QuestionStatus status;
    private String textQ;
    private String title;
    private Integer user; // Nome utente che ha creato la domanda

    public QuestionDTO(int id, Subject subject, LocalDateTime publishDate, Question.QuestionStatus status, String textQ, String title, Integer user) {
        this.id = id;
        this.subject = subject;
        this.publishDate = publishDate;
        this.status = status;
        this.textQ = textQ;
        this.title = title;
        this.user = user;
    }

    public QuestionDTO() {} // Costruttore vuoto richiesto da Hibernate

}
