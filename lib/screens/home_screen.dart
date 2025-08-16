import 'package:flutter/material.dart';
import 'package:spotnews/models/rss_item.dart';
import 'package:spotnews/services/rss_parser_service.dart';
// lib/screens/home_screen.dart
// Este archivo construye la interfaz de usuario para mostrar la lista de noticias.
// Ubícalo en: lib/screens/home_screen.dart

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<RssItem>>
  _rssItemsFuture; // Futuro que contendrá la lista de ítems RSS
  bool _isLoading =
      false; // Bandera para controlar si se está cargando (para el CircularProgressIndicator)
  static const String _corsProxyUrl =
      'https://corsproxy.io/?'; // Un proxy CORS público

  @override
  void initState() {
    super.initState();
    _loadRssItems(); // Carga inicial de los ítems RSS al iniciar la pantalla
  }

  // Función para cargar los ítems RSS y actualizar el estado de la UI
  Future<void> _loadRssItems() async {
    setState(() {
      _isLoading =
          true; // Establece el estado de carga a verdadero para mostrar el indicador
    });
    try {
      _rssItemsFuture =
          RssParserService.fetchAndParseRss(); // Llama al servicio para obtener los datos
      // Espera a que el futuro se complete. Esto es importante para capturar errores
      // y para saber cuándo se debe ocultar el indicador de carga.
      await _rssItemsFuture;
    } catch (e) {
      // Muestra un SnackBar si ocurre un error durante la carga de noticias
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al cargar noticias: $e')));
    } finally {
      setState(() {
        _isLoading =
            false; // Oculta el indicador de carga una vez que la operación finaliza
      });
    }
  }

  // Función para obtener la URL de la imagen con el proxy CORS si es necesario.
  // Se ha modificado para devolver null si la URL apunta a un archivo de video.
  String? _getImageUrlWithProxy(String originalUrl) {
    // Lista de extensiones de video comunes a evitar
    final videoExtensions = ['.mp4', '.mov', '.avi', '.wmv', '.flv', '.webm'];

    // Comprueba si la URL termina con alguna de las extensiones de video
    if (videoExtensions.any((ext) => originalUrl.toLowerCase().endsWith(ext))) {
      return null; // Devuelve null si es una URL de video
    }

    // También se puede añadir una comprobación más general si la URL contiene "/video/"
    if (originalUrl.toLowerCase().contains('/video/')) {
      return null;
    }

    // Si la plataforma es web, prefiere usar el proxy CORS
    if (ThemeData().platform == TargetPlatform.android ||
        ThemeData().platform == TargetPlatform.iOS) {
      return originalUrl;
    } else {
      return _corsProxyUrl + Uri.encodeComponent(originalUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('El País Noticias'),
        actions: [
          // Botón para recargar el feed RSS manualmente
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRssItems,
            tooltip: 'Recargar noticias', // Texto de ayuda
          ),
          // Botón para detener la reproducción de TTS
          IconButton(
            icon: const Icon(Icons.stop),
            onPressed: TextToSpeechService.stop,
            tooltip: 'Detener audio', // Texto de ayuda
          ),
        ],
      ),
      body:
          _isLoading // Si está cargando, muestra un indicador de progreso
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              // Permite "tirar para refrescar" la lista
              onRefresh:
                  _loadRssItems, // Llama a _loadRssItems cuando se tira para refrescar
              child: FutureBuilder<List<RssItem>>(
                future: _rssItemsFuture, // El futuro que se está esperando
                builder: (context, snapshot) {
                  // Maneja los diferentes estados del Future:
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      !_isLoading) {
                    // Muestra un indicador si el FutureBuilder aún está esperando y no es la carga inicial
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    // Muestra un mensaje de error si el futuro falla
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    // Muestra un mensaje si no se encontraron datos
                    return const Center(
                      child: Text('No se encontraron noticias.'),
                    );
                  } else {
                    // Si los datos están disponibles, construye la lista de ítems
                    return ListView.builder(
                      itemCount:
                          snapshot.data!.length, // Número de ítems en la lista
                      itemBuilder: (context, index) {
                        final item =
                            snapshot.data![index]; // Obtiene el RssItem actual
                        // Obtiene la URL de la imagen procesada por el proxy y el filtro de video
                        final displayImageUrl = item.imageUrl != null
                            ? _getImageUrlWithProxy(item.imageUrl!)
                            : null;

                        return Card(
                          child: InkWell(
                            // Usa InkWell para un efecto visual de "click"
                            onTap: () {
                              // MODIFICACIÓN: Al tocar la tarjeta, reproduce el TÍTULO y luego la DESCRIPCIÓN
                              TextToSpeechService.speak(
                                '${item.title}. ${item.description}',
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Muestra la imagen SOLO si displayImageUrl no es nulo y no está vacío
                                  if (displayImageUrl != null &&
                                      displayImageUrl.isNotEmpty)
                                    ClipRRect(
                                      // Recorta la imagen con bordes redondeados
                                      borderRadius: BorderRadius.circular(8.0),
                                      child: Image.network(
                                        displayImageUrl, // Usa la URL ya filtrada y proxy-izada
                                        height: 200,
                                        width: double.infinity,
                                        fit: BoxFit
                                            .cover, // Ajusta la imagen para cubrir el área
                                        // Manejo de errores para la imagen (si no carga)
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            height: 100,
                                            color: Colors.grey[200],
                                            alignment: Alignment
                                                .center, // Centra el contenido del Container
                                            child: const Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.broken_image,
                                                  color: Colors.grey,
                                                ),
                                                SizedBox(
                                                  height: 4,
                                                ), // Pequeño espacio entre icono y texto
                                                Text(
                                                  'No se pudo cargar la imagen',
                                                  style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  const SizedBox(
                                    height: 12.0,
                                  ), // Espacio vertical
                                  // Título del artículo
                                  Text(
                                    item.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.0,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 8.0,
                                  ), // Espacio vertical
                                  // Descripción completa, sin truncar
                                  Text(
                                    // <-- MODIFICACIÓN: Mostrar la descripción completa
                                    item.description,
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 8.0,
                                  ), // Espacio vertical
                                  // Fecha de publicación (si está disponible)
                                  if (item.pubDate != null)
                                    Text(
                                      'Publicado: ${item.pubDate!}',
                                      style: TextStyle(
                                        fontSize: 12.0,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
    );
  }
}
