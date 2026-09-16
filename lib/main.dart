import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app.dart';
import 'core/config/env.dart';
import 'core/widgets/marca_laburito.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Qué archivos de logo hay empaquetados. Se resuelve antes de dibujar para
  // no pedir un PNG que todavía no existe.
  await AssetsDeMarca.precargar();

  if (!Env.esValido) {
    runApp(const _FaltaConfiguracion());
    return;
  }

  await Supabase.initialize(
    url: Env.supabaseUrl,
    publishableKey: Env.supabaseAnonKey,
  );

  // CU-21. Si falla —clave mal generada, sin red— `servicioPushProvider` lo
  // nota por `Firebase.apps.isEmpty` y cae en `PushNoConfigurado`: sin push la
  // app tiene que arrancar igual.
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (error) {
    if (kDebugMode) debugPrint('No se pudo inicializar Firebase: $error');
  }

  runApp(const ProviderScope(child: LaburitoApp()));
}

/// La app no arranca sin las claves de Supabase. En vez de una excepción cruda,
/// se muestra el comando que falta ejecutar.
class _FaltaConfiguracion extends StatelessWidget {
  const _FaltaConfiguracion();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Text(
              'Faltan las claves de Supabase.\n\n'
              'Copiá .env.example como .env, completá SUPABASE_URL y '
              'SUPABASE_ANON_KEY, y ejecutá:\n\n'
              'flutter run --dart-define-from-file=.env',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
