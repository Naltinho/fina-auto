import 'package:fina_auto_core/fina_auto_core.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import 'pedido_detail_screen.dart';

class CreatePedidoScreen extends StatefulWidget {
  const CreatePedidoScreen({super.key});

  @override
  State<CreatePedidoScreen> createState() => _CreatePedidoScreenState();
}

class _CreatePedidoScreenState extends State<CreatePedidoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descricao = TextEditingController();
  final _endereco = TextEditingController();
  bool _loading = false;
  bool _locating = true;
  double? _lat;
  double? _lng;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadLocation();
  }

  @override
  void dispose() {
    _descricao.dispose();
    _endereco.dispose();
    super.dispose();
  }

  Future<void> _loadLocation() async {
    setState(() => _locating = true);
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() {
          _lat = -8.8390;
          _lng = 13.2894;
          _error = 'Localização indisponível — usando posição padrão.';
          _locating = false;
        });
        return;
      }
      final pos = await Geolocator.getCurrentPosition();
      setState(() {
        _lat = pos.latitude;
        _lng = pos.longitude;
        _locating = false;
      });
    } on Exception catch (e) {
      setState(() {
        _lat = -8.8390;
        _lng = 13.2894;
        _error = e.toString();
        _locating = false;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _lat == null || _lng == null) {
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final id = await context.read<PedidoService>().criarPedido(
            descricao: _descricao.text,
            latitude: _lat!,
            longitude: _lng!,
            endereco: _endereco.text.trim().isEmpty
                ? null
                : _endereco.text.trim(),
          );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => PedidoDetailScreen(pedidoId: id),
        ),
      );
    } on Exception catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pedir mecânico')),
      body: _locating
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_lat != null)
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.location_on),
                          title: const Text('Localização enviada'),
                          subtitle: Text(
                            'Lat ${_lat!.toStringAsFixed(5)}, Lng ${_lng!.toStringAsFixed(5)}',
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.refresh),
                            onPressed: _loadLocation,
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descricao,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Descreva o problema',
                        hintText: 'Ex.: carro não liga, pneu furado...',
                        alignLabelWithHint: true,
                      ),
                      validator: (v) => v == null || v.trim().length < 10
                          ? 'Mínimo 10 caracteres'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _endereco,
                      decoration: const InputDecoration(
                        labelText: 'Endereço (opcional)',
                      ),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _error!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _loading ? null : _submit,
                      child: _loading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Enviar pedido'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
