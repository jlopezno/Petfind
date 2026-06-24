// Punto de entrada de la aplicacion PetFindr.
import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/enrutador.dart';
import 'app/tema.dart';
import 'caracteristicas/autenticacion/proveedores/proveedor_autenticacion.dart';
import 'caracteristicas/autenticacion/proveedores/proveedor_onboarding.dart';
import 'compartido/servicios/servicio_notificaciones_push.dart';
import 'nucleo/constantes/supabase_constantes.dart';
import 'nucleo/constantes/rutas.dart';

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

class AplicacionPetFindr extends ConsumerStatefulWidget {
  const AplicacionPetFindr({super.key});

  @override
  ConsumerState<AplicacionPetFindr> createState() =>
      _AplicacionPetFindrState();
}

class _AplicacionPetFindrState extends ConsumerState<AplicacionPetFindr> {
  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _suscripcionEnlaces;
  String? _rutaPendiente;
  bool _navegacionProgramada = false;

  @override
  void initState() {
    super.initState();
    _escucharEnlaces();
  }

  @override
  void dispose() {
    _suscripcionEnlaces?.cancel();
    super.dispose();
  }

  Future<void> _escucharEnlaces() async {
    final enlaceInicial = await _appLinks.getInitialLink();
    _recibirEnlace(enlaceInicial);
    _suscripcionEnlaces = _appLinks.uriLinkStream.listen(_recibirEnlace);
  }

  void _recibirEnlace(Uri? enlace) {
    if (enlace == null ||
        enlace.scheme != 'https' ||
        enlace.host != Rutas.dominioEnlaces ||
        enlace.pathSegments.length != 2 ||
        enlace.pathSegments.first != 'p') {
      return;
    }
    final id = enlace.pathSegments.last;
    if (!RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    ).hasMatch(id)) {
      return;
    }
    if (mounted) setState(() => _rutaPendiente = '/publicacion/$id');
  }

  void _abrirEnlaceCuandoEsteListo(GoRouter enrutador, bool listo) {
    if (!listo || _rutaPendiente == null || _navegacionProgramada) return;
    _navegacionProgramada = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _rutaPendiente == null) return;
      final ruta = _rutaPendiente!;
      setState(() {
        _rutaPendiente = null;
        _navegacionProgramada = false;
      });
      enrutador.go(ruta);
    });
  }

  @override
  Widget build(BuildContext context) {
    final enrutador = ref.watch(proveedorEnrutador);
    final autenticacion = ref.watch(proveedorAutenticacion);
    final onboarding = ref.watch(proveedorOnboarding);
    _abrirEnlaceCuandoEsteListo(
      enrutador,
      onboarding.valueOrNull == true &&
          !onboarding.isLoading &&
          !autenticacion.isLoading &&
          autenticacion.valueOrNull != null,
    );

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'PetFindr',
      theme: temaPetFindr,
      routerConfig: enrutador,
    );
  }
}
