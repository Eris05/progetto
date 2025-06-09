import 'package:flutter/material.dart';
import '../services/question_service.dart';
import '../model/dtos/QuestionDTO.dart';
import '../util/popup_utils.dart';
import '../widgets/PatternBackground.dart';

class CreateQuestionScreen extends StatefulWidget {
  final String token; // Token JWT per autenticazione
  final QuestionDTO? question; // Domanda da modificare (opzionale)

  CreateQuestionScreen({required this.token, this.question});

  @override
  _CreateQuestionScreenState createState() => _CreateQuestionScreenState();
}

class _CreateQuestionScreenState extends State<CreateQuestionScreen> {
  final QuestionService _questionService = QuestionService();
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _textQController;
  final int maxChars = 3000; //variabile per il limite di parole
  bool isLoading = false;

  // Argomenti disponibili
  final Map<String, String> subjectsLabels = {
    "TECHNICAL_SUPPORT": "Supporto Tecnico",
    "BILLING": "Fatturazione",
    "ACCOUNT_MANAGEMENT": "Gestione Account",
    "PRODUCT_INQUIRY": "Richiesta Prodotto",
    "GENERAL_INFORMATION": "Informazioni Generali"
  };

  // Elenco di argomenti
  List<String> get _subjects => subjectsLabels.keys.toList();

  String? _selectedSubject; // Argomento selezionato
  late int remainingChars; // Variabile per il conteggio dei caratteri rimanenti
  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.question?.title ?? '',
    );
    _textQController = TextEditingController(
      text: widget.question?.textQ ?? '',
    );
    _selectedSubject = widget.question?.subject;
    remainingChars = maxChars - _textQController.text.length;
    _textQController.addListener(() {
      setState(() {
        remainingChars = maxChars - _textQController.text.length;
      });
    });
  }

  void _submitQuestion() async {
    if (_formKey.currentState!.validate() && _selectedSubject != null) {
      setState(() {
        isLoading = true;
      });

      try {
        final questionData = {
          "title": _titleController.text,
          "textQ": _textQController.text,
          "subject": _selectedSubject,
        };

        bool success;
        if (widget.question == null) {
          success = await _questionService.createQuestion(
            questionData,
            widget.token,
          );
        } else {
          success = await _questionService.updateQuestion(
            widget.question!.id,
            questionData,
            widget.token,
          );
        }

        if (success) {
          await PopupUtils.showCenterPopup(
            context,
            widget.question == null
                ? 'Domanda creata con successo!'
                : 'Domanda aggiornata con successo!',
          );

          Navigator.pop(context, true);
        } else {
          throw 'Errore durante il salvataggio della domanda';
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore: $error')),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    } else if (_selectedSubject == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Seleziona un argomento')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tema chiaro
    const cardBg = Color(0xFFF8FAFF); // sfondo card chiaro
    const primaryBlue = Color(0xFF1976D2);
    const labelColor = Color(0xFF263238); // grigio scuro per testo
    const inputFill = Color(0xFFF1F4FB); // input chiaro

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
                                    Text(
                                      widget.question == null
                                          ? 'Crea una nuova domanda'
                                          : 'Modifica domanda',
                                      style: TextStyle(
                                        fontSize: 21,
                                        fontWeight: FontWeight.bold,
                                        color: labelColor,
                                        fontFamily: 'Roboto',
                                        height: 1.3,
                                      ),
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
                                          _selectedSubject = value;
                                        });
                                      },
                                      style: TextStyle(
                                        color: labelColor,
                                        fontSize: 15.5,
                                        fontFamily: 'Roboto',
                                        fontWeight: FontWeight.w500,
                                      ),
                                      dropdownColor: inputFill,
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
                                      maxLength: maxChars,
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
                                  onPressed: _submitQuestion,
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
                                  child: Text(widget.question == null
                                      ? 'Crea Domanda'
                                      : 'Salva Modifiche'),
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
}
