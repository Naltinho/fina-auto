import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../collections.dart';

class AvaliacaoService {
  AvaliacaoService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  Future<void> avaliarPedido({
    required String pedidoId,
    required int estrelas,
    String? comentario,
  }) async {
    if (estrelas < 1 || estrelas > 5) {
      throw ArgumentError('Estrelas devem ser entre 1 e 5');
    }

    await _firestore.collection(FinaCollections.pedidos).doc(pedidoId).update({
      'avaliacaoEstrelas': estrelas,
      if (comentario != null && comentario.isNotEmpty)
        'avaliacaoComentario': comentario.trim(),
      'avaliadoEm': FieldValue.serverTimestamp(),
      'avaliadoPor': _auth.currentUser?.uid,
    });
  }
}
