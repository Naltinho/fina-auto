import 'package:fina_auto_core/fina_auto_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'pedido_detail_screen.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stream = context.read<PedidoService>().streamPedidosPendentesPro();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Novos pedidos'),
      ),
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
              child: Text('Nenhum pedido pendente no momento.'),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: pedidos.length,
            itemBuilder: (context, index) {
              final pedido = pedidos[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.build),
                  ),
                  title: Text(pedido.descricao),
                  subtitle: Text(
                    pedido.endereco ??
                        'Lat ${pedido.latitude}, Lng ${pedido.longitude}',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            PedidoDetailScreen(pedidoId: pedido.id),
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
