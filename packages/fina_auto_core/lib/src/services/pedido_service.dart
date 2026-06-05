import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../collections.dart';
import '../enums.dart';
import '../models/pedido.dart';
import 'pagamento_service.dart' show PagamentoDefaults;

class PedidoService {
  PedidoService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  String? get _uid => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> get _pedidos =>
      _firestore.collection(FinaCollections.pedidos);

  Future<String> criarPedido({
    required String descricao,
    required double latitude,
    required double longitude,
    String? endereco,
  }) async {
    final uid = _uid;
    if (uid == null) throw StateError('Utilizador não autenticado');

    final ref = _pedidos.doc();
    await ref.set({
      'clienteId': uid,
      'descricao': descricao.trim(),
      'status': PedidoStatus.pendente.value,
      'latitude': latitude,
      'longitude': longitude,
      if (endereco != null && endereco.isNotEmpty) 'endereco': endereco,
      'rejeitadoPor': <String>[],
      'criadoEm': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  Future<void> aceitarPedido(String pedidoId) async {
    final uid = _uid;
    if (uid == null) throw StateError('Utilizador não autenticado');

    await _pedidos.doc(pedidoId).update({
      'profissionalId': uid,
      'status': PedidoStatus.aceite.value,
      'aceiteEm': FieldValue.serverTimestamp(),
    });
  }

  Future<void> rejeitarPedido(String pedidoId) async {
    final uid = _uid;
    if (uid == null) throw StateError('Utilizador não autenticado');

    await _pedidos.doc(pedidoId).update({
      'rejeitadoPor': FieldValue.arrayUnion([uid]),
    });
  }

  Future<void> iniciarServico(String pedidoId) async {
    await _pedidos.doc(pedidoId).update({
      'status': PedidoStatus.emAndamento.value,
    });
  }

  Future<void> concluirPedido(String pedidoId) async {
    await _pedidos.doc(pedidoId).update({
      'status': PedidoStatus.concluido.value,
      'concluidoEm': FieldValue.serverTimestamp(),
      'valorServico': PagamentoDefaults.valorServico,
      'pagamentoStatus': 'pendente',
    });
  }

  Future<void> cancelarPedido(String pedidoId) async {
    await _pedidos.doc(pedidoId).update({
      'status': PedidoStatus.cancelado.value,
    });
  }

  Stream<Pedido?> streamPedido(String pedidoId) {
    return _pedidos.doc(pedidoId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return Pedido.fromFirestore(doc);
    });
  }

  Stream<List<Pedido>> streamPedidosCliente() {
    final uid = _uid;
    if (uid == null) return Stream.value([]);

    return _pedidos
        .where('clienteId', isEqualTo: uid)
        .orderBy('criadoEm', descending: true)
        .limit(100)
        .snapshots()
        .map(_mapDocs);
  }

  Stream<List<Pedido>> streamPedidosPendentesPro() {
    final uid = _uid;
    if (uid == null) return Stream.value([]);

    return _pedidos
        .where('status', isEqualTo: PedidoStatus.pendente.value)
        .orderBy('criadoEm', descending: true)
        .limit(50)
        .snapshots()
        .map((snap) {
          return snap.docs
              .map(Pedido.fromFirestore)
              .where((p) => !p.rejeitadoPor.contains(uid))
              .toList();
        });
  }

  Stream<List<Pedido>> streamPedidosAtivosPro() {
    final uid = _uid;
    if (uid == null) return Stream.value([]);

    return _pedidos
        .where('profissionalId', isEqualTo: uid)
        .orderBy('criadoEm', descending: true)
        .limit(50)
        .snapshots()
        .map((snap) {
          return snap.docs
              .map(Pedido.fromFirestore)
              .where(
                (p) =>
                    p.status == PedidoStatus.aceite ||
                    p.status == PedidoStatus.emAndamento,
              )
              .toList();
        });
  }

  List<Pedido> _mapDocs(QuerySnapshot<Map<String, dynamic>> snap) {
    return snap.docs.map(Pedido.fromFirestore).toList();
  }
}
