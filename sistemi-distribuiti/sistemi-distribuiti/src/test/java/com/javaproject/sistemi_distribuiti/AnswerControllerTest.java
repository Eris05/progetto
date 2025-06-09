package com.javaproject.sistemi_distribuiti;

import com.javaproject.sistemi_distribuiti.controller.AnswerController;
import com.javaproject.sistemi_distribuiti.dtos.AnswerDTO;
import com.javaproject.sistemi_distribuiti.dtos.CreateAnswerRequest;
import com.javaproject.sistemi_distribuiti.entity.*;
import com.javaproject.sistemi_distribuiti.service.*;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.*;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

import javax.json.Json;
import javax.json.JsonArrayBuilder;
import javax.json.JsonObjectBuilder;
import java.io.StringReader;
import java.net.http.HttpClient;
import java.net.http.HttpResponse;
import java.net.http.HttpRequest;

import org.mockito.MockedStatic;

import java.time.LocalDateTime;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

public class AnswerControllerTest {

    @InjectMocks
    private AnswerController answerController;

    @Mock
    private AnswerService answerService;

    @Mock
    private QuestionService questionService;

    @Mock
    private UserService userService;

    @Mock
    private JwtService jwtService;

    @Mock
    private NotificationService notificationService;

    @Mock
    private EmailService emailService;

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
    }

    @Test
    void createAnswer_shouldReturnCreatedResponse() {
        // Mock token info
        String token = "Bearer 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";
        String username = "employeeUser";
        int questionId = 1;

        User employee = new User();
        employee.setId(10);
        employee.setUsername(username);
        employee.setRole(Role.EMPLOYEE);

        Question question = new Question();
        question.setId(questionId);
        question.setTitle("Domanda?");
        question.setUser(employee);

        CreateAnswerRequest request = new CreateAnswerRequest();
        request.setText("Risposta generica");
        request.setQuestionId(questionId);

        Answer answer = new Answer();
        answer.setId(99);
        answer.setTextA(request.getText());
        answer.setQuestion(question);
        answer.setUser(employee);
        answer.setAnswerDate(LocalDateTime.now());

        // Mocks
        when(jwtService.extractRole("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")).thenReturn(Role.EMPLOYEE);
        when(jwtService.extractUsername("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")).thenReturn(username);
        when(userService.getUserByUsername(username)).thenReturn(employee);
        when(questionService.getQuestionById(questionId)).thenReturn(question);
        when(answerService.createAnswer(any(Answer.class))).thenReturn(answer);
        when(userService.getUserById(anyInt())).thenReturn(employee);

        // Act
        ResponseEntity<AnswerDTO> response = answerController.createAnswer(token, request);

        // Assert
        assertEquals(HttpStatus.CREATED, response.getStatusCode());
        assertNotNull(response.getBody());
        assertEquals(99, response.getBody().getId());
    }

    @Test
    void getAnswerById_shouldReturnAnswer() {
        Answer answer = new Answer();
        answer.setId(1);
        when(answerService.getAnswerById(1)).thenReturn(answer);

        ResponseEntity<Answer> response = answerController.getAnswerById(1);

        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertEquals(answer, response.getBody());
    }

    @Test
    void getAllAnswers_shouldReturnList() {
        when(answerService.getAllAnswers()).thenReturn(List.of(new Answer(), new Answer()));

        ResponseEntity<List<Answer>> response = answerController.getAllAnswers();

        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertEquals(2, response.getBody().size());
    }

    @Test
    void deleteAnswer_shouldReturnNoContent() {
        String token = "Bearer test-token";
        when(jwtService.extractRole("test-token")).thenReturn(Role.USER);

        ResponseEntity<Void> response = answerController.deleteAnswer(token, 1);

        verify(answerService, times(1)).deleteAnswer(1);
        assertEquals(HttpStatus.NO_CONTENT, response.getStatusCode());
    }

    @Test
    void deleteAnswer_shouldReturnForbiddenForEmployee() {
        String token = "Bearer test-token";
        when(jwtService.extractRole("test-token")).thenReturn(Role.EMPLOYEE);

        ResponseEntity<Void> response = answerController.deleteAnswer(token, 1);

        verify(answerService, never()).deleteAnswer(1);
        assertEquals(HttpStatus.FORBIDDEN, response.getStatusCode());
    }

    @Test
    void generateAIAnswer_shouldReturnGeneratedAnswer() throws Exception {
        // Arrange
        String token = "Bearer test-token";
        String pureToken = "test-token";
        int questionId = 123;

        User user = new User();
        user.setId(1);
        user.setEmail("user@example.com");

        Question question = new Question();
        question.setId(questionId);
        question.setTextQ("Cos'è il PIL?");
        question.setUser(user);

        String fakeResponseJson = """
        {
          "choices": [
            {
              "message": {
                "content": "Il PIL è il Prodotto Interno Lordo..."
              }
            }
          ]
        }
        """;

        Answer answer = new Answer();
        answer.setId(50);
        answer.setTextA("Il PIL è il Prodotto Interno Lordo...");
        answer.setQuestion(question);
        answer.setUser(user);
        answer.setAnswerDate(LocalDateTime.now());

        // Mocks
        when(jwtService.extractRole(pureToken)).thenReturn(Role.USER);
        when(questionService.getQuestionById(questionId)).thenReturn(question);

        // Mock static HttpClient.send()
        HttpClient mockClient = mock(HttpClient.class);
        HttpResponse<String> mockResponse = mock(HttpResponse.class);

        when(mockResponse.body()).thenReturn(fakeResponseJson);
        when(mockClient.send(any(HttpRequest.class), any(HttpResponse.BodyHandler.class))).thenReturn(mockResponse);

        try (MockedStatic<HttpClient> httpClientStatic = mockStatic(HttpClient.class)) {
            httpClientStatic.when(HttpClient::newHttpClient).thenReturn(mockClient);

            when(answerService.createAnswer(any(Answer.class))).thenReturn(answer);

            // Act
            ResponseEntity<AnswerDTO> response = answerController.generateAIAnswer(token, questionId);

            // Assert
            assertEquals(HttpStatus.CREATED, response.getStatusCode());
            assertNotNull(response.getBody());
            assertEquals("Il PIL è il Prodotto Interno Lordo...", response.getBody().getTextA());
        }
    }
}
