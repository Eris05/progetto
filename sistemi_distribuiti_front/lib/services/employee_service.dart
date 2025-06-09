import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sistemi_distribuiti_front/constants/api_constants.dart';
import '../constants/api_helpers.dart';
import '../model/dtos/UserDTO.dart';

class EmployeeService {
  //final String apiUrl = 'http://localhost:8080/api/app_users/emoloyee'; // URL API backend

  Future<UserDTO> getEmployeeById(int id, String token) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.employeeService}/$id'),
      headers: authHeaders(token),
    );

    if (response.statusCode == 200) {
      return UserDTO.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Errore nel recupero delle informazioni del dipendente');
    }
  }
}
