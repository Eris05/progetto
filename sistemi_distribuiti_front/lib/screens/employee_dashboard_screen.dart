import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Usa shared_preferences
import 'package:http/http.dart' as http;
import 'package:sistemi_distribuiti_front/constants/api_constants.dart';
import 'dart:convert';
import 'dart:ui'; // <--- aggiungi questa riga per FontFeature
import '../model/dtos/QuestionDTO.dart';

import '../util/popup_utils.dart';
import 'auth_screen.dart';
import 'create_answer_screen.dart'; // Importa la schermata per rispondere alla domanda


void showStyledSnackBar(BuildContext context, String message, {bool isError = false}) {
  final color = isError ? Color(0xFFEF5350) : Color(0xFF66BB6A);
  final icon = isError ? Icons.error_outline : Icons.check_circle;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.white,
                fontFamily: 'Roboto',
              ),
            ),
          ),
        ],
      ),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      duration: Duration(seconds: 3),
      elevation: 8,
    ),
  );
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

// Funzione di mapping per le categorie tecniche in label leggibili
String getHumanCategory(String? category) {
  switch (category) {
    case 'TECHNICAL_SUPPORT':
      return 'Supporto tecnico';
    case 'BILLING':
      return 'Fatturazione';
    case 'ACCOUNT_MANAGEMENT':
      return 'Gestione account';
    case 'PRODUCT_INQUIRY':
      return 'Informazioni prodotto';
    case 'GENERAL_INFORMATION':
      return 'Informazioni generali';
    default:
      return category?.replaceAll('_', ' ') ?? '';
  }
}

class EmployeeDashboardScreen extends StatefulWidget {
  final String token;
  final String email;

  const EmployeeDashboardScreen({Key? key, required this.token, required this.email}) : super(key: key);

  @override
  _EmployeeDashboardScreenState createState() => _EmployeeDashboardScreenState();
}

class _EmployeeDashboardScreenState extends State<EmployeeDashboardScreen> {
  QuestionDTO? selectedQuestion;
  String _searchQuery = "";
  String? _selectedCategory;
  bool _descendingOrder = true;


