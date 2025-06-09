import 'User.dart';

class Question{
  int id;
  String title;
  String textQ;
  String subject;
  DateTime publishDate;
  DateTime expirationDate;
  User user;

  Question({
    required this.id,
    required this.title,
    required this.textQ,
    required this.subject,
    required this.publishDate,
    required this.expirationDate,
    required this.user
  });

  factory Question.fromJson(Map<String,dynamic> json){
    return Question(
      id: json['id'],
      title: json['title'],
      textQ: json['textQ'],
      subject: json['subject'],
      publishDate: DateTime.parse(json['publishDate']),// Parsing della stringa ISO-8601
      expirationDate: DateTime.parse(json['expirationDate']),
      user: User.fromJson(json['user'])
    );
  }//fromJson

  Map<String,dynamic> toJson() =>{
    'id':id,
    'title':title,
    'textQ':textQ,
    'subject':subject,
    'publishDate': publishDate.toIso8601String(),
    'expirationDate':expirationDate.toIso8601String(),
    'user': user.toJson()
  };//toJson

  @override
  String toString(){
    return title;
  }
}//Question