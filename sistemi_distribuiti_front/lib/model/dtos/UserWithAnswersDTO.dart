class UserWithAnswersDTO {
  final int userId;
  final String username;
  final List<String> answers;

  UserWithAnswersDTO({
    required this.userId,
    required this.username,
    required this.answers,
  });

  // Factory per creare un'istanza da JSON
  factory UserWithAnswersDTO.fromJson(Map<String, dynamic> json) {
    return UserWithAnswersDTO(
      userId: json['userId'],
      username: json['username'],
      answers: List<String>.from(json['answers']),
    );
  }

  // Metodo per serializzare l'oggetto in JSON
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'answers': answers,
    };
  }
}
