import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../collections.dart';

/// Valor fixo MVP do serviço (AOA).
abstract final class PagamentoDefaults {
  static const double valorServico = 15000;
}

class PagamentoService {
  PagamentoService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  String? get _uid => _auth.currentUser?.uid;

  Future<void> simularPagamento({
    required String pedidoId,
    required String profissionalId,
  }) async {
    final uid = _uid;
    if (uid == null) throw StateError('Não autenticado');

    final batch = _firestore.batch();
    final pagRef = _firestore.collection(FinaCollections.pagamentos).doc();

    batch.set(pagRef, {
      'pedidoId': pedidoId,
      'clienteId': uid,
      'profissionalId': profissionalId,
      'valor': PagamentoDefaults.valorServico,
      'moeda': 'AOA',
      'metodo': 'simulado',
      'status': 'pago',
      'criadoEm': FieldValue.serverTimestamp(),
    });

    batch.update(_firestore.collection(FinaCollections.pedidos).doc(pedidoId), {
      'pagamentoStatus': 'pago',
      'valorServico': PagamentoDefaults.valorServico,
      'pagamentoId': pagRef.id,
    });

    await batch.commit();
  }

  Stream<List<Map<String, dynamic>>> streamGanhosProfissional() {
    final uid = _uid;
    if (uid == null) return Stream.value([]);

    return _firestore
        .collection(FinaCollections.pagamentos)
        .where('profissionalId', isEqualTo: uid)
        .where('status', isEqualTo: 'pago')
        .orderBy('criadoEm', descending: true)
        .limit(100)
        .snapshots()
        .map((s) => s.docs.map((d) => {'id': d.id, ...d.data()}).toList());
  }
}