  void _logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('jwt_token');
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => AuthScreen()),
            (route) => false,
      );
    } catch (error) {
      debugPrint('Errore durante il logout: $error');
      await PopupUtils.showCenterPopup(context, 'Errore durante il logout.', isError: true);
    }
  }

  Future<List<QuestionDTO>> _fetchQuestions() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.fetchQuestion),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return data.map((item) => QuestionDTO.fromJson(item)).toList();
      } else {
        throw Exception('Errore durante il recupero delle domande');
      }
    } catch (e) {
      throw Exception('Errore durante la chiamata HTTP');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF30344C),
        title: Text('Dashboard Dipendente', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF5F7FA),
              Color(0xFFE9ECF3),
              Color(0xFFDDE3ED),
            ],
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 700),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Barra ricerca e filtri in una card
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    color: Color(0xFFF7F9FC),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Barra di ricerca con ombra leggera
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.07),
                                  blurRadius: 10,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    decoration: InputDecoration(
                                      labelText: 'Cerca per titolo',
                                      labelStyle: TextStyle(
                                        color: Colors.blueGrey[700],
                                        fontWeight: FontWeight.w600,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(color: Colors.grey, width: 1),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(color: Colors.grey, width: 1),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(color: Colors.blue, width: 1),
                                      ),
                                      prefixIcon: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 6.0),
                                        child: Icon(Icons.search, color: Colors.blueAccent, size: 22),
                                      ),
                                      prefixIconConstraints: BoxConstraints(minWidth: 36, minHeight: 36),
                                      contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                                      filled: true,
                                      fillColor: Colors.white,
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        _searchQuery = value;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 22), // Maggiore spazio tra ricerca e filtri
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                // Inizio pulsanti filtro categoria
                                ...[
                                  {
                                    'label': 'TECHNICAL_SUPPORT',
                                    'icon': Icons.build_rounded,
                                  },
                                  {
                                    'label': 'BILLING',
                                    'icon': Icons.receipt_long_rounded,
                                  },
                                  {
                                    'label': 'ACCOUNT_MANAGEMENT',
                                    'icon': Icons.person_outline_rounded,
                                  },
                                  {
                                    'label': 'PRODUCT_INQUIRY',
                                    'icon': Icons.info_outline_rounded,
                                  },
                                  {
                                    'label': 'GENERAL_INFORMATION',
                                    'icon': Icons.help_outline_rounded,
                                  },
                                ].map<Widget>((cat) {
                                  final category = cat['label'] as String;
                                  final icon = cat['icon'] as IconData;
                                  final bool isSelected = _selectedCategory == category;
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                                    child: MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      onEnter: (_) => setState(() {}),
                                      onExit: (_) => setState(() {}),
                                      child: AnimatedContainer(
                                        duration: Duration(milliseconds: 200),
                                        curve: Curves.ease,
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? Color(0xFF1976D2)
                                              : Color(0xFFE3F2FD),
                                          borderRadius: BorderRadius.circular(32),
                                          boxShadow: isSelected
                                              ? [
                                            BoxShadow(
                                              color: Colors.blue.withOpacity(0.15),
                                              blurRadius: 8,
                                              offset: Offset(0, 2),
                                            )
                                          ]
                                              : [],
                                          border: Border.all(
                                            color: isSelected
                                                ? Color(0xFF1976D2)
                                                : Color(0xFFB3C6D6),
                                            width: 1.5,
                                          ),
                                        ),
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(32),
                                          onTap: () {
                                            setState(() {
                                              _selectedCategory = isSelected ? null : category;
                                            });
                                          },
                                          child: AnimatedContainer(
                                            duration: Duration(milliseconds: 200),
                                            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment: CrossAxisAlignment.center, // Centra verticalmente
                                              children: [
                                                Icon(
                                                  icon,
                                                  size: 20,
                                                  color: isSelected
                                                      ? Colors.white
                                                      : Color(0xFF1976D2),
                                                ),
                                                SizedBox(width: 8),
                                                Text(
                                                  getHumanCategory(category), // <-- usa la funzione di mapping
                                                  style: TextStyle(
                                                    color: isSelected
                                                        ? Colors.white
                                                        : Color(0xFF1976D2),
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 13,
                                                    letterSpacing: 0.2,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                                // Fine pulsanti filtro categoria
                              ],
                            ),
                          ),
                          SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                "Ordina per data:",
                                style: TextStyle(
                                  color: Color(0xFF23263A), // colore più scuro e leggibile
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(width: 8),
                              DropdownButton<bool>(
                                value: _descendingOrder,
                                dropdownColor: Color(0xFFF7F9FC), // stesso sfondo della barra filtri (Card)
                                style: TextStyle(
                                  color: Color(0xFF23263A), // stesso colore di "Ordina per data"
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                                underline: SizedBox(),
                                items: [
                                  DropdownMenuItem(
                                    value: true,
                                    child: Text("Più recenti",
                                      style: TextStyle(
                                        color: Color(0xFF23263A), // stesso colore di "Ordina per data"
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: false,
                                    child: Text("Meno recenti",
                                      style: TextStyle(
                                        color: Color(0xFF23263A), // stesso colore di "Ordina per data"
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                ],
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      _descendingOrder = value;
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 36), // Più spazio tra filtri e lista domande
                  // Lista domande o empty state
                  Expanded(
                    child: FutureBuilder<List<QuestionDTO>>(
                      future: _fetchQuestions(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(child: Text('Errore nel caricamento delle domande'));
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Center(
                            child: AnimatedSwitcher(
                              duration: Duration(milliseconds: 400),
                              child: Card(
                                key: ValueKey('empty-state'),
                                elevation: 8,
                                color: Color(0xFF23263A),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 32),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.mark_email_read_rounded, size: 54, color: Colors.lightBlueAccent),
                                      SizedBox(height: 18),
                                      Text(
                                        "Tutto tranquillo per ora!\nNessuna domanda da rispondere 😊",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        } else {
                          final filteredQuestions = snapshot.data!
                              .where((q) =>
                          (_searchQuery.isEmpty ||
                              q.title.toLowerCase().contains(_searchQuery.toLowerCase())) &&
                              (_selectedCategory == null || q.subject == _selectedCategory))
                              .toList();
                          final sortedQuestions = List<QuestionDTO>.from(filteredQuestions)
                            ..sort((a, b) => _descendingOrder
                                ? b.publishDate.compareTo(a.publishDate)
                                : a.publishDate.compareTo(b.publishDate));
                          return AnimatedSwitcher(
                            duration: Duration(milliseconds: 400),
                            child: selectedQuestion == null
                                ? ListView.builder(
                                    key: ValueKey('list'),
                                    itemCount: sortedQuestions.length,
                                    itemBuilder: (context, index) {
                                      final question = sortedQuestions[index];
                                      return MouseRegion(
                                        cursor: SystemMouseCursors.click,
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              selectedQuestion = question;
                                            });
                                          },
                                          child: AnimatedContainer(
                                            duration: Duration(milliseconds: 180),
                                            curve: Curves.easeInOut,
                                            child: Card(
                                              elevation: 4,
                                              margin: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(14),
                                              ),
                                              color: Colors.blueGrey[800],
                                              child: Padding(
                                                padding: const EdgeInsets.all(18.0),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    // Stato badge
                                                    Row(
                                                      children: [
                                                        Container(
                                                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                          decoration: BoxDecoration(
                                                            color: Colors.orange[700],
                                                            borderRadius: BorderRadius.circular(8),
                                                          ),
                                                          child: Text(
                                                            getHumanStatus(question.status ?? ''),
                                                            style: TextStyle(
                                                              color: Colors.white,
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: 12,
                                                              fontFamily: 'Roboto',
                                                            ),
                                                          ),
                                                        ),
                                                        Spacer(),
                                                        Icon(Icons.label_important, color: Colors.lightBlueAccent, size: 20),
                                                        SizedBox(width: 6),
                                                        Text(
                                                          getHumanCategory(question.subject), // <-- usa la funzione di mapping
                                                          style: TextStyle(
                                                            color: Colors.lightBlueAccent,
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 14,
                                                            fontFamily: 'Roboto',
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: 10),
                                                    // Titolo della domanda
                                                    Text(
                                                      question.title ?? '',
                                                      style: TextStyle(
                                                        fontSize: 19,
                                                        fontWeight: FontWeight.bold,
                                                        height: 1.4,
                                                        fontFamily: 'Roboto',
                                                        color: Colors.white,
                                                        fontFeatures: [FontFeature.enable('liga')],
                                                      ),
                                                      textAlign: TextAlign.left,
                                                    ),
                                                    SizedBox(height: 6),
                                                    // Descrizione (testo domanda)
                                                    if (question.textQ != null && question.textQ!.isNotEmpty)
                                                      Text(
                                                        question.textQ!,
                                                        style: TextStyle(
                                                          fontSize: 15,
                                                          color: Colors.grey[200],
                                                          fontFamily: 'Noto Sans',
                                                          height: 1.7,
                                                          fontFeatures: [FontFeature.enable('liga')],
                                                          decoration: TextDecoration.none,
                                                          letterSpacing: 0.1,
                                                        ),
                                                        maxLines: 2,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  )
                                : Card(
                              key: ValueKey('dettaglio'),
                              margin: EdgeInsets.symmetric(vertical: 32, horizontal: 0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 8,
                              color: Colors.blueGrey[900],
                              child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxHeight: MediaQuery.of(context).size.height * 0.85, // max 85% schermo
                                  ),
                                  child: SingleChildScrollView(
                                      padding: const EdgeInsets.all(24.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "Domanda",
                                                style: TextStyle(
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.lightBlueAccent,
                                                  fontFamily: 'Roboto',
                                                ),
                                              ),
                                              IconButton(
                                                icon: Icon(Icons.close, color: Colors.white70),
                                                onPressed: () {
                                                  setState(() {
                                                    selectedQuestion = null;
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 16),
                                          // Titolo della domanda
                                          Text(
                                            selectedQuestion?.title ?? '',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              height: 1.6,
                                              fontFamily: 'Roboto',
                                              color: Colors.white,
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          // Categoria leggibile
                                          if (selectedQuestion?.subject != null)
                                            Text(
                                              getHumanCategory(selectedQuestion!.subject),
                                              style: TextStyle(
                                                color: Colors.lightBlueAccent,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                                letterSpacing: 0.2,
                                              ),
                                            ),
                                          SizedBox(height: 16),
                                          // Testo della domanda (aggiunto qui)
                                          if (selectedQuestion?.textQ != null && selectedQuestion!.textQ!.isNotEmpty)
                                            Container(
                                              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                                              decoration: BoxDecoration(
                                                color: Colors.blueGrey[800],
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                selectedQuestion!.textQ!,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.white70,
                                                  fontFamily: 'Noto Sans',
                                                  height: 1.7,
                                                  fontFeatures: [FontFeature.enable('liga')],
                                                  decoration: TextDecoration.none,
                                                  letterSpacing: 0.1,
                                                ),
                                              ),
                                            ),
                                          SizedBox(height: 24),
                                          ElevatedButton.icon(
                                            icon: Icon(Icons.reply, color: Colors.white),
                                            label: Text(
                                              "Rispondi",
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Roboto',
                                              ),
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.lightBlue,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32), // Adjust padding for better clickability
                                              minimumSize: Size(double.infinity, 48), // Ensure button is sufficiently wide and clickable
                                            ),
                                            onPressed: () async {
                                              if (selectedQuestion != null && widget.token.isNotEmpty) {
                                                await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => CreateAnswerScreen(
                                                      questionId: selectedQuestion!.id,
                                                      token: widget.token,
                                                      onAnswerSubmitted: () {
                                                        setState(() {
                                                          selectedQuestion = null;
                                                        });
                                                      },
                                                    ),
                                                  ),
                                                );
                                                setState(() {}); // Update UI after the response submission
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
