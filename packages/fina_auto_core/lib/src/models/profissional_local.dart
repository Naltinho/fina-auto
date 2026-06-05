import 'package:cloud_firestore/cloud_firestore.dart';

class ProfissionalLocal {
  const ProfissionalLocal({
    required this.id,
    required this.nome,
    required this.subtipo,
    required this.latitude,
    required this.longitude,
    this.telefone,
  });

  final String id;
  final String nome;
  final String subtipo;
  final double latitude;
  final double longitude;
  final String? telefone;

  factory ProfissionalLocal.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
    String subtipo,
  ) {
    final data = doc.data() ?? {};
    return ProfissionalLocal(
      id: doc.id,
      nome: data['nome'] as String? ?? 'Profissional',
      subtipo: subtipo,
      latitude: (data['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 0,
      telefone: data['telefone'] as String?,
    );
  }

  bool get temLocalizacao => latitude != 0 || longitude != 0;
}
