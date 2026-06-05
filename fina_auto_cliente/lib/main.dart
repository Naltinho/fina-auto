import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fina_auto_core/fina_auto_core.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'services/push_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  try {
    await PushService().init();
  } catch (e) {
    debugPrint('FCM não configurado: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        Provider(create: (_) => PedidoService()),
        Provider(create: (_) => ChatService()),
        Provider(create: (_) => ProfissionalService()),
        Provider(create: (_) => PagamentoService()),
        Provider(create: (_) => AvaliacaoService()),
        Provider(create: (_) => PushTokenService()),
      ],
      child: const FinaAutoClienteApp(),
    ),
  );
}
