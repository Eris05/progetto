import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart'; // Usa shared_preferences
import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../constants/api_helpers.dart';

class AuthService {
  /// Controlla il formato dell'email prima di registrare un nuovo utente
  bool isValidEmailFormat(String email) {
    final emailRegex = RegExp(r"^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$");
    return emailRegex.hasMatch(email);
  }

  bool isTokenValid(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        return false;
      }
      final payload = utf8.decode(base64.decode(base64.normalize(parts[1])));
      final data = json.decode(payload);
      final exp = data['exp'] * 1000; // Converti in millisecondi
      return DateTime.now().millisecondsSinceEpoch < exp;
    } catch (e) {
      print('Errore nel controllo del token: $e');
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    print('Logout effettuato e token rimosso.');
  }

  // Chiamata autenticata A CHE SERVE?! DOVE VIENE USATA?
  Future<void> fetchProtectedData() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');

    if (token == null || !isTokenValid(token)) {
      print('Nessun token valido trovato, l\'utente non è autenticato.');
      return;
    }

    final url = Uri.parse('${ApiConstants.auth}/protected-endpoint'); // Cambia con l'endpoint reale

    try {
      final response = await http.get(
        url,
        headers: authHeaders(token),
      );

      if (response.statusCode == 200) {
        print('Dati protetti ricevuti: ${response.body}');
      } else {
        print('Errore: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      print('Errore di rete: $e');
    }
  }

  // Metodo per registrare un utente (Signup)
  Future<bool> signup(String email, String password, String username) async {
    final url = Uri.parse('${ApiConstants.auth}/signup');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
          'username': username,
        }),
      );

      if (response.statusCode == 200) {
        return true; // Registrazione riuscita
      } else {
        print('Errore durante la registrazione: ${response.body}');
        return false; // Fallimento della registrazione
      }
    } catch (e) {
      print('Errore di rete: $e');
      return false;
    }
  }

  // Metodo per effettuare il login
  Future<Map<String, dynamic>?> login(String email, String password) async {
    final url = Uri.parse('${ApiConstants.auth}/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        // Decodifica della risposta JSON
        final data = json.decode(response.body);
        // Salva il token con shared_preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', data['token']);
        return {
          'token': data['token'],
          'expiresIn': data['expiresIn'],
        };
      } else {
        print('Errore durante il login: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Errore di rete: $e');
      return null;
    }
  }
}
