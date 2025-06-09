import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../constants/api_helpers.dart';
import '../model/dtos/AnswerDTO.dart';

class AnswerService {
  final String apiUrl = ApiConstants.answerQuestion;
  final String api2Url = ApiConstants.generateAIAnswer;

  // Recupera le risposte associate a una domanda
  Future<List<AnswerDTO>> getQuestionAnswer(String token, int questionId) async {
    final response = await http.get(
      Uri.parse('$apiUrl$questionId'),
      headers: authHeaders(token),
    );

    if (response.statusCode == 200) {
      // Decodifica la risposta in UTF-8 per evitare problemi con caratteri speciali
      final decodedBody = utf8.decode(response.bodyBytes);
      final List<dynamic> body = jsonDecode(decodedBody);

      // Converte il JSON in una lista di AnswerDTO
      return body.map((json) => AnswerDTO.fromJson(json)).toList();
    } else {
      // Gestisce il caso di errore
      throw Exception('Failed to load answers');
    }
  }

  // Genera una risposta con AI
  Future<Map<String, dynamic>?> generateAIAnswer(int questionId, String token) async {
    final url = Uri.parse('$api2Url?questionId=$questionId');

    try {
      final response = await http.post(
        url,
        headers: authHeaders(token),
      );

      if (response.statusCode == 201) {
        final decodedResponse = utf8.decode(response.bodyBytes); // Decodifica in UTF-8
        return jsonDecode(decodedResponse);
      } else if (response.statusCode == 403) {
        print("Accesso negato: solo gli utenti possono generare risposte.");
      } else if (response.statusCode == 404) {
        print("Domanda non trovata.");
      } else if (response.statusCode == 400) {
        print("Errore nella richiesta: parametri non validi.");
      } else {
        print("Errore interno del server.");
      }
    } catch (e) {
      print("Errore durante la richiesta: $e");
    }

    return null;
  }

  // Elimina una risposta
  Future<void> deleteAnswer(String token, int answerId) async {
    final response = await http.delete(
      Uri.parse('${ApiConstants.answer}/$answerId'),
      headers: authHeaders(token),
    );

    if (response.statusCode == 204) {
      print("Risposta eliminata con successo.");
    } else if (response.statusCode == 403) {
      throw Exception("Accesso negato: solo utenti autorizzati possono eliminare risposte.");
    } else if (response.statusCode == 404) {
      throw Exception("Errore: risposta non trovata.");
    } else if (response.statusCode == 400) {
      throw Exception("Errore nella richiesta: parametri non validi.");
    } else {
      throw Exception("Errore interno del server: ${response.statusCode} - ${response.body}");
    }
  }
}
