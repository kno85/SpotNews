// main.dart
// Este es el archivo principal de tu aplicación Flutter.
// Ubícalo en: lib/main.dart

import 'package:flutter/material.dart';
// Importa las librerías necesarias
// Necesario para hacer peticiones HTTP (descargar el RSS)
import 'package:spotnews/screens/home_screen.dart';
import 'package:spotnews/services/text_to_speech_service.dart';
// Necesario para parsear el contenido XML del RSS
// Necesario para la funcionalidad Text-to-Speech

void main() async {
  // Asegura que los widgets de Flutter estén inicializados antes de usar servicios de plataforma
  WidgetsFlutterBinding.ensureInitialized();
  // Inicializa el servicio de Text-to-Speech al iniciar la aplicación
  await TextToSpeechService.initTts();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'El País RSS Reader',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blueGrey,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
        cardTheme: CardThemeData(
          // <-- CORRECCIÓN: Cambiado de CardTheme a CardThemeData
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          elevation: 4.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        listTileTheme: ListTileThemeData(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 8.0,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
