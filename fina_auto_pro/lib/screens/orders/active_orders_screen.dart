import 'package:fina_auto_core/fina_auto_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'pedido_detail_screen.dart';

class ActiveOrdersScreen extends StatelessWidget {
  const ActiveOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stream = context.read<PedidoService>().streamPedidosAtivosPro();

    return Scaffold(
      appBar: AppBar(title: const Text('Pedidos ativos')),
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
              child: Text('Nenhum pedido ativo.'),
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
                  leading: const CircleAvatar(child: Icon(Icons.build)),
                  title: Text(p.descricao, maxLines: 2, overflow: TextOverflow.ellipsis),
                  subtitle: Text(PedidoUi.statusLabel(p.status)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (p.podeChat)
                        IconButton(
                          icon: const Icon(Icons.chat_bubble_outline),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => PedidoDetailScreen(pedidoId: p.id),
                              ),
                            );
                          },
                        ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
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
}
