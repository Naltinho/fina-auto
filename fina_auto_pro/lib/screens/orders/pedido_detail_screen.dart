import 'package:fina_auto_core/fina_auto_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../chat/chat_screen.dart';

class PedidoDetailScreen extends StatelessWidget {
  const PedidoDetailScreen({super.key, required this.pedidoId});

  final String pedidoId;

  @override
  Widget build(BuildContext context) {
    final pedidoService = context.read<PedidoService>();

    return Scaffold(
      appBar: AppBar(title: const Text('Pedido')),
      body: StreamBuilder<Pedido?>(
        stream: pedidoService.streamPedido(pedidoId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final pedido = snapshot.data;
          if (pedido == null) {
            return const Center(child: Text('Pedido não encontrado.'));
          }

          final podeNavegar = pedido.status == PedidoStatus.aceite ||
              pedido.status == PedidoStatus.emAndamento;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _StatusChip(status: pedido.status),
                const SizedBox(height: 16),
                Text(
                  pedido.descricao,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                if (pedido.endereco != null)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.place),
                    title: Text(pedido.endereco!),
                  ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.map),
                  title: Text(
                    '${pedido.latitude.toStringAsFixed(5)}, ${pedido.longitude.toStringAsFixed(5)}',
                  ),
                ),
                if (podeNavegar) ...[
                  const SizedBox(height: 8),
                  FilledButton.tonalIcon(
                    onPressed: () async {
                      final ok = await NavigationHelper.abrirNavegacao(
                        latitude: pedido.latitude,
                        longitude: pedido.longitude,
                        label: pedido.endereco ?? 'Cliente',
                      );
                      if (!ok && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Não foi possível abrir o mapa.'),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.navigation),
                    label: const Text('Navegar até ao cliente'),
                  ),
                ],
                const SizedBox(height: 24),
                if (pedido.status == PedidoStatus.pendente) ...[
                  FilledButton.icon(
                    onPressed: () => _aceitar(context, pedidoService),
                    icon: const Icon(Icons.check),
                    label: const Text('Aceitar pedido'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => _rejeitar(context, pedidoService),
                    icon: const Icon(Icons.close),
                    label: const Text('Rejeitar'),
                  ),
                ],
                if (pedido.status == PedidoStatus.aceite) ...[
                  FilledButton.icon(
                    onPressed: () async {
                      await pedidoService.iniciarServico(pedidoId);
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Iniciar serviço'),
                  ),
                  const SizedBox(height: 12),
                  _chatButton(context),
                ],
                if (pedido.status == PedidoStatus.emAndamento) ...[
                  FilledButton.icon(
                    onPressed: () async {
                      await pedidoService.concluirPedido(pedidoId);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Pedido concluído')),
                        );
                      }
                    },
                    icon: const Icon(Icons.done_all),
                    label: const Text('Concluir serviço'),
                  ),
                  const SizedBox(height: 12),
                  _chatButton(context),
                ],
                if (pedido.status == PedidoStatus.concluido &&
                    pedido.pagamentoStatus == 'pago') ...[
                  const SizedBox(height: 12),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.payments, color: Colors.green),
                      title: Text(
                        'Pago: ${(pedido.valorServico ?? PagamentoDefaults.valorServico).toStringAsFixed(0)} AOA',
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _chatButton(BuildContext context) {
    return FilledButton.tonalIcon(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => ChatScreen(pedidoId: pedidoId),
          ),
        );
      },
      icon: const Icon(Icons.chat),
      label: const Text('Chat com cliente'),
    );
  }

  Future<void> _aceitar(BuildContext context, PedidoService service) async {
    try {
      await service.aceitarPedido(pedidoId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pedido aceite!')),
        );
      }
    } on Exception catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e')),
        );
      }
    }
  }

  Future<void> _rejeitar(BuildContext context, PedidoService service) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rejeitar pedido?'),
        content: const Text(
          'O pedido ficará disponível para outros profissionais.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Rejeitar'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    try {
      await service.rejeitarPedido(pedidoId);
      if (context.mounted) Navigator.of(context).pop();
    } on Exception catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e')),
        );
      }
    }
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final PedidoStatus status;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: const Icon(Icons.info_outline, size: 18),
      label: Text(PedidoUi.statusLabel(status)),
    );
  }
}
