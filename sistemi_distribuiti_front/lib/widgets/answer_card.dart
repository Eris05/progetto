import 'package:flutter/material.dart';

class AnswerCard extends StatelessWidget {
  final int id;
  final String textA;
  final int questionId;
  final DateTime answerDate;
  final int userId;
  final String token;

  const AnswerCard({
    required this.id,
    required this.textA,
    required this.questionId,
    required this.answerDate,
    required this.userId,
    required this.token,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Separatore visivo sopra la card
        Padding(
          padding: const EdgeInsets.only(top: 12.0, bottom: 6.0),
          child: Divider(
            color: Colors.grey.shade400,
            thickness: 1,
            height: 1,
          ),
        ),
        // Mini etichetta "Risposta" con icona
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.mail_outline, size: 18, color: Color(0xFF4FC3F7)), // azzurro chiaro
            SizedBox(width: 6),
            Text(
              'Risposta',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4FC3F7), // azzurro chiaro
                letterSpacing: 0.5,
              ),
            ),
            // ...rimosso il pulsante "Nascondi risposta"...
          ],
        ),
        // Card della risposta vera e propria
        Container(
          margin: const EdgeInsets.only(top: 4, bottom: 4),
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 22), // padding aumentato
          decoration: BoxDecoration(
            color: const Color(0xFF232A3A), // Grigio/blu scuro per tema dark
            borderRadius: BorderRadius.circular(14), // Angoli più arrotondati
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                textA,
                style: TextStyle(
                  fontSize: 18, // dimensione aumentata
                  color: Colors.white, // Testo chiaro su sfondo scuro
                  fontWeight: FontWeight.w400,
                  height: 1.7, // interlinea aumentata
                ),
              ),
              SizedBox(height: 10), // più spazio sotto il testo
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  'Data risposta: ' +
                      '${answerDate.day.toString().padLeft(2, '0')}/'
                      '${answerDate.month.toString().padLeft(2, '0')}/'
                      '${answerDate.year} ${answerDate.hour.toString().padLeft(2, '0')}:${answerDate.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    fontSize: 15, // leggermente più grande
                    color: Color(0xFFE0E6ED), // grigio chiaro più leggibile
                    fontWeight: FontWeight.w500,
                    height: 1.4, // interlinea anche qui
                  ),
                ),
              ),
            ],
          ),
        ),
        // ...rimosso il pulsante duplicato in basso...
      ],
    );
  }
}

// ...rimosso il widget _HideAnswerButton...
