package com.javaproject.sistemi_distribuiti.mappers;

import com.javaproject.sistemi_distribuiti.dtos.AnswerDTO;
import com.javaproject.sistemi_distribuiti.entity.Answer;

public class AnswerMapper {

    private AnswerMapper(){}
    public static AnswerDTO toDTO(Answer answer) {
        return AnswerDTO.builder()
                .id(answer.getId())
                .textA(answer.getTextA())
                .questionId(answer.getQuestion().getId()) // Ottieni l'ID della domanda
                .answerDate(answer.getAnswerDate())
                .userId(answer.getUser().getId()) // Ottieni l'ID dell'utente
                .build();
    }
}
