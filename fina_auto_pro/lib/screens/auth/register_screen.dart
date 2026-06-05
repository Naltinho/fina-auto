import 'package:fina_auto_core/fina_auto_core.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import '../../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nome = TextEditingController();
  final _email = TextEditingController();
  final _telefone = TextEditingController();
  final _password = TextEditingController();
  ProfissionalSubtipo _subtipo = ProfissionalSubtipo.mecanico;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nome.dispose();
    _email.dispose();
    _telefone.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      double? lat;
      double? lng;
      try {
        var permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        if (permission == LocationPermission.whileInUse ||
            permission == LocationPermission.always) {
          final pos = await Geolocator.getCurrentPosition();
          lat = pos.latitude;
          lng = pos.longitude;
        }
      } catch (_) {}

      await context.read<AuthService>().registerProfissional(
            email: _email.text.trim(),
            password: _password.text,
            nome: _nome.text.trim(),
            subtipo: _subtipo,
            telefone: _telefone.text.trim().isEmpty
                ? null
                : _telefone.text.trim(),
            latitude: lat,
            longitude: lng,
          );
      if (mounted) Navigator.of(context).pop();
    } on Exception catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registo profissional')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SegmentedButton<ProfissionalSubtipo>(
                  segments: const [
                    ButtonSegment(
                      value: ProfissionalSubtipo.mecanico,
                      label: Text('Mecânico'),
                      icon: Icon(Icons.handyman),
                    ),
                    ButtonSegment(
                      value: ProfissionalSubtipo.oficina,
                      label: Text('Oficina'),
                      icon: Icon(Icons.garage),
                    ),
                  ],
                  selected: {_subtipo},
                  onSelectionChanged: (s) =>
                      setState(() => _subtipo = s.first),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nome,
                  decoration: InputDecoration(
                    labelText: _subtipo == ProfissionalSubtipo.oficina
                        ? 'Nome da oficina'
                        : 'Nome completo',
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Obrigatório' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'E-mail'),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Obrigatório' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _telefone,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Telefone'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _password,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Palavra-passe'),
                  validator: (v) =>
                      v == null || v.length < 6 ? 'Mínimo 6 caracteres' : null,
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
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
                      : const Text('Registar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
