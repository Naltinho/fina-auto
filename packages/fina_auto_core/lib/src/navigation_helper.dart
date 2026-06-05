import 'package:url_launcher/url_launcher.dart';

abstract final class NavigationHelper {
  /// Abre Google Maps com navegação até o destino.
  static Future<bool> abrirNavegacao({
    required double latitude,
    required double longitude,
    String? label,
  }) async {
    final dest = '$latitude,$longitude';
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$dest&travelmode=driving',
    );
    if (await canLaunchUrl(uri)) {
      return launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    final fallback = Uri.parse('geo:$dest?q=$dest(${label ?? 'Destino'})');
    return launchUrl(fallback, mode: LaunchMode.externalApplication);
  }
}
