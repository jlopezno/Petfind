// Punto de entrada de la aplicacion PetFindr.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/enrutador.dart';
import 'app/tema.dart';
import 'compartido/servicios/servicio_notificaciones_push.dart';
import 'nucleo/constantes/supabase_constantes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Obtienes estas credenciales en Supabase: Project Settings > API.
  if (credencialesSupabaseConfiguradas) {
    await Supabase.initialize(
      url: urlSupabase,
      publishableKey: llaveAnonimaSupabase,
    );
  }
  await ServicioNotificacionesPush.instancia.inicializar();

  runApp(const ProviderScope(child: AplicacionPetFindr()));
}

class AplicacionPetFindr extends ConsumerWidget {
  const AplicacionPetFindr({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enrutador = ref.watch(proveedorEnrutador);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'PetFindr',
      theme: temaPetFindr,
      routerConfig: enrutador,
    );
  }
}
