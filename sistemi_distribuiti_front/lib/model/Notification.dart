class Notification {
  final int id;
  final String username; // Aggiunto il campo username
  final String message;
  final DateTime createdAt;
  final bool read;

  Notification({
    required this.id,
    required this.username, // Aggiungi qui
    required this.message,
    required this.createdAt,
    required this.read,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    final createdAtArray = json['createdAt'];
    DateTime createdAt;

    if (createdAtArray is List && createdAtArray.length >= 6) {
      createdAt = DateTime(
        createdAtArray[0],
        createdAtArray[1],
        createdAtArray[2],
        createdAtArray[3],
        createdAtArray[4],
        createdAtArray[5],
      );
    } else {
      throw FormatException('Formato non valido per createdAt');
    }

    return Notification(
      id: json['id'],
      username: json['username'], // Parsing del campo username
      message: json['message'],
      createdAt: createdAt,
      read: json['read'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'message': message,
    'createdAt': createdAt.toIso8601String(),
    'read': read,
  };
}
