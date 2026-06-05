/// Nomes das collections Firestore (backend único).
abstract final class FinaCollections {
  static const users = 'users';
  static const pedidos = 'pedidos';
  static const oficinas = 'oficinas';
  static const mecanicos = 'mecanicos';
  static const produtos = 'produtos';
  static const pagamentos = 'pagamentos';
  static const chat = 'chat';

  static String chatMessages(String pedidoId) =>
      '$chat/$pedidoId/mensagens';
}
