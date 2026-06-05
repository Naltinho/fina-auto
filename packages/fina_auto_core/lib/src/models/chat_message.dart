import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.remetenteId,
    required this.texto,
    this.criadoEm,
  });

  final String id;
  final String remetenteId;
  final String texto;
  final DateTime? criadoEm;

  factory ChatMessage.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return ChatMessage(
      id: doc.id,
      remetenteId: data['remetenteId'] as String? ?? '',
      texto: data['texto'] as String? ?? '',
      criadoEm: (data['criadoEm'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'remetenteId': remetenteId,
      'texto': texto,
      'criadoEm': FieldValue.serverTimestamp(),
    };
  }
}
