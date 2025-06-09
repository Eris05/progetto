package com.javaproject.sistemi_distribuiti.dtos;

import java.util.List;

public class UserWithAnswersDTO {
    private int userId;
    private String username;
    private List<String> answers;

    public UserWithAnswersDTO(int userId,String username,List<String> answers){
        this.userId=userId;
        this.username=username;
        this.answers=answers;
    }

    public int getUserId(){return userId;}
    public void setUserId(int userId){this.userId=userId;}

    public String getUsername(){return username;}
    public void setUsername(String username){this.username=username;}

    public List<String> getAnswers(){return answers;}
    public void setAnswers(List<String> answers){this.answers=answers;}


}
