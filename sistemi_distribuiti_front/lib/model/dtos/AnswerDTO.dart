class AnswerDTO {
  final int id;
  final String textA;
  final int questionId;
  final DateTime answerDate;
  final int userId;

  AnswerDTO({
    required this.id,
    required this.textA,
    required this.questionId,
    required this.answerDate,
    required this.userId,
  });

  // Metodo per creare un'istanza da una mappa JSON
  factory AnswerDTO.fromJson(Map<String, dynamic> json) {
    return AnswerDTO(
      id: json['id'],
      textA: json['textA'],
      questionId: json['questionId'],
      answerDate: DateTime(
        json['answerDate'][0],
        json['answerDate'][1],
        json['answerDate'][2],
        json['answerDate'][3],
        json['answerDate'][4],
        json['answerDate'][5],
      ),
      userId: json['userId'],
    );
  }
}
