package com.javaproject.sistemi_distribuiti.dtos;

import java.util.List;

public class UserWithQuestionsDTO {
    private int userId;
    private String username;
    private List<QuestionDTO> questions;//modificare questo in una list di QuestionTO

    // Constructor
    public UserWithQuestionsDTO(int userId, String username, List<QuestionDTO> questions) {
        this.userId = userId;
        this.username = username;
        this.questions = questions;
    }

    // Getters e Setters
    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public List<QuestionDTO> getQuestions() {
        return questions;
    }

    public void setQuestions(List<QuestionDTO> questions) {
        this.questions = questions;
    }
}
