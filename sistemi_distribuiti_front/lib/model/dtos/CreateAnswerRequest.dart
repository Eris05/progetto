class CreateAnswerRequest {
  String text; // Testo della risposta
  int questionId; // ID della domanda a cui si risponde

  // Costruttore con argomenti
  CreateAnswerRequest({
    required this.text,
    required this.questionId,
  });



  // Metodo per creare un oggetto AnswerRequest da un JSON (per deserializzazione)
  factory CreateAnswerRequest.fromJson(Map<String, dynamic> json) {
    return CreateAnswerRequest(
      text: json['text'],
      questionId: json['questionId'],
    );
  }

  // Metodo per convertire l'oggetto AnswerRequest in formato JSON (per l'invio al backend)
  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'questionId': questionId,
    };
  }

  // Override del metodo toString per una rappresentazione più leggibile
  @override
  String toString() {
    return 'AnswerRequest{textA: $text,questionId: $questionId}';
  }
}
