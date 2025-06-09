import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sistemi_distribuiti_front/constants/api_constants.dart';
import '../services/auth_service.dart';
import '../services/password_reset_service.dart';
import '../util/popup_utils.dart';
import '../widgets/PatternBackground.dart';
import 'employee_dashboard_screen.dart';
import 'user_dashboard_screen.dart';
import 'package:jwt_decode/jwt_decode.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  final PasswordResetService _passwordResetService = PasswordResetService(ApiConstants.baseUrl);
  SharedPreferences? prefs;

  bool isLogin = true;
  bool isEmployee = false;
  String email = '';
  String password = '';
  String confirmPassword = '';
  String username = '';
  bool isLoading = false;

  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();
  final FocusNode _usernameFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    _checkAuthentication();
  }

  @override
  void dispose() {
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    _usernameFocusNode.dispose();
    super.dispose();
  }

  // Funzione per aprire il popup del reset password
  void _showResetPasswordDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String email = '';
        String newPassword = '';
        String? token;
        bool isTokenStep = false;

        return StatefulBuilder(
          builder: (context, setState) {
            final TextEditingController newPasswordController = TextEditingController();
            return AlertDialog(
              title: Text('Reimposta Password'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isTokenStep)
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Inserisci la tua email',
                        prefixIcon: Icon(Icons.email),
                      ),
                      onChanged: (value) => email = value,
                    ),
                  if (isTokenStep)
                    TextField(
                      controller: newPasswordController,
                      decoration: InputDecoration(
                        labelText: 'Nuova password',
                        prefixIcon: Icon(Icons.lock),
                      ),
                      obscureText: true,
                      onChanged: (value) => newPassword = value,
                    ),
                ],
              ),
              actions: [
                if (!isTokenStep)
                  TextButton(
                    onPressed: () async {
                      try {
                        token = await _passwordResetService.requestPasswordReset(email);
                        if (token != null) {
                          setState(() {
                            isTokenStep = true;
                            newPasswordController.clear();
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Token ricevuto e memorizzato!')),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Errore: impossibile ottenere il token')),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Errore: $e')),
                        );
                      }
                    },
                    child: Text('Richiedi Reset'),
                  ),
                if (isTokenStep)
                  TextButton(
                    onPressed: () async {
                      if (token == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Token non disponibile')),
                        );
                        return;
                      }

                      try {
                        await _passwordResetService.resetPassword(token!, newPassword);
                        Navigator.pop(context);
                        await PopupUtils.showCenterPopup(
                          context,
                          'La tua password è stata reimpostata con successo.',
                        );
                        await Future.delayed(Duration(seconds: 1));
                        Navigator.of(context, rootNavigator: true).pop();
                      } catch (e) {
                        await PopupUtils.showCenterPopup(
                          context,
                          'Si è verificato un errore durante la reimpostazione della password: $e',
                          isError: true,
                        );
                      }
                    },
                    child: Text('Reimposta Password'),
                  ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Chiudi'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _checkAuthentication() async {
    if (prefs == null) return;
    final token = prefs!.getString('jwt_token');
    if (token != null && _authService.isTokenValid(token)) {
      Map<String, dynamic> payload = Jwt.parseJwt(token);
      final role = payload['role'];

      setState(() {
        isEmployee = role == 'EMPLOYEE';
      });

      if (isEmployee) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => EmployeeDashboardScreen(
              token: token,
              email: email,
            ),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => UserDashboardScreen(
              token: token,
            ),
          ),
        );
      }
    }
  }

  void submit() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();

    setState(() {
      isLoading = true;
    });

    try {
      if (isLogin) {
        final response = await _authService.login(email, password);

        if (response != null) {
          final token = response['token'];
          Map<String, dynamic> payload = Jwt.parseJwt(token);
          final role = payload['role'];

          await prefs?.setString('jwt_token', token);

          setState(() {
            isEmployee = role == 'EMPLOYEE';
          });

          if (isEmployee) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => EmployeeDashboardScreen(
                  token: token,
                  email: email,
                ),
              ),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => UserDashboardScreen(
                  token: token,
                ),
              ),
            );
          }
        } else {
          _showError('Login fallito. Controlla le credenziali.');
        }
      } else {
        if (password != confirmPassword) {
          _showError('Le password non corrispondono.');
          return;
        }

        bool success = await _authService.signup(email, password, username);
        if (success) {
          setState(() {
            isLogin = true;
          });
          await PopupUtils.showCenterPopup(
            context,
            'Registrazione completata con successo! Ora puoi effettuare il login.',
          );
        } else {
          _showError('Registrazione fallita.');
        }
      }
    } catch (error) {
      _showError('Si è verificato un errore. Riprova più tardi.');
    } finally {
      setState(() {
        isLoading = false;
      });
      password = '';
      confirmPassword = '';
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Errore'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PatternBackground(
        child: Center(
          child: Container(
            width: 340,
            padding: EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.10),
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Titolo dinamico
                  Text(
                    isEmployee
                        ? 'Login Dipendente'
                        : 'Login Utente',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                      letterSpacing: 1.1,
                    ),
                  ),
                  SizedBox(height: 18),
                  // Switch centrato tra Utente e Dipendente
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Utente',
                        style: TextStyle(
                          color: !isEmployee ? Colors.blue[800] : Colors.grey[500],
                          fontWeight: !isEmployee ? FontWeight.bold : FontWeight.normal,
                          fontSize: 15,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              isEmployee = !isEmployee;
                              isLogin = true;
                              // Reset campi quando si cambia ruolo
                              email = '';
                              password = '';
                              confirmPassword = '';
                              username = '';
                              _formKey.currentState?.reset();
                            });
                          },
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 200),
                            width: 54,
                            height: 30,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: isEmployee ? Colors.blue[400] : Colors.grey[300],
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                AnimatedAlign(
                                  duration: Duration(milliseconds: 200),
                                  alignment: isEmployee ? Alignment.centerRight : Alignment.centerLeft,
                                  child: Container(
                                    width: 26,
                                    height: 26,
                                    margin: EdgeInsets.symmetric(horizontal: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Text(
                        'Dipendente',
                        style: TextStyle(
                          color: isEmployee ? Colors.blue[800] : Colors.grey[500],
                          fontWeight: isEmployee ? FontWeight.bold : FontWeight.normal,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 22),
                  _buildTextField(
                    label: 'Email',
                    icon: Icons.email_outlined,
                    focusNode: _emailFocusNode,
                    onSaved: (value) => email = value!,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Inserisci un\'email valida.';
                      } else if (!_authService.isValidEmailFormat(value)) {
                        return 'Formato email non corretto';
                      }
                      return null;
                    },
                    // Aggiungi initialValue per resettare il campo
                    initialValue: email,
                  ),
                  if (!isLogin && !isEmployee)
                    _buildTextField(
                      label: 'Username',
                      icon: Icons.person_outline,
                      focusNode: _usernameFocusNode,
                      onSaved: (value) => username = value!,
                      initialValue: username,
                    ),
                  _buildTextField(
                    label: 'Password',
                    icon: Icons.lock_outline,
                    focusNode: _passwordFocusNode,
                    onSaved: (value) => password = value!,
                    obscureText: true,
                    initialValue: password,
                  ),
                  if (!isLogin && !isEmployee)
                    _buildTextField(
                      label: 'Conferma Password',
                      icon: Icons.lock_reset,
                      focusNode: _confirmPasswordFocusNode,
                      onSaved: (value) => confirmPassword = value!,
                      obscureText: true,
                      initialValue: confirmPassword,
                    ),
                  SizedBox(height: 18),
                  ElevatedButton(
                    onPressed: submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 38, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      elevation: 4,
                      textStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 1.1,
                      ),
                    ),
                    child: isLoading
                        ? SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(isLogin ? 'Login' : 'Registrati'),
                  ),
                  if (!isEmployee)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          isLogin = !isLogin;
                          // Reset campi quando si cambia modalità login/registrazione
                          email = '';
                          password = '';
                          confirmPassword = '';
                          username = '';
                          _formKey.currentState?.reset();
                        });
                      },
                      child: Text(
                        isLogin
                            ? 'Crea un nuovo account'
                            : 'Hai già un account? Login',
                        style: TextStyle(
                          color: Colors.blue[800],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  TextButton(
                    onPressed: _showResetPasswordDialog,
                    child: Text(
                      'Hai dimenticato la password?',
                      style: TextStyle(
                        color: Colors.blue[600],
                        fontWeight: FontWeight.w400,
                      ),
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

  Widget _buildTextField({
    required String label,
    required IconData icon,
    required FocusNode focusNode,
    required FormFieldSetter<String> onSaved,
    FormFieldValidator<String>? validator,
    bool obscureText = false,
    String? initialValue,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        focusNode: focusNode,
        initialValue: initialValue ?? '',
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.grey[800],
            fontWeight: FontWeight.w500,
            fontSize: 15,
            letterSpacing: 0.2,
          ),
          prefixIcon: Icon(icon, color: Colors.blue[700]),
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.blueGrey.shade100, width: 1.2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.blueGrey.shade100, width: 1.2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.blue[400]!, width: 1.7),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 18),
          hintText: label,
          hintStyle: TextStyle(
            color: Colors.grey[400],
            fontWeight: FontWeight.w400,
            fontSize: 14,
          ),
        ),
        style: TextStyle(
          color: Colors.grey[900],
          fontWeight: FontWeight.w500,
          fontSize: 15.5,
        ),
        obscureText: obscureText,
        validator: validator,
        onSaved: onSaved,
      ),
    );
  }
}
