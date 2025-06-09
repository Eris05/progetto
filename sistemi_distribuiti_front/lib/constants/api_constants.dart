class ApiConstants {
  static const String baseUrl = 'http://localhost:8080';
  static const String baseUrlApi = 'http://localhost:8080/api';

  //Endpoints
  static const String fetchQuestion = '$baseUrlApi/questions/waiting';
  static const String answer = '$baseUrlApi/answers';
  static const String answerQuestion = '$baseUrlApi/answers/question/';
  static const String generateAIAnswer = '$baseUrlApi/answers/generateAI/answer';

  static const String auth = "$baseUrl/auth";
  static const String employeeService = '$baseUrlApi/app_users/emoloyee';
  static const String notification = '$baseUrlApi/notifications';
  static const String appUsers = '$baseUrlApi/app_users';
}