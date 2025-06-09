package com.javaproject.sistemi_distribuiti.dtos;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class CreateAnswerRequest {
    private String text;
    private int questionId;
}
