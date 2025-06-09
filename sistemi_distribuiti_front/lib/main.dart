import 'package:flutter/material.dart';
import 'package:sistemi_distribuiti_front/screens/auth_screen.dart';
import 'package:sistemi_distribuiti_front/screens/splash_screen.dart';
import 'package:sistemi_distribuiti_front/widgets/custom_theme.dart';
import 'widgets/custom_snackbar.dart';

void main() {

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Piattaforma Domande&Risposte',
      theme: CustomTheme.themeData,
      initialRoute: '/splash', //pagina iniziale
      routes: {
        '/splash': (context) => SplashScreen(),
        '/login': (context) => AuthScreen(), // Schermata di autenticazione
      },
    );
  }
}

// Esempio di utilizzo in una callback o evento:
void exampleCallback(BuildContext context) {
  CustomSnackbar.show(
    context,
    message: "Domanda riproposta!",
    type: SnackbarType.success,
  );
}
