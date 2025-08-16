import 'package:flutter/material.dart';
import 'package:spotnews/models/rss_item.dart';
import 'package:spotnews/services/rss_parser_service.dart';

// lib/screens/article_detail_screen.dart
// Este archivo contiene la pantalla de detalle para un artículo de noticias.
// Ubícalo en: lib/screens/article_detail_screen.dart

class ArticleDetailScreen extends StatefulWidget {
  final RssItem article; // El artículo a mostrar en detalle

  const ArticleDetailScreen({super.key, required this.article});

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  static const String _corsProxyUrl =
      'https://corsproxy.io/?'; // Un proxy CORS público

  // Función para obtener la URL de la imagen con el proxy CORS si es necesario.
  // Se ha modificado para devolver null si la URL apunta a un archivo de video.
  String? _getImageUrlWithProxy(String originalUrl) {
    final videoExtensions = ['.mp4', '.mov', '.avi', '.wmv', '.flv', '.webm'];

    if (videoExtensions.any((ext) => originalUrl.toLowerCase().endsWith(ext))) {
      return null;
    }
    if (originalUrl.toLowerCase().contains('/video/')) {
      return null;
    }

    if (ThemeData().platform == TargetPlatform.android ||
        ThemeData().platform == TargetPlatform.iOS) {
      return originalUrl;
    } else {
      return _corsProxyUrl + Uri.encodeComponent(originalUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayImageUrl = widget.article.imageUrl != null
        ? _getImageUrlWithProxy(widget.article.imageUrl!)
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.article.title.length > 30
              ? '${widget.article.title.substring(0, 30)}...'
              : widget.article.title,
        ), // Título en la AppBar, recortado si es muy largo
        actions: [
          // Botón para detener la reproducción de TTS desde la vista de detalle
          IconButton(
            icon: const Icon(Icons.stop),
            onPressed: TextToSpeechService.stop,
            tooltip: 'Detener audio',
          ),
        ],
      ),
      body: SingleChildScrollView(
        // Permite hacer scroll si el contenido es largo
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen del artículo
            if (displayImageUrl != null && displayImageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Image.network(
                  displayImageUrl,
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 150,
                      color: Colors.grey[200],
                      alignment:
                          Alignment.center, // Centra el contenido del Container
                      child: const Column(
                        // <-- CORRECCIÓN: Envuelto en Column
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.broken_image,
                            size: 50,
                            color: Colors.grey,
                          ),
                          SizedBox(
                            height: 4,
                          ), // Pequeño espacio entre icono y texto
                          Text(
                            'No se pudo cargar la imagen',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 20.0),

            // Título completo del artículo
            Text(
              widget.article.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24.0,
              ),
            ),
            const SizedBox(height: 10.0),

            // Fecha de publicación
            if (widget.article.pubDate != null)
              Text(
                'Publicado: ${widget.article.pubDate!}',
                style: TextStyle(fontSize: 14.0, color: Colors.grey[600]),
              ),
            const SizedBox(height: 20.0),

            // Botón para leer la descripción (TTS)
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  TextToSpeechService.speak(widget.article.description);
                },
                icon: const Icon(Icons.volume_up),
                label: const Text('Leer Noticia'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
            ),
            const SizedBox(height: 20.0),

            // Contenido de la descripción (texto del artículo para leer visualmente)
            Text(
              widget.article.description,
              style: const TextStyle(fontSize: 16.0, height: 1.5),
            ),
            const SizedBox(height: 20.0),

            // Botón para ir al enlace original (si se desea abrir en navegador)
            Align(
              alignment: Alignment.center,
              child: TextButton.icon(
                icon: const Icon(Icons.open_in_new),
                label: const Text('Ver artículo original'),
                onPressed: () {
                  // Para abrir el enlace en un navegador, necesitarías el paquete 'url_launcher'.
                  // 1. Añade 'url_launcher: ^6.2.2' (o la última versión) a pubspec.yaml
                  // 2. Importa: import 'package:url_launcher/url_launcher.dart';
                  // 3. Descomenta la siguiente línea:
                  // launchUrl(Uri.parse(widget.article.link));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
