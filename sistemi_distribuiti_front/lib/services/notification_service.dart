import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sistemi_distribuiti_front/constants/api_constants.dart';
import '../constants/api_helpers.dart';
import '../model/Notification.dart' as notify;

class NotificationService {
  //final String baseUrl = 'http://localhost:8080/api/notifications';

  /// Recupera le notifiche non ancora lette
  Future<List<notify.Notification>> getUnreadNotifications(String username, String token) async {
    final url = Uri.parse('${ApiConstants.notification}/unread?username=$username');
    final response = await http.get(
      url,
      headers: authHeaders(token),
    );

    if (response.statusCode == 200) {
      // Decodifica la risposta con UTF-8
      final decodedBody = utf8.decode(response.bodyBytes);
      final List<dynamic> jsonData = json.decode(decodedBody);

      // Converte ogni elemento JSON in un oggetto Notification
      return jsonData.map((item) => notify.Notification.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load notifications');
    }
  }


  Future<void> markNotificationAsRead(int notificationId, String token) async {
    final url = Uri.parse('${ApiConstants.notification}/$notificationId/read');
    final response = await http.put(
      url,
      headers: authHeaders(token),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to mark notification as read');
    }
  }



}
