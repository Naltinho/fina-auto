import 'package:fina_auto_core/fina_auto_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../chat/chat_screen.dart';

class PedidoDetailScreen extends StatefulWidget {
  const PedidoDetailScreen({super.key, required this.pedidoId});

  final String pedidoId;

  @override
  State<PedidoDetailScreen> createState() => _PedidoDetailScreenState();
}

class _PedidoDetailScreenState extends State<PedidoDetailScreen> {
  bool _processing = false;

  Future<void> _pagar(Pedido pedido) async {
    if (pedido.profissionalId == null) return;
    setState(() => _processing = true);
    try {
      await context.read<PagamentoService>().simularPagamento(
            pedidoId: widget.pedidoId,
            profissionalId: pedido.profissionalId!,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pagamento simulado com sucesso!')),
        );
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  Future<void> _avaliar(Pedido pedido) async {
    var estrelas = 5;
    final comentario = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Avaliar serviço'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  return IconButton(
                    onPressed: () => setDialogState(() => estrelas = i + 1),
                    icon: Icon(
                      i < estrelas ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 36,
                    ),
                  );
                }),
              ),
              TextField(
                controller: comentario,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Comentário (opcional)',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Enviar'),
            ),
          ],
        ),
      ),
    );

    if (ok != true || !mounted) return;
    setState(() => _processing = true);
    try {
      await context.read<AvaliacaoService>().avaliarPedido(
            pedidoId: widget.pedidoId,
            estrelas: estrelas,
            comentario: comentario.text,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Obrigado pela avaliação!')),
        );
      }
    } finally {
      comentario.dispose();
      if (mounted) setState(() => _processing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pedidoService = context.read<PedidoService>();

    return Scaffold(
      appBar: AppBar(title: const Text('Detalhe do pedido')),
      body: StreamBuilder<Pedido?>(
        stream: pedidoService.streamPedido(widget.pedidoId),
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

          final valor = pedido.valorServico ?? PagamentoDefaults.valorServico;

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
                if (pedido.status == PedidoStatus.pendente)
                  OutlinedButton.icon(
                    onPressed: _processing
                        ? null
                        : () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Cancelar pedido?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: const Text('Não'),
                                  ),
                                  FilledButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: const Text('Sim'),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true && context.mounted) {
                              await pedidoService.cancelarPedido(widget.pedidoId);
                            }
                          },
                    icon: const Icon(Icons.cancel_outlined),
                    label: const Text('Cancelar pedido'),
                  ),
                if (pedido.podeChat) ...[
                  const SizedBox(height: 12),
                  FilledButton.tonalIcon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) =>
                              ChatScreen(pedidoId: widget.pedidoId),
                        ),
                      );
                    },
                    icon: const Icon(Icons.chat),
                    label: const Text('Chat com profissional'),
                  ),
                ],
                if (pedido.precisaPagamento) ...[
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pagamento',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${valor.toStringAsFixed(0)} AOA (simulação)',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 12),
                          FilledButton.icon(
                            onPressed: _processing
                                ? null
                                : () => _pagar(pedido),
                            icon: const Icon(Icons.payment),
                            label: const Text('Pagar agora'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                if (pedido.precisaAvaliacao) ...[
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed:
                        _processing ? null : () => _avaliar(pedido),
                    icon: const Icon(Icons.star),
                    label: const Text('Avaliar serviço'),
                  ),
                ],
                if (pedido.avaliacaoEstrelas != null) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      ...List.generate(
                        5,
                        (i) => Icon(
                          i < pedido.avaliacaoEstrelas!
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('Avaliação enviada'),
                    ],
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
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
