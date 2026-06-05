import 'package:fina_auto_core/fina_auto_core.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _controller;
  LatLng? _position;
  String? _locationError;
  bool _loading = true;

  static const _fallback = LatLng(-8.8390, 13.2894);

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() {
          _position = _fallback;
          _locationError = 'Permissão de localização negada.';
          _loading = false;
        });
        return;
      }
      final pos = await Geolocator.getCurrentPosition();
      setState(() {
        _position = LatLng(pos.latitude, pos.longitude);
        _loading = false;
      });
    } on Exception catch (e) {
      setState(() {
        _position = _fallback;
        _locationError = e.toString();
        _loading = false;
      });
    }
  }

  Set<Marker> _buildMarkers(LatLng userPos, List<ProfissionalLocal> profs) {
    final markers = <Marker>{
      Marker(
        markerId: const MarkerId('eu'),
        position: userPos,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: const InfoWindow(title: 'A sua localização'),
      ),
    };
    for (final p in profs) {
      if (!p.temLocalizacao) continue;
      markers.add(
        Marker(
          markerId: MarkerId('${p.subtipo}_${p.id}'),
          position: LatLng(p.latitude, p.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            p.subtipo == 'oficina'
                ? BitmapDescriptor.hueGreen
                : BitmapDescriptor.hueOrange,
          ),
          infoWindow: InfoWindow(
            title: p.nome,
            snippet: p.subtipo == 'oficina' ? 'Oficina' : 'Mecânico',
          ),
        ),
      );
    }
    return markers;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final target = _position ?? _fallback;
    final profStream =
        context.read<ProfissionalService>().streamProfissionaisNoMapa();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Oficinas e mecânicos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _initLocation,
          ),
        ],
      ),
      body: StreamBuilder<List<ProfissionalLocal>>(
        stream: profStream,
        builder: (context, profSnap) {
          final profs = profSnap.data ?? [];
          final markers = _buildMarkers(target, profs);

          return Stack(
            children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: target,
                  zoom: 14,
                ),
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                markers: markers,
                onMapCreated: (c) => _controller = c,
              ),
              Positioned(
                top: 8,
                left: 16,
                right: 16,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.garage, color: Colors.green[700], size: 20),
                        const SizedBox(width: 4),
                        Text(
                          '${profs.where((p) => p.subtipo == 'oficina').length} oficinas',
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.handyman,
                            color: Colors.orange[800], size: 20),
                        const SizedBox(width: 4),
                        Text(
                          '${profs.where((p) => p.subtipo == 'mecanico').length} mecânicos',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (_locationError != null)
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(_locationError!),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
