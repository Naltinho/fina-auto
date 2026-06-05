import 'package:cloud_firestore/cloud_firestore.dart';

import '../enums.dart';

class Pedido {
  const Pedido({
    required this.id,
    required this.clienteId,
    required this.descricao,
    required this.status,
    required this.latitude,
    required this.longitude,
    this.profissionalId,
    this.endereco,
    this.criadoEm,
    this.rejeitadoPor = const [],
    this.valorServico,
    this.pagamentoStatus,
    this.avaliacaoEstrelas,
    this.avaliacaoComentario,
  });

  final String id;
  final String clienteId;
  final String? profissionalId;
  final String descricao;
  final PedidoStatus status;
  final double latitude;
  final double longitude;
  final String? endereco;
  final DateTime? criadoEm;
  final List<String> rejeitadoPor;
  final double? valorServico;
  final String? pagamentoStatus;
  final int? avaliacaoEstrelas;
  final String? avaliacaoComentario;

  bool get precisaPagamento =>
      status == PedidoStatus.concluido && pagamentoStatus != 'pago';

  bool get precisaAvaliacao =>
      status == PedidoStatus.concluido &&
      pagamentoStatus == 'pago' &&
      avaliacaoEstrelas == null;

  factory Pedido.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Pedido(
      id: doc.id,
      clienteId: data['clienteId'] as String? ?? '',
      profissionalId: data['profissionalId'] as String?,
      descricao: data['descricao'] as String? ?? '',
      status: PedidoStatus.fromString(data['status'] as String?),
      latitude: (data['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 0,
      endereco: data['endereco'] as String?,
      criadoEm: (data['criadoEm'] as Timestamp?)?.toDate(),
      rejeitadoPor: List<String>.from(
        data['rejeitadoPor'] as List<dynamic>? ?? [],
      ),
      valorServico: (data['valorServico'] as num?)?.toDouble(),
      pagamentoStatus: data['pagamentoStatus'] as String?,
      avaliacaoEstrelas: data['avaliacaoEstrelas'] as int?,
      avaliacaoComentario: data['avaliacaoComentario'] as String?,
    );
  }

  bool get podeChat =>
      status == PedidoStatus.aceite || status == PedidoStatus.emAndamento;

  Map<String, dynamic> toFirestore() {
    return {
      'clienteId': clienteId,
      if (profissionalId != null) 'profissionalId': profissionalId,
      'descricao': descricao,
      'status': status.value,
      'latitude': latitude,
      'longitude': longitude,
      if (endereco != null) 'endereco': endereco,
      'criadoEm': FieldValue.serverTimestamp(),
    };
  }
}
