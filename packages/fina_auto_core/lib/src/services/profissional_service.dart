import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../collections.dart';
import '../enums.dart';
import '../models/profissional_local.dart';

class ProfissionalService {
  ProfissionalService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<List<ProfissionalLocal>> streamProfissionaisNoMapa() {
    final controller = StreamController<List<ProfissionalLocal>>.broadcast();
    var oficinas = <ProfissionalLocal>[];
    var mecanicos = <ProfissionalLocal>[];

    void emit() {
      if (!controller.isClosed) {
        controller.add([
          ...oficinas.where((p) => p.temLocalizacao),
          ...mecanicos.where((p) => p.temLocalizacao),
        ]);
      }
    }

    final sub1 = _firestore
        .collection(FinaCollections.oficinas)
        .where('ativo', isEqualTo: true)
        .snapshots()
        .listen((snap) {
      oficinas = snap.docs
          .map((d) => ProfissionalLocal.fromFirestore(d, 'oficina'))
          .toList();
      emit();
    });

    final sub2 = _firestore
        .collection(FinaCollections.mecanicos)
        .where('ativo', isEqualTo: true)
        .snapshots()
        .listen((snap) {
      mecanicos = snap.docs
          .map((d) => ProfissionalLocal.fromFirestore(d, 'mecanico'))
          .toList();
      emit();
    });

    controller.onCancel = () async {
      await sub1.cancel();
      await sub2.cancel();
    };

    return controller.stream;
  }

  Future<void> atualizarLocalizacao({
    required String userId,
    required ProfissionalSubtipo subtipo,
    required double latitude,
    required double longitude,
  }) async {
    final data = {
      'latitude': latitude,
      'longitude': longitude,
      'localizacaoAtualizadaEm': FieldValue.serverTimestamp(),
    };
    final collection = subtipo == ProfissionalSubtipo.oficina
        ? FinaCollections.oficinas
        : FinaCollections.mecanicos;
    await _firestore.collection(collection).doc(userId).update(data);
  }
}
