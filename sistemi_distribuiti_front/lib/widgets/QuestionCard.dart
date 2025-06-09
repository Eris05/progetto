import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jwt_decode/jwt_decode.dart';
import '../model/dtos/QuestionDTO.dart';
import '../model/dtos/AnswerDTO.dart';
import '../screens/edit_question_screen.dart';
import '../services/answer_service.dart';
import '../services/question_service.dart';
import '../util/popup_utils.dart';
import 'answer_card.dart';

class QuestionCard extends StatefulWidget {
  final QuestionDTO question;
  final VoidCallback onTap;
  final VoidCallback? onEditTap;
  final bool isAuthenticated;
  final bool isSelected;
  final String token;
  final VoidCallback onUpdate;

  QuestionCard({
    required this.question,
    required this.onTap,
    this.onEditTap,
    this.isAuthenticated = false,
    this.isSelected = false,
    required this.token,
    required this.onUpdate,
  });

  @override
  _QuestionCardState createState() => _QuestionCardState();
}

class _QuestionCardState extends State<QuestionCard> {
  final AnswerService answerService = AnswerService();
  final QuestionService questionService = QuestionService();
  bool isExpanded = false;
  List<AnswerDTO> answers = [];
  bool isLoadingAnswer = false;
  bool isGeneratingAnswer = false;
  bool isEmployee = false;

  @override
  void initState() {
    super.initState();
    _decodeToken();
  }


  void _decodeToken() {
    try {
      Map<String, dynamic> payload = Jwt.parseJwt(widget.token);
      setState(() {
        isEmployee = payload['role'] == 'EMPLOYEE';
      });
    } catch (e) {
      print("Errore nella decodifica del token: $e");
    }
  }

  void _toggleExpand() async {
    if (!isExpanded) {
      setState(() {
        isLoadingAnswer = true;
      });

      try {
        List<AnswerDTO> response = await answerService.getQuestionAnswer(
          widget.token,
          widget.question.id,
        );

        setState(() {
          answers = response;
        });
      } catch (error) {
        print('Errore durante il recupero della risposta: $error');
        setState(() {
          answers = [];
        });
      } finally {
        setState(() {
          isLoadingAnswer = false;
        });
      }
    }
    setState(() {
      isExpanded = !isExpanded;
    });
  }

