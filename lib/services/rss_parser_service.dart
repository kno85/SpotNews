// lib/services/rss_parser_service.dart
// Este archivo contiene la lógica para descargar y parsear el feed RSS.
// Ubícalo en: lib/services/rss_parser_service.dart

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:spotnews/models/rss_item.dart';
import 'package:xml/xml.dart';
// lib/services/rss_parser_service.dart
// Este archivo contiene la lógica para descargar y parsear el feed RSS.
// Ubícalo en: lib/services/rss_parser_service.dart

import 'dart:convert'; // Importa esta librería para la decodificación de caracteres

class RssParserService {
  // URL del feed RSS de El País para la portada
  // Se usa un proxy CORS para las compilaciones web para evitar problemas de CORS.
  // Para compilaciones nativas (Android/iOS), el proxy no es estrictamente necesario,
  // pero el paquete http lo maneja sin problema.
  static const String _baseFeedUrl =
      'https://feeds.elpais.com/mrss-s/pages/ep/site/elpais.com/portada';
  static const String _corsProxyUrl =
      'https://corsproxy.io/?'; // Un proxy CORS público

  static String get _feedUrl {
    // Para plataformas nativas (Android/iOS), se usa la URL directa.
    // Para la web, se concatena con el proxy CORS.
    // Usamos kIsWeb para determinar la plataforma de forma más robusta.
    // Asegúrate de importar 'package:flutter/foundation.dart' si usas kIsWeb
    // Para simplificar aquí, se usa una comprobación básica, pero kIsWeb es más preciso.
    if (ThemeData().platform == TargetPlatform.android ||
        ThemeData().platform == TargetPlatform.iOS) {
      return _baseFeedUrl;
    } else {
      return _corsProxyUrl + Uri.encodeComponent(_baseFeedUrl);
    }
  }

  // Función asíncrona para obtener y parsear el feed RSS
  static Future<List<RssItem>> fetchAndParseRss() async {
    try {
      // Realiza una petición GET a la URL del feed RSS
      final response = await http.get(Uri.parse(_feedUrl));

      if (response.statusCode == 200) {
        // DECodifica explícitamente el cuerpo de la respuesta como UTF-8
        // Esto es crucial para asegurar que los caracteres especiales se interpreten correctamente.
        final String xmlString = utf8.decode(response.bodyBytes);
        final document = XmlDocument.parse(xmlString); // Parsea la cadena XML

        final items = <RssItem>[]; // Lista para almacenar los objetos RssItem

        // Función auxiliar para decodificar entidades HTML comunes en español
        String _decodeHtmlEntities(String text) {
          return text
              .replaceAll('&#x27;', "'")
              .replaceAll('&quot;', '"')
              .replaceAll('&amp;', '&')
              .replaceAll('&lt;', '<')
              .replaceAll('&gt;', '>')
              // Añade entidades HTML para caracteres españoles si el feed las usa
              .replaceAll('&aacute;', 'á')
              .replaceAll('&eacute;', 'é')
              .replaceAll('&iacute;', 'í')
              .replaceAll('&oacute;', 'ó')
              .replaceAll('&uacute;', 'ú')
              .replaceAll('&ntilde;', 'ñ')
              .replaceAll('&Aacute;', 'Á')
              .replaceAll('&Eacute;', 'É')
              .replaceAll('&Iacute;', 'Í')
              .replaceAll('&Oacute;', 'Ó')
              .replaceAll('&Uacute;', 'Ú')
              .replaceAll('&Ntilde;', 'Ñ')
              .replaceAll('&uuml;', 'ü')
              .replaceAll('&Uuml;', 'Ü')
              .replaceAll('&ordf;', 'ª') // Femenino ordinal
              .replaceAll('&ordm;', 'º'); // Masculino ordinal
        }

        // Busca todos los elementos '<item>' en el documento XML.
        // En un feed RSS, cada noticia individual está contenida en una etiqueta <item>.
        for (var itemNode in document.findAllElements('item')) {
          // Extrae el texto y aplica la decodificación de entidades
          final title = _decodeHtmlEntities(
            itemNode.findElements('title').firstOrNull?.innerText ??
                'Sin título',
          );
          final link =
              itemNode.findElements('link').firstOrNull?.innerText ??
              'Sin enlace';
          final description = _decodeHtmlEntities(
            itemNode.findElements('description').firstOrNull?.innerText ??
                'Sin descripción',
          );
          final pubDate = itemNode
              .findElements('pubDate')
              .firstOrNull
              ?.innerText;

          // Intenta encontrar la URL de la imagen. Los feeds de El País usan 'media:content' o 'media:thumbnail'.
          String? imageUrl;
          final mediaContent = itemNode
              .findElements('media:content')
              .firstOrNull;
          if (mediaContent != null) {
            imageUrl = mediaContent.getAttribute(
              'url',
            ); // Obtiene el atributo 'url'
          } else {
            final mediaThumbnail = itemNode
                .findElements('media:thumbnail')
                .firstOrNull;
            imageUrl = mediaThumbnail?.getAttribute('url');
          }

          // Crea un nuevo objeto RssItem con los datos extraídos y lo añade a la lista
          items.add(
            RssItem(
              title: title,
              link: link,
              description: description,
              pubDate: pubDate,
              imageUrl: imageUrl,
            ),
          );
        }
        return items; // Devuelve la lista de RssItem
      } else {
        // Lanza una excepción si la respuesta HTTP no es exitosa
        throw Exception('Error al cargar el feed RSS: ${response.statusCode}');
      }
    } catch (e) {
      // Captura cualquier error que ocurra durante la petición o el parseo
      throw Exception('Error en la operación del feed RSS: $e');
    }
  }
}

// lib/services/text_to_speech_service.dart
// Este archivo maneja la funcionalidad de Text-to-Speech (TTS).
// Ubícalo en: lib/services/text_to_speech_service.dart

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
