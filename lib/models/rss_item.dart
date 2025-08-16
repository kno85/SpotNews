// lib/models/rss_item.dart
// Este archivo define la estructura de datos para un ítem de noticias RSS.
// Ubícalo en: lib/models/rss_item.dart

class RssItem {
  final String title;
  final String link;
  final String description;
  final String? pubDate; // Fecha de publicación, puede ser nula
  final String?
  imageUrl; // URL de la imagen asociada al artículo, puede ser nula

  RssItem({
    required this.title,
    required this.link,
    required this.description,
    this.pubDate,
    this.imageUrl,
  });
}
