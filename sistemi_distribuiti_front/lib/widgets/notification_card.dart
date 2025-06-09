import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../model/Notification.dart' as notify;
import '../util/popup_utils.dart';


class NotificationCard extends StatefulWidget {
  final notify.Notification notification;
  final VoidCallback onMarkAsRead;

  NotificationCard({
    required this.notification,
    required this.onMarkAsRead,
  });

  @override
  _NotificationCardState createState() => _NotificationCardState();
}

class _NotificationCardState extends State<NotificationCard> {
  bool isLoading = false;

  void _markAsRead() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Se onMarkAsRead è asincrona, attendi la sua esecuzione
      final result = widget.onMarkAsRead();

      // Se usi un popup custom (es. showCenterPopup), assicurati di attendere la sua chiusura:
      // await showCenterPopup(context, ...);
      // Navigator.pop(context); // solo se necessario e se il popup non si chiude da solo
    } catch (e) {
      await PopupUtils.showCenterPopup(
        context,
        'Impossibile segnare la notifica come letta. Riprova più tardi.',
        isError: true,
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  String formatDateTime(DateTime dateTime) {
    final DateFormat formatter = DateFormat('dd MMMM yyyy, HH:mm');
    return formatter.format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final createdAt = formatDateTime(widget.notification.createdAt);

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Color(0xFF30344C), // Colore dello sfondo come QuestionCard
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Testo della notifica
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.notification.message,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Ricevuta il $createdAt',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          // Pulsante per segnare come letta con icona di caricamento
          isLoading
              ? CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                )
              : IconButton(
                  icon: Icon(Icons.check, color: Colors.green),
                  onPressed: _markAsRead,
                ),
        ],
      ),
    );
  }
}
