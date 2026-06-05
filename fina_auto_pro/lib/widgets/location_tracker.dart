import 'package:firebase_auth/firebase_auth.dart';
import 'package:fina_auto_core/fina_auto_core.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

/// Atualiza a localização do profissional no Firestore ao abrir o app.
class LocationTracker extends StatefulWidget {
  const LocationTracker({
    super.key,
    required this.subtipo,
    required this.child,
  });

  final ProfissionalSubtipo subtipo;
  final Widget child;

  @override
  State<LocationTracker> createState() => _LocationTrackerState();
}

class _LocationTrackerState extends State<LocationTracker> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _atualizar());
  }

  Future<void> _atualizar() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }
      final pos = await Geolocator.getCurrentPosition();
      if (!mounted) return;
      await context.read<ProfissionalService>().atualizarLocalizacao(
            userId: userId,
            subtipo: widget.subtipo,
            latitude: pos.latitude,
            longitude: pos.longitude,
          );
    } on Exception catch (e) {
      debugPrint('LocationTracker: $e');
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
