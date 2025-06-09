import 'Question.dart';
import 'User.dart';

class Answer{
  int id;
  String textA;
  Question question;
  User user;
  DateTime answerDate;

  Answer({
    required this.id,
    required this.textA,
    required this.question,
    required this.user,
    required this.answerDate
});

  factory Answer.fromJson(Map<String,dynamic> json){
    return Answer(
      id: json['id'],
      textA: json['textA'],
      question: Question.fromJson(json['question']),
      user: User.fromJson(json['user']),
        answerDate: DateTime.parse(json['answerDate'])
    );
  }//fromJson

  Map<String,dynamic> toJson() =>{
    'id':id,
    'textA':textA,
    'question': question.toJson(),
    'user': user.toString(),
    'answerDate': answerDate.toIso8601String()
  };//toJson

  @override
  String toString(){
    return textA;
  }
}//Answer