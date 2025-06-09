package com.javaproject.sistemi_distribuiti.dtos;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AnswerDTO {
    private int id;
    private String textA;
    private int questionId;
    private LocalDateTime answerDate;
    private int userId;
}
