enum UserType {
  cliente('cliente'),
  profissional('profissional'),
  admin('admin');

  const UserType(this.value);
  final String value;

  static UserType fromString(String? v) {
    return UserType.values.firstWhere(
      (e) => e.value == v,
      orElse: () => UserType.cliente,
    );
  }
}

enum ProfissionalSubtipo {
  oficina('oficina'),
  mecanico('mecanico');

  const ProfissionalSubtipo(this.value);
  final String value;

  static ProfissionalSubtipo? fromString(String? v) {
    if (v == null) return null;
    try {
      return ProfissionalSubtipo.values.firstWhere((e) => e.value == v);
    } catch (_) {
      return null;
    }
  }
}

enum PedidoStatus {
  pendente('pendente'),
  aceite('aceite'),
  emAndamento('em_andamento'),
  concluido('concluido'),
  cancelado('cancelado');

  const PedidoStatus(this.value);
  final String value;

  static PedidoStatus fromString(String? v) {
    return PedidoStatus.values.firstWhere(
      (e) => e.value == v,
      orElse: () => PedidoStatus.pendente,
    );
  }
}
