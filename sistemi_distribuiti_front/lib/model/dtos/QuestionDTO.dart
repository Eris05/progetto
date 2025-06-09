class QuestionDTO{
  int id;
  String subject;
  DateTime publishDate;
  String title;
  String textQ;

  String status;

  dynamic user;

  QuestionDTO({
    required this.id,
    required this.subject,
    required this.publishDate,
    required this.status,
    required this.textQ,
    required this.title,
    this.user
  });

  factory QuestionDTO.fromJson(Map<String,dynamic> json){
    return QuestionDTO(
        id: json['id'],
        subject: json['subject'],
        publishDate: DateTime(
          json['publishDate'][0], // Anno
          json['publishDate'][1], // Mese
          json['publishDate'][2], // Giorno
          json['publishDate'][3], // Ore
          json['publishDate'][4], // Minuti
          json['publishDate'][5], // Secondi
          json['publishDate'][6] ~/ 1000000, // Microsecondi
        ),
        status: json['status'],
        textQ: json['textQ'],
        title: json['title'],
        user: json['user']
    );
  }//fromJson

  Map<String,dynamic> toJson() =>{
    'id':id,
    'subject':subject,
    'publishDate': publishDate.toIso8601String(),
    'status':status,
    'textQ':textQ,
    'title': title,
    'user':user
  };//toJson

  @override
  String toString(){
    return title;
  }
}