package com.javaproject.sistemi_distribuiti.service;

import com.javaproject.sistemi_distribuiti.dtos.QuestionDTO;
import com.javaproject.sistemi_distribuiti.entity.Question;
import com.javaproject.sistemi_distribuiti.repository.QuestionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
@Service
@RequiredArgsConstructor
public class QuestionService {

    private final QuestionRepository questionRepository;

    public Question createQuestion(Question question) {
        return questionRepository.save(question);
    }

    public Question getQuestionById(int id) {
        return questionRepository.findById(id).orElse(null);
    }

    public void deleteQuestion(int id) {
        questionRepository.deleteById(id);
    }

    public List<QuestionDTO> getAllQuestions() {
        return questionRepository.findAllQuestions();
    }

    public Question updateQuestion(Question question) {
        return questionRepository.save(question);
    }

    public List<QuestionDTO> getWaitingQuestion() {
        return questionRepository.findByStatusWaiting();
    }

    public List<QuestionDTO> getExpiredQuestion() {
        return questionRepository.findByStatusExpired();
    }
}

