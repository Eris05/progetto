import 'QuestionDTO.dart';

class UserWithQuestionDTO {
  final int userId;
  final String username;
  final List<QuestionDTO> questions;

  UserWithQuestionDTO({
    required this.userId,
    required this.username,
    required this.questions,
  });

  factory UserWithQuestionDTO.fromJson(Map<String, dynamic> json) {
    return UserWithQuestionDTO(
      userId: json['userId'],
      username: json['username'],
      questions: (json['questions'] as List)
          .map((q) => QuestionDTO.fromJson(q))
          .toList(),
    );
  }
}