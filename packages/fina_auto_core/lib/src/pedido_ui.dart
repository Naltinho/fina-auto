import 'enums.dart';

/// Textos e cores partilhados para estado do pedido.
abstract final class PedidoUi {
  static String statusLabel(PedidoStatus status) {
    switch (status) {
      case PedidoStatus.pendente:
        return 'À espera de profissional';
      case PedidoStatus.aceite:
        return 'Profissional a caminho';
      case PedidoStatus.emAndamento:
        return 'Serviço em curso';
      case PedidoStatus.concluido:
        return 'Concluído';
      case PedidoStatus.cancelado:
        return 'Cancelado';
    }
  }
}
