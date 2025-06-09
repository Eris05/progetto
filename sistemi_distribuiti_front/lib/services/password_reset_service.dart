import 'dart:convert';
import 'package:http/http.dart' as http;

class PasswordResetService {
  final String baseUrl;

  PasswordResetService(this.baseUrl);

  Future<String?> requestPasswordReset(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/password-reset/request'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode == 200) {
      String responseBody = response.body;
      if (responseBody.contains("Token: ")) {
        return responseBody.split("Token: ")[1]; // Estrae il token dalla risposta
      }
      return null;
    } else {
      throw Exception('Errore durante la richiesta di reset');
    }
  }

  Future<void> resetPassword(String token, String newPassword) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/password-reset/reset'),
      headers: {
        'Content-Type': 'application/json',
        'Token': token, // Aggiunge il token come header automaticamente
      },
      body: jsonEncode({'newPassword': newPassword}),
    );

    if (response.statusCode != 200) {
      throw Exception('Errore durante il reset della password');
    }
  }

}
