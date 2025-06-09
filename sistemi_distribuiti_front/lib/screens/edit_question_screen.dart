import 'package:flutter/material.dart';
import '../services/question_service.dart';
import '../model/dtos/QuestionDTO.dart';
import '../util/popup_utils.dart';
import '../widgets/PatternBackground.dart';

class EditQuestionScreen extends StatefulWidget {
  final QuestionDTO question;
  final String token;

  EditQuestionScreen({required this.question, required this.token});

  @override
  _EditQuestionScreenState createState() => _EditQuestionScreenState();
}

class _EditQuestionScreenState extends State<EditQuestionScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _textQController;
  late String _selectedSubject;
  bool isLoading = false;

  final Map<String, String> subjectsLabels = {
    "TECHNICAL_SUPPORT": "Supporto Tecnico",
    "BILLING": "Fatturazione",
    "ACCOUNT_MANAGEMENT": "Gestione Account",
    "PRODUCT_INQUIRY": "Richiesta Prodotto",
    "GENERAL_INFORMATION": "Informazioni Generali"
  };

  List<String> get _subjects => subjectsLabels.keys.toList();
  late int remainingChars; // Variabile per il conteggio dei caratteri rimanenti
  final int maxChars = 3000; //variabile per il limite di parole

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.question.title);
    _textQController = TextEditingController(text: widget.question.textQ);
    _selectedSubject = widget.question.subject;
    remainingChars = maxChars - _textQController.text.length;
    _textQController.addListener(() {
      setState(() {
        remainingChars = maxChars - _textQController.text.length;
      });
    });
  }

  Future<void> _updateQuestion() async {
    if (_formKey.currentState!.validate() && _selectedSubject.isNotEmpty) {
      setState(() => isLoading = true);
      try {
        final questionService = QuestionService();
        final success = await questionService.updateQuestion(
          widget.question.id,
          {
            'title': _titleController.text,
            'textQ': _textQController.text,
            'subject': _selectedSubject,
          },
          widget.token,
        );
        if (success) {
          await PopupUtils.showCenterPopup(
            context,
            'Domanda aggiornata con successo!',
          );
          Navigator.pop(context, true);
        } else {
          throw 'Errore durante il salvataggio della domanda';
        }
      } catch (e) {
        await PopupUtils.showCenterPopup(
          context,
          'Errore durante l\'aggiornamento della domanda: $e',
          isError: true,
        );
      } finally {
        setState(() => isLoading = false);
      }
    }
  }

  IconData _getSubjectIcon(String subject) {
    switch (subject) {
      case "TECHNICAL_SUPPORT":
        return Icons.build_rounded;
      case "BILLING":
        return Icons.receipt_long_rounded;
      case "ACCOUNT_MANAGEMENT":
        return Icons.manage_accounts_rounded;
      case "PRODUCT_INQUIRY":
        return Icons.shopping_bag_rounded;
      case "GENERAL_INFORMATION":
        return Icons.info_outline_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    const cardBg = Color(0xFFF8FAFF);
    const primaryBlue = Color(0xFF1976D2);
    const labelColor = Color(0xFF263238);
    const inputFill = Color(0xFFF1F4FB);


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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 18),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.07),
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
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Modifica domanda',
                                    style: TextStyle(
                                      fontSize: 21,
                                      fontWeight: FontWeight.bold,
                                      color: labelColor,
                                      fontFamily: 'Roboto',
                                      height: 1.3,
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.close, color: labelColor),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              Text(
                                'Argomento',
                                style: TextStyle(
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w500,
                                  color: labelColor,
                                  fontFamily: 'Roboto',
                                  letterSpacing: 0.1,
                                ),
                              ),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<String>(
                                value: _selectedSubject,
                                items: _subjects.map((subject) {
                                  return DropdownMenuItem(
                                    value: subject,
                                    child: Row(
                                      children: [
                                        Icon(
                                          _getSubjectIcon(subject),
                                          color: primaryBlue,
                                          size: 20,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          subjectsLabels[subject] ?? subject,
                                          style: TextStyle(
                                            color: labelColor,
                                            fontWeight: FontWeight.w500,
                                            fontFamily: 'Roboto',
                                            fontSize: 15,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: inputFill,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14.0),
                                    borderSide: BorderSide(color: primaryBlue, width: 1.2),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14.0),
                                    borderSide: BorderSide(color: Color(0xFFB3C6D6), width: 1.2),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14.0),
                                    borderSide: BorderSide(color: primaryBlue, width: 2),
                                  ),
                                  hintText: 'Seleziona un argomento',
                                  hintStyle: TextStyle(
                                    color: Colors.grey[500],
                                    fontWeight: FontWeight.w400,
                                    fontSize: 15,
                                    fontFamily: 'Roboto',
                                  ),
                                  contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 14),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedSubject = value!;
                                  });
                                },
                                style: TextStyle(
                                  color: labelColor,
                                  fontSize: 15.5,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w500,
                                ),
                                dropdownColor: inputFill,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Seleziona un argomento';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 18),
                              TextFormField(
                                controller: _titleController,
                                decoration: InputDecoration(
                                  labelText: 'Titolo',
                                  labelStyle: TextStyle(
                                    color: labelColor.withOpacity(0.85),
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Roboto',
                                    fontSize: 15.5,
                                    letterSpacing: 0.1,
                                  ),
                                  filled: true,
                                  fillColor: inputFill,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14.0),
                                    borderSide: BorderSide(color: primaryBlue, width: 1.2),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14.0),
                                    borderSide: BorderSide(color: Color(0xFFB3C6D6), width: 1.2),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14.0),
                                    borderSide: BorderSide(color: primaryBlue, width: 2),
                                  ),
                                  hintText: 'Inserisci il titolo della domanda',
                                  hintStyle: TextStyle(
                                    color: Colors.grey[500],
                                    fontWeight: FontWeight.w400,
                                    fontSize: 15,
                                    fontFamily: 'Roboto',
                                  ),
                                  contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 14),
                                ),
                                style: TextStyle(
                                  color: labelColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Roboto',
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Inserisci un titolo';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 18),
                              TextFormField(
                                controller: _textQController,
                                maxLength: maxChars,
                                decoration: InputDecoration(
                                  labelText: 'Testo della domanda',
                                  labelStyle: TextStyle(
                                    color: labelColor.withOpacity(0.85),
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Roboto',
                                    fontSize: 15.5,
                                    letterSpacing: 0.1,
                                  ),
                                  filled: true,
                                  fillColor: inputFill,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14.0),
                                    borderSide: BorderSide(color: primaryBlue, width: 1.2),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14.0),
                                    borderSide: BorderSide(color: Color(0xFFB3C6D6), width: 1.2),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14.0),
                                    borderSide: BorderSide(color: primaryBlue, width: 2),
                                  ),
                                  hintText: 'Scrivi qui la tua domanda',
                                  hintStyle: TextStyle(
                                    color: Colors.grey[500],
                                    fontWeight: FontWeight.w400,
                                    fontSize: 15,
                                    fontFamily: 'Roboto',
                                  ),
                                  contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                                ),
                                style: TextStyle(
                                  color: labelColor,
                                  fontSize: 15.5,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w500,
                                  height: 1.6,
                                ),
                                maxLines: 5,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Inserisci il testo della domanda';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: ElevatedButton(
                            onPressed: _updateQuestion,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryBlue,
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
                            child: Text('Salva Modifiche'),
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