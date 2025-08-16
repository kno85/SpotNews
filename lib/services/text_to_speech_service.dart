// lib/services/text_to_speech_service.dart
// Este archivo maneja la funcionalidad de Text-to-Speech (TTS).
// Ubícalo en: lib/services/text_to_speech_service.dart

import 'package:flutter_tts/flutter_tts.dart';

class TextToSpeechService {
  static final FlutterTts flutterTts = FlutterTts(); // Instancia de FlutterTts

  // Inicializa la configuración de Text-to-Speech.
  // Debe ser llamado antes de usar 'speak'.
  static Future<void> initTts() async {
    // Establece el idioma del TTS a español de España.
    await flutterTts.setLanguage("es-ES");
    // Ajusta la velocidad de habla (0.5 es un buen punto de partida, 1.0 es normal).
    await flutterTts.setSpeechRate(0.5);
    // Establece el volumen (1.0 es el máximo).
    await flutterTts.setVolume(1.0);
    // Establece el tono (1.0 es el normal).
    await flutterTts.setPitch(1.0);
  }

  // Reproduce el texto proporcionado usando TTS.
  static Future<void> speak(String text) async {
    if (text.isNotEmpty) {
      await flutterTts.speak(text); // Inicia la reproducción del texto
    }
  }

  // Detiene cualquier reproducción de audio TTS que esté en curso.
  static Future<void> stop() async {
    await flutterTts.stop();
  }
}
