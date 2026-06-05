import 'package:fina_auto_core/fina_auto_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GanhosScreen extends StatelessWidget {
  const GanhosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stream = context.read<PagamentoService>().streamGanhosProfissional();

    return Scaffold(
      appBar: AppBar(title: const Text('Histórico de ganhos')),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: stream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snapshot.data!;
          if (items.isEmpty) {
            return const Center(
              child: Text('Ainda sem pagamentos recebidos.'),
            );
          }

          final total = items.fold<double>(
            0,
            (s, i) => s + ((i['valor'] as num?)?.toDouble() ?? 0),
          );

          return Column(
            children: [
              Card(
                margin: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      const Icon(Icons.account_balance_wallet, size: 40),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Total recebido'),
                          Text(
                            '${total.toStringAsFixed(0)} AOA',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final p = items[index];
                    final valor = (p['valor'] as num?)?.toDouble() ?? 0;
                    return ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.payments),
                      ),
                      title: Text('${valor.toStringAsFixed(0)} AOA'),
                      subtitle: Text('Pedido #${p['pedidoId'] ?? ''}'),
                      trailing: const Icon(Icons.check_circle, color: Colors.green),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
