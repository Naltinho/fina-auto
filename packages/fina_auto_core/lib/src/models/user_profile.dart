import 'package:cloud_firestore/cloud_firestore.dart';

import '../enums.dart';

class UserProfile {
  const UserProfile({
    required this.id,
    required this.email,
    required this.nome,
    required this.tipo,
    this.telefone,
    this.profissionalSubtipo,
    this.fotoUrl,
    this.criadoEm,
  });

  final String id;
  final String email;
  final String nome;
  final UserType tipo;
  final String? telefone;
  final ProfissionalSubtipo? profissionalSubtipo;
  final String? fotoUrl;
  final DateTime? criadoEm;

  factory UserProfile.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return UserProfile(
      id: doc.id,
      email: data['email'] as String? ?? '',
      nome: data['nome'] as String? ?? '',
      tipo: UserType.fromString(data['tipo'] as String?),
      telefone: data['telefone'] as String?,
      profissionalSubtipo:
          ProfissionalSubtipo.fromString(data['profissionalSubtipo'] as String?),
      fotoUrl: data['fotoUrl'] as String?,
      criadoEm: (data['criadoEm'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'nome': nome,
      'tipo': tipo.value,
      if (telefone != null) 'telefone': telefone,
      if (profissionalSubtipo != null)
        'profissionalSubtipo': profissionalSubtipo!.value,
      if (fotoUrl != null) 'fotoUrl': fotoUrl,
      'criadoEm': FieldValue.serverTimestamp(),
    };
  }
}
