import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../constants/api_constants.dart';
import '../model/dtos/CreateAnswerRequest.dart';
import '../model/dtos/QuestionDTO.dart';
import '../services/question_service.dart';
import '../util/popup_utils.dart';
import '../widgets/PatternBackground.dart';


class CreateAnswerScreen extends StatefulWidget {
  final String token;
  final int questionId;
  final VoidCallback onAnswerSubmitted; // Callback per notificare il completamento

  const CreateAnswerScreen({
    Key? key,
    required this.token,
    required this.questionId,
    required this.onAnswerSubmitted,
  }) : super(key: key);

  @override
  _CreateAnswerScreenState createState() => _CreateAnswerScreenState();
}

class _CreateAnswerScreenState extends State<CreateAnswerScreen> {
  final _formKey = GlobalKey<FormState>();
  final QuestionService _questionService = QuestionService(); // Aggiunto il service
  TextEditingController _answerController = TextEditingController();
  QuestionDTO? _question; // La domanda recuperata
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchQuestion(); // Recupera la domanda al caricamento della pagina
  }

  Future<void> _fetchQuestion() async {
    setState(() {
      isLoading = true;
    });

    try {
      final question = await _questionService.getQuestion(widget.token, widget.questionId);
      setState(() {
        _question = question;
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore nel recupero della domanda: $error')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> submitAnswer() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    final answerRequest = CreateAnswerRequest(
      text: _answerController.text.trim(),
      questionId: widget.questionId,
    );

    final url = Uri.parse(ApiConstants.answer);
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(answerRequest.toJson()),
      );

      if (response.statusCode == 201) {
        await PopupUtils.showCenterPopup(
          context,
          'Risposta inviata con successo.',
        );
        widget.onAnswerSubmitted(); // Notifica alla dashboard
        Navigator.pop(context);
      } else {
        final errorMessage = jsonDecode(response.body)['message'] ?? 'Errore generico';
        await PopupUtils.showCenterPopup(context, 'Errore durante l\'invio della risposta: $errorMessage', isError: true);
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Errore di connessione al server.')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: PatternPainter(),
          ),
        ),
        Center(
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              padding: const EdgeInsets.all(16.0),
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_question != null)
                              Container(
                                margin: const EdgeInsets.only(bottom: 18),
                                decoration: BoxDecoration(
                                  color: Color(0xFF23263A),
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.10),
                                      blurRadius: 12,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Wrap(
                                        alignment: WrapAlignment.spaceBetween,
                                        crossAxisAlignment: WrapCrossAlignment.center,
                                        runSpacing: 8,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Color(0xFF1976D2),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.hourglass_empty, color: Colors.white, size: 16),
                                                SizedBox(width: 5),
                                                Text(
                                                  "IN ATTESA DI RISPOSTA",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                    letterSpacing: 1.2,
                                                    fontFamily: 'Roboto',
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (_question!.subject != null)
                                            Padding(
                                              padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                                              child: Text(
                                                _question!.subject!.replaceAll('_', ' '),
                                                style: TextStyle(
                                                  color: Colors.grey[300],
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 13,
                                                  letterSpacing: 1.1,
                                                  fontFamily: 'Roboto',
                                                  fontFeatures: [FontFeature.enable('smcp')],
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      SizedBox(height: 14),
                                      Text(
                                        _question!.title ?? '',
                                        style: TextStyle(
                                          fontSize: 21,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontFamily: 'Roboto',
                                          height: 1.3,
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      if (_question!.textQ != null && _question!.textQ!.isNotEmpty)
                                        Text(
                                          _question!.textQ!,
                                          style: TextStyle(
                                            fontSize: 15.5,
                                            color: Colors.grey[200],
                                            fontFamily: 'Noto Sans',
                                            height: 1.7,
                                            letterSpacing: 0.1,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 6.0, left: 2.0),
                                child: Text(
                                  'Risposta',
                                  style: TextStyle(
                                    color: Color(0xFF1A237E),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    letterSpacing: 0.1,
                                  ),
                                ),
                              ),
                            ),
                            TextFormField(
                              controller: _answerController,
                              maxLines: 5,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14.0),
                                  borderSide: BorderSide(color: Color(0xFF1976D2), width: 1.2),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14.0),
                                  borderSide: BorderSide(color: Color(0xFFB3C6D6), width: 1.2),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14.0),
                                  borderSide: BorderSide(color: Color(0xFF1976D2), width: 2),
                                ),
                                fillColor: Colors.white,
                                filled: true,
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Il campo risposta non può essere vuoto.';
                                }
                                return null;
                              },
                              style: TextStyle(
                                fontSize: 15.5,
                                color: Colors.black87,
                                fontFamily: 'Noto Sans',
                                height: 1.6,
                              ),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: ElevatedButton(
                                  onPressed: submitAnswer,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF1976D2),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16.0),
                                    ),
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    elevation: 3,
                                    textStyle: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      fontFamily: 'Roboto',
                                    ),
                                  ).copyWith(
                                    overlayColor: MaterialStateProperty.resolveWith<Color?>(
                                      (states) {
                                        if (states.contains(MaterialState.hovered) || states.contains(MaterialState.pressed)) {
                                          return Color(0xFF1565C0);
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  child: const Text('Invia Risposta'),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