  Future<void> _generateAIAnswer() async {
    setState(() {
      isGeneratingAnswer = true;
    });

    try {
      var response = await answerService.generateAIAnswer(
        widget.question.id,
        widget.token,
      );

      if (response != null) {
        await PopupUtils.showCenterPopup(context, 'Risposta generata con successo');

        setState(() {
          answers.add(AnswerDTO(
            id: response['id'],
            textA: response['textA'],
            questionId: response['questionId'],
            answerDate: DateTime.now(),
            userId: response['userId'],
          ));
        });
      } else {
        await PopupUtils.showCenterPopup(context, 'Errore nella generazione della risposta', isError: true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore: $e')),
      );
    } finally {
      setState(() {
        isGeneratingAnswer = false;
      });
    }
  }

  String getHumanStatus(String status) {
    switch (status) {
      case 'WAITING_FOR_ANSWER':
        return 'In attesa';
      case 'ANSWER_PROVIDED':
        return 'Risolta';
      case 'EXPIRED_NO_ANSWER':
        return 'Scaduta';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFF30344C);
    const titleColor = Color(0xFFC6E1ED);
    const bodyTextColor = Color(0xFFC0C3D7);

    Color getStatusColor(String status) {
      switch (status) {
        case 'WAITING_FOR_ANSWER':
          return Colors.orangeAccent;
        case 'ANSWER_PROVIDED':
          return Colors.greenAccent;
        case 'EXPIRED_NO_ANSWER':
          return Colors.redAccent;
        default:
          return Colors.blueGrey;
      }
    }

    String formatDateTime(DateTime dateTime) {
      final DateFormat formatter = DateFormat('dd MMMM yyyy, HH:mm');
      return formatter.format(dateTime);
    }

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: Offset(4, 4),
            ),
          ],
        ),
        margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titolo
            Text(
              widget.question.title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: titleColor,
              ),
            ),
            SizedBox(height: 8),
            // Argomento
            Text(
              widget.question.subject.toUpperCase(),
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: 8),
            // Testo della domanda
            Text(
              widget.question.textQ,
              style: TextStyle(
                fontSize: 16,
                color: bodyTextColor,
                fontWeight: FontWeight.w400,
                height: 1.5,
              ),
            ),
            SizedBox(height: 8),
            // Data di creazione e stato
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Data di creazione: ${formatDateTime(widget.question.publishDate)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: bodyTextColor,
                  ),
                ),
                SizedBox(height: 4),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                  decoration: BoxDecoration(
                    color: getStatusColor(widget.question.status),
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Text(
                    getHumanStatus(widget.question.status),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            if (widget.question.status == 'ANSWER_PROVIDED')
              Column(
                children: [
                  TextButton(
                    onPressed: _toggleExpand,
                    child: Text(
                      isExpanded ? 'Nascondi risposta' : 'Mostra risposta',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                  if (isExpanded)
                    isLoadingAnswer
                        ? Center(child: CircularProgressIndicator())
                        : answers.isEmpty
                        ? Text('Nessuna risposta disponibile.')
                        : Column(
                      children: answers.map((answer) {
                        return AnswerCard(
                          id: answer.id,
                          textA: answer.textA,
                          questionId: answer.questionId,
                          answerDate: answer.answerDate,
                          userId: answer.userId,
                          token: widget.token,
                        );
                      }).toList(),
                    ),
                ],
              ),
            if (!isEmployee && widget.question.status == 'WAITING_FOR_ANSWER')
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 200, // aumenta la larghezza per evitare il wrap
                    child: ElevatedButton(
                      onPressed: isGeneratingAnswer
                          ? null
                          : () async {
                        setState(() {
                          isGeneratingAnswer = true;
                        });
                        try {
                          await _generateAIAnswer();
                          widget.onUpdate();
                        } catch (e) {
                          await PopupUtils.showCenterPopup(context, 'Errore nella generazione della risposta', isError: true);
                        } finally {
                          setState(() {
                            isGeneratingAnswer = false;
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: isGeneratingAnswer
                          ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                          : FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text('Genera risposta con AI'),
                            ),
                    ),
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    width: 160,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditQuestionScreen(
                              question: widget.question,
                              token: widget.token,
                            ),
                          ),
                        ).then((_) {
                          widget.onUpdate();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text('Modifica Domanda'),
                    ),
                  ),
                ],
              ),
            if (!isEmployee && widget.question.status == 'EXPIRED_NO_ANSWER')
              Row(
                children: [
                  ElevatedButton.icon(
                    icon: Icon(Icons.refresh, color: Colors.white),
                    label: Text('Riproponi'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    ),
                    onPressed: () async {
                      try {
                        await questionService.updateExpiredQuestion(widget.question.id, widget.token);
                        await PopupUtils.showCenterPopup(context, 'Domanda riproposta con successo');
                        widget.onUpdate();
                      } catch (e) {
                        await PopupUtils.showCenterPopup(context, 'Si è verificato un errore', isError: true);
                      }
                    },
                  ),
                  SizedBox(width: 12),
                  ElevatedButton.icon(
                    icon: Icon(Icons.delete, color: Colors.white),
                    label: Text('Elimina'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    ),
                    onPressed: () async {
                      try {
                        await questionService.deleteQuestion(widget.token, widget.question.id);
                        await PopupUtils.showCenterPopup(context, 'Domanda eliminata con successo');
                        widget.onUpdate();
                      } catch (e) {
                        await PopupUtils.showCenterPopup(context, 'Si è verificato un errore', isError: true);
                      }
                    },
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
