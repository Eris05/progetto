import 'package:flutter/material.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Usa shared_preferences

import '../model/Notification.dart' as notify;
import '../model/dtos/QuestionDTO.dart';
import '../services/question_service.dart';
import '../services/notification_service.dart';
import '../util/popup_utils.dart';
import '../widgets/QuestionCard.dart';
import '../widgets/button/add_new_button.dart';
import '../widgets/notification_card.dart';
import 'auth_screen.dart';
import 'create_question_screen.dart';

// --- SNACKBAR MODERNA ---
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

class UserDashboardScreen extends StatefulWidget {
  final String token;

  UserDashboardScreen({required this.token});

  @override
  _UserDashboardScreenState createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen> {
  final QuestionService _questionService = QuestionService();
  final NotificationService _notificationService = NotificationService();
  late String username;
  List<notify.Notification> _unreadNotifications = [];
  bool isLoading = false;
  List<QuestionDTO> _allQuestions = []; // Lista completa delle domande
  List<QuestionDTO> _filteredQuestions = []; // Lista filtrata
  String _searchQuery = "";
  DateTime? _startDate;
  DateTime? _endDate;
  String _activeFilter = ''; // Nessun filtro attivo di default
  String? _hoveredFilter;

  @override
  void initState() {
    super.initState();
    _decodeToken();
    _fetchUnreadNotifications();
    _fetchUserQuestions(); // Recupero delle domande dell'utente
  }

  void _decodeToken() {
    try {
      final jwt = JWT.decode(widget.token);
      setState(() {
        username = jwt.payload['sub'] ?? 'Utente';
      });

      final exp = jwt.payload['exp'] as int?;
      if (exp != null &&
          DateTime.now().millisecondsSinceEpoch / 1000 > exp) {
        throw 'Token scaduto';
      }
    } catch (e) {
      debugPrint('Errore nella decodifica del token: $e');
      setState(() {
        username = 'Utente';
      });
      _logout();
    }
  }

  Future<void> _fetchUnreadNotifications() async {
    try {
      final notifications = await _notificationService.getUnreadNotifications(
        username,
        widget.token,
      );
      setState(() {
        _unreadNotifications = notifications;
      });
    } catch (error) {
      debugPrint('Errore nel recupero delle notifiche: $error');
    }
  }

  Future<void> _fetchUserQuestions() async {
    setState(() {
      isLoading = true;
    });
    try {
      final questions = await _questionService.getUserQuestions(widget.token);
      final sortedQuestions = List<QuestionDTO>.from(questions)
        ..sort((a, b) => b.publishDate.compareTo(a.publishDate));
      setState(() {
        _allQuestions = sortedQuestions; // Memorizza tutte le domande ordinate
        _filteredQuestions = _allQuestions; // Inizia mostrando tutte le domande
      });
    } catch (error) {
      debugPrint('Errore nel recupero delle domande: $error');
      await PopupUtils.showCenterPopup(context, 'Errore nel recupero delle domande.', isError: true);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _logout() async {
    try {
      // Elimina il token da SharedPreferences invece che da FlutterSecureStorage
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('jwt_token');

      // Naviga alla schermata di autenticazione
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => AuthScreen()),
        (route) => false, // Rimuove tutte le pagine dalla navigazione
      );
    } catch (error) {
      debugPrint('Errore durante il logout: $error');
      await PopupUtils.showCenterPopup(context, 'Errore durante il logout.', isError: true);
    }
  }


  void _showNotificationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFFD8EAF5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          title: Text(
            'Notifiche',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF003366),
            ),
          ),
          content: StatefulBuilder(
            builder: (context, setStateDialog) {
              return Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.6,
                child: _unreadNotifications.isEmpty
                    ? Center(
                        child: Text(
                          'Nessuna notifica disponibile.',
                          style: TextStyle(
                            color: Color(0xFF003366),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _unreadNotifications.length,
                        itemBuilder: (context, index) {
                          final notification = _unreadNotifications[index];
                          return Dismissible(
                            key: Key(notification.id.toString()),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Icon(Icons.delete, color: Colors.white),
                            ),
                            onDismissed: (direction) async {
                              try {
                                await _notificationService.markNotificationAsRead(
                                    notification.id, widget.token);
                                setState(() {
                                  _unreadNotifications.remove(notification);
                                });
                                setStateDialog(() {});
                                //await PopupUtils.showCenterPopup(context, 'Notifica segnata come letta.');
                              } catch (e) {
                                await PopupUtils.showCenterPopup(context, 'Si è verificato un errore.', isError: true);
                              }
                            },
                            child: NotificationCard(
                              notification: notification,
                              // Dentro il builder di StatefulBuilder nella dialog delle notifiche
                              onMarkAsRead: () async {
                                try {
                                  await _notificationService.markNotificationAsRead(
                                      notification.id, widget.token);
                                  setState(() {
                                    _unreadNotifications.remove(notification);
                                  });
                                  setStateDialog(() {});
                                 // await PopupUtils.showCenterPopup(context, 'Notifica segnata come letta.');
                                } catch (e) {
                                  await PopupUtils.showCenterPopup(context, 'Si è verificato un errore.', isError: true);
                                }
                              },
                            ),
                          );
                        },
                      ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Chiudi',
                style: TextStyle(
                  color: Color(0xFF003366),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _filterQuestionsBySearchQuery(String query) {
    setState(() {
      _filteredQuestions = _allQuestions.where((question) {
        return question.title.toLowerCase().contains(query.toLowerCase());
      }).toList()
        ..sort((a, b) => b.publishDate.compareTo(a.publishDate));
    });
  }

  void _filterQuestionsByDateRange() {
    setState(() {
      _filteredQuestions = _allQuestions.where((question) {
        final publishDate = question.publishDate; // Assumendo che sia di tipo DateTime
        if (_startDate != null && publishDate.isBefore(_startDate!)) {
          return false;
        }
        if (_endDate != null &&
            publishDate.isAfter(
                _endDate!.add(Duration(days: 1)).subtract(Duration(seconds: 1)))) {
          return false;
        }
        return true;
      }).toList()
        ..sort((a, b) => b.publishDate.compareTo(a.publishDate));
    });
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _filterQuestionsByDateRange();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF30344C),
        toolbarHeight: 56,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Dashboard $username',
              style: TextStyle(color: Colors.white),
            ),
            Container(
              height: 40,
              alignment: Alignment.center,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Tooltip(
                    message: 'Nuova domanda',
                    child: Semantics(
                      label: 'Aggiungi nuova domanda',
                      button: true,
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: AddNewButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    CreateQuestionScreen(token: widget.token),
                              ),
                            ).then((_) => _fetchUserQuestions());
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Semantics(
                        label: 'Notifiche',
                        button: true,
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: IconButton(
                            icon: Icon(Icons.notifications, semanticLabel: 'Notifiche'),
                            onPressed: () {
                              _showNotificationDialog(context);
                            },
                          ),
                        ),
                      ),
                      if (_unreadNotifications.isNotEmpty)
                        Positioned(
                          top: -2,
                          right: 4,
                          child: Semantics(
                            label: 'Hai nuove notifiche',
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: Center(
                                child: Text(
                                  _unreadNotifications.length > 9
                                      ? '9+'
                                      : _unreadNotifications.length.toString(),
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  Semantics(
                    label: 'Logout',
                    button: true,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: IconButton(
                        icon: Icon(Icons.logout, semanticLabel: 'Logout'),
                        onPressed: _logout,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF5F7FA), // sfumatura soft chiara in alto
              Color(0xFFE9ECF3), // sfumatura soft intermedia
              Color(0xFFDDE3ED), // sfumatura soft più scura in basso
            ],
          ),
        ),
        child: Column(
          children: [
            Container(
              color: Color(0xFFEFEFEF), // Sfondo della barra di ricerca
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 600),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: TextField(
                              decoration: InputDecoration(
                                labelText: 'Cerca nei titoli',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide:
                                      BorderSide(color: Colors.grey, width: 1),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide:
                                      BorderSide(color: Colors.grey, width: 1),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide:
                                      BorderSide(color: Colors.blue, width: 1),
                                ),
                                prefixIcon: Padding(
                                  padding:
                                      const EdgeInsets.only(left: 8, right: 8),
                                  child: Icon(Icons.search,
                                      color: Colors.grey[700]),
                                ),
                                prefixIconConstraints:
                                    BoxConstraints(minWidth: 40, minHeight: 40),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 0),
                              ),
                              onChanged: (value) {
                                _searchQuery = value;
                                _filterQuestionsBySearchQuery(_searchQuery);
                              },
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            flex: 1,
                            child: Tooltip(
                              message: 'Seleziona intervallo di date',
                              child: ElevatedButton(
                                onPressed: () => _selectDateRange(context),
                                style: ElevatedButton.styleFrom(
                                  shape: CircleBorder(),
                                  padding: EdgeInsets.all(16),
                                  backgroundColor: Colors.orange,
                                ),
                                child: Icon(Icons.calendar_today,
                                    size: 24, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildFilterButton(
                              'In attesa',
                              'WAITING_FOR_ANSWER',
                              Colors.orange,
                              _activeFilter == 'WAITING_FOR_ANSWER'),
                          _buildFilterButton(
                              'Risolte',
                              'ANSWER_PROVIDED',
                              Colors.greenAccent,
                              _activeFilter == 'ANSWER_PROVIDED'),
                          _buildFilterButton(
                              'Scadute',
                              'EXPIRED_NO_ANSWER',
                              Colors.redAccent,
                              _activeFilter == 'EXPIRED_NO_ANSWER'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: isLoading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 12),
                          Text('Caricamento domande...',
                              style: TextStyle(color: Colors.grey[700])),
                        ],
                      ),
                    )
                  : _filteredQuestions.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.info_outline,
                                  color: Colors.blueGrey, size: 48),
                              SizedBox(height: 8),
                              Text('Nessuna domanda trovata.',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.blueGrey)),
                            ],
                          ),
                        )
                      : AnimatedOpacity(
                          opacity: 1.0,
                          duration: Duration(milliseconds: 400),
                          child: ListView.builder(
                            itemCount: _filteredQuestions.length,
                            itemBuilder: (context, index) {
                              final question = _filteredQuestions[index];
                              return Container(
                                margin: EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 16.0),
                                padding: EdgeInsets.all(16.0),
                                decoration: BoxDecoration(
                                  color: Color(0xFFE0E0E0), // Sfondo delle card
                                  borderRadius: BorderRadius.circular(8.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.10), // shadow più morbida
                                      blurRadius: 8.0,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: QuestionCard(
                                  question: question,
                                  token: widget.token,
                                  onTap: () {
                                    print(
                                        'Domanda selezionata: ${question.id}');
                                  },
                                  isAuthenticated: true,
                                  onEditTap: () {
                                    print('Modifica domanda: ${question.id}');
                                  },
                                  onUpdate: _fetchUserQuestions,
                                ),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton(
      String label, String status, Color color, bool isActive) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hoveredFilter = status),
      onExit: (_) => setState(() => _hoveredFilter = null),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 120),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isActive
              ? color.withOpacity(0.90)
              : (_hoveredFilter == status
                  ? color.withOpacity(0.15)
                  : Colors.grey[200]),
          borderRadius: BorderRadius.circular(32),
          border: isActive
              ? Border.all(color: _darken(color, 0.15), width: 2.5)
              : Border.all(color: Colors.transparent, width: 2),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.35),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ]
              : (_hoveredFilter == status
                  ? [
                      BoxShadow(
                        color: color.withOpacity(0.18),
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ]
                  : []),
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: isActive ? Colors.white : Colors.black,
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 28),
            minimumSize: Size(0, 44),
            shape: StadiumBorder(),
            side: BorderSide.none,
          ),
          onPressed: () {
            setState(() {
              if (_activeFilter == status) {
                // Se il filtro è già attivo, deselezionalo e mostra tutte le domande
                _activeFilter = '';
                _filteredQuestions = _allQuestions;
              } else {
                _activeFilter = status;
                _filteredQuestions =
                    QuestionService.filterQuestionsByStatus(_allQuestions, status)
                      ..sort((a, b) => b.publishDate.compareTo(a.publishDate));
              }
            });
          },
          child: Text(label, style: TextStyle(fontSize: 16)),
        ),
      ),
    );
  }

  Color _darken(Color color, [double amount = .1]) {
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}
