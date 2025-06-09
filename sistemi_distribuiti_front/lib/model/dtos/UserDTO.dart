class UserDTO {
  final int id;
  final String username;
  final String email;
  final String role;

  UserDTO({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
  });

  // Metodo per creare un oggetto UserDTO da JSON
  factory UserDTO.fromJson(Map<String, dynamic> json) {
    return UserDTO(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      role: json['role'],
    );
  }
}
