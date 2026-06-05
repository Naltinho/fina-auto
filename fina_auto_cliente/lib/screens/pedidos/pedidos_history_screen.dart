import 'package:fina_auto_core/fina_auto_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'pedido_detail_screen.dart';

class PedidosHistoryScreen extends StatelessWidget {
  const PedidosHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stream = context.read<PedidoService>().streamPedidosCliente();

    return Scaffold(
      appBar: AppBar(title: const Text('Os meus pedidos')),
      body: StreamBuilder<List<Pedido>>(
        stream: stream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final pedidos = snapshot.data!;
          if (pedidos.isEmpty) {
            return const Center(
              child: Text('Ainda não tem pedidos.'),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: pedidos.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final p = pedidos[index];
              return Card(
                child: ListTile(
                  leading: Icon(_iconFor(p.status)),
                  title: Text(p.descricao, maxLines: 2, overflow: TextOverflow.ellipsis),
                  subtitle: Text(PedidoUi.statusLabel(p.status)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => PedidoDetailScreen(pedidoId: p.id),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  IconData _iconFor(PedidoStatus status) {
    switch (status) {
      case PedidoStatus.pendente:
        return Icons.hourglass_top;
      case PedidoStatus.aceite:
      case PedidoStatus.emAndamento:
        return Icons.build_circle;
      case PedidoStatus.concluido:
        return Icons.check_circle;
      case PedidoStatus.cancelado:
        return Icons.cancel;
    }
  }
}
