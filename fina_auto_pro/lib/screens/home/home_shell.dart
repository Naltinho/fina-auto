import 'package:fina_auto_core/fina_auto_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/auth_service.dart';
import '../../widgets/location_tracker.dart';
import '../ganhos/ganhos_screen.dart';
import '../orders/active_orders_screen.dart';
import '../orders/orders_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;
  ProfissionalSubtipo? _subtipo;

  @override
  void initState() {
    super.initState();
    _loadSubtipo();
  }

  Future<void> _loadSubtipo() async {
    final profile = await context.read<AuthService>().getCurrentProfile();
    if (mounted) {
      setState(() => _subtipo = profile?.profissionalSubtipo);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      const OrdersScreen(),
      const ActiveOrdersScreen(),
      const GanhosScreen(),
      const _ContaTab(),
    ];

    Widget body = Scaffold(
      body: pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.inbox_outlined),
            selectedIcon: Icon(Icons.inbox),
            label: 'Novos',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment),
            label: 'Ativos',
          ),
          NavigationDestination(
            icon: Icon(Icons.payments_outlined),
            selectedIcon: Icon(Icons.payments),
            label: 'Ganhos',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Conta',
          ),
        ],
      ),
    );

    if (_subtipo != null) {
      body = LocationTracker(subtipo: _subtipo!, child: body);
    }

    return body;
  }
}

class _ContaTab extends StatelessWidget {
  const _ContaTab();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.settings,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text('Conta', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            const Text(
              'A sua localização é atualizada automaticamente para aparecer no mapa dos clientes.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.tonalIcon(
              onPressed: () => context.read<AuthService>().signOut(),
              icon: const Icon(Icons.logout),
              label: const Text('Terminar sessão'),
            ),
          ],
        ),
      ),
    );
  }
}
