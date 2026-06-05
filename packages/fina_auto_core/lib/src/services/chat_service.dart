import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../collections.dart';
import '../models/chat_message.dart';

class ChatService {
  ChatService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  String? get _uid => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> _mensagens(String pedidoId) =>
      _firestore.collection(FinaCollections.chatMessages(pedidoId));

  Stream<List<ChatMessage>> streamMensagens(String pedidoId) {
    return _mensagens(pedidoId)
        .orderBy('criadoEm', descending: false)
        .limit(200)
        .snapshots()
        .map((snap) => snap.docs.map(ChatMessage.fromFirestore).toList());
  }

  Future<void> enviarMensagem({
    required String pedidoId,
    required String texto,
  }) async {
    final uid = _uid;
    if (uid == null) throw StateError('Utilizador não autenticado');
    final trimmed = texto.trim();
    if (trimmed.isEmpty) return;

    await _mensagens(pedidoId).add({
      'remetenteId': uid,
      'texto': trimmed,
      'criadoEm': FieldValue.serverTimestamp(),
    });
  }
}
