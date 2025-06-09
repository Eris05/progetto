import 'dart:convert';
import 'package:sistemi_distribuiti_front/constants/api_constants.dart';

import '../constants/api_helpers.dart';
import '../model/dtos/QuestionDTO.dart';
import 'package:http/http.dart' as http;

class QuestionService {
  //final String apiUrl = 'http://localhost:8080/api/app_users'; // Modifica con il tuo URL
  // String api2Url = 'http://localhost:8080/api';


  /// Recupera la domanda associata a quell'ID
  Future<QuestionDTO> getQuestion(String token, int questionId) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrlApi}/questions/$questionId'),
      headers: authHeaders(token),
    );

    if (response.statusCode == 200) {
      // Decodifica la risposta con UTF-8
      final decodedBody = utf8.decode(response.bodyBytes);
      final Map<String, dynamic> jsonData = jsonDecode(decodedBody);

      // Converti il JSON in un oggetto QuestionDTO
      final question = QuestionDTO.fromJson(jsonData);
      return question;
    } else if (response.statusCode == 404) {
      throw Exception('Domanda non trovata.');
    } else {
      throw Exception('Errore durante il recupero della domanda: ${response.body}');
    }
  }



  /// Recupera le domande di un utente specifico
  Future<List<QuestionDTO>> getUserQuestions(String token) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.appUsers}/questions'),
      headers: authHeaders(token),
    );

    if (response.statusCode == 200) {
      // Decodifica la risposta con UTF-8
      final decodedBody = utf8.decode(response.bodyBytes);
      final body = jsonDecode(decodedBody);

      // Controlla che il body sia una mappa e che contenga il campo "questions"
      if (body is Map<String, dynamic> && body.containsKey('questions')) {
        final questions = body['questions'] as List;

        // Converti ogni oggetto JSON in un QuestionDTO
        return questions
            .map((questionJson) => QuestionDTO.fromJson(questionJson))
            .toList();
      } else {
        throw Exception("Formato dei dati inaspettato: $body");
      }
    } else {
      throw Exception('Errore ${response.statusCode}: ${response.body}');
    }
  }

  /// Crea una nuova domanda
  Future<bool> createQuestion(Map<String, dynamic> questionData, String token) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrlApi}/questions'),
        headers: authHeaders(token),
        body: jsonEncode(questionData),
      );

      if (response.statusCode == 201) {
        return true; // Domanda creata con successo
      } else {
        throw Exception('Errore: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Errore durante la creazione della domanda: $e');
    }
  }

  Future<bool> updateQuestion(
      int questionId, Map<String, dynamic> questionData, String token) async {
    // Controlla che i dati richiesti siano presenti
    if (!questionData.containsKey('title') ||
        !questionData.containsKey('textQ') ||
        !questionData.containsKey('subject')) {
      throw Exception('Dati mancanti: titolo, testo o argomento non forniti.');
    }

    try {
      final url = Uri.parse('${ApiConstants.baseUrlApi}/questions/$questionId');
      final response = await http.put(
        url,
        headers: authHeaders(token),
        body: jsonEncode(questionData),
      );

      if (response.statusCode == 200) {
        // Aggiornamento riuscito
        return true;
      } else if (response.statusCode == 403) {
        throw Exception('Accesso negato: non sei autorizzato a modificare questa domanda.');
      } else if (response.statusCode == 404) {
        throw Exception('Domanda non trovata.');
      } else if (response.statusCode == 400) {
        throw Exception('Errore di validazione: ${response.body}');
      } else {
        throw Exception('Errore: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      // Gestione generale degli errori
      throw Exception('Errore durante la modifica della domanda: $e');
    }
  }


  /// Aggiorna lo stato di una domanda scaduta
  Future<bool> updateExpiredQuestion(int questionId, String token) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConstants.baseUrlApi}/questions/expired/$questionId'),
        headers: authHeaders(token),
      );

      if (response.statusCode == 200) {
        return true; // Aggiornamento riuscito
      } else if (response.statusCode == 403) {
        throw Exception(
            'Accesso negato: non sei autorizzato a modificare questa domanda.');
      } else if (response.statusCode == 404) {
        throw Exception('Domanda non trovata.');
      } else {
        throw Exception('Errore: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Errore durante l\'aggiornamento della domanda scaduta: $e');
    }
  }

  /// Filtra una lista di domande per stato
  static List<QuestionDTO> filterQuestionsByStatus(
      List<QuestionDTO> questions, String status) {
    return questions.where((question) => question.status == status).toList();
  }


  ///eliminare le domande scadute
  Future<void> deleteQuestion(String token, int questionId) async {
    final response = await http.delete(
      Uri.parse('${ApiConstants.baseUrlApi}/questions/$questionId'),
      headers: authHeaders(token),
    );

    // Controlla lo stato della risposta
    if (response.statusCode == 204) {
      // Eliminazione riuscita: non è prevista una risposta, quindi non restituiamo nulla
      print("Domanda eliminata con successo.");
    } else if (response.statusCode == 403) {
      throw Exception("Accesso negato: solo le domande scadute possono essere eliminate.");
    } else if (response.statusCode == 404) {
      throw Exception("Errore: domanda non trovata.");
    } else if (response.statusCode == 400) {
      throw Exception("Errore nella richiesta: parametri non validi.");
    } else {
      throw Exception("Errore interno del server: ${response.body}");
    }
  }
}
