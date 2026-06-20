// Configura la navegacion con go_router.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../caracteristicas/autenticacion/pantallas/pantalla_carga_inicial.dart';
import '../caracteristicas/autenticacion/pantallas/pantalla_inicio_sesion.dart';
import '../caracteristicas/autenticacion/pantallas/pantalla_onboarding.dart';
import '../caracteristicas/autenticacion/pantallas/pantalla_registro.dart';
import '../caracteristicas/autenticacion/proveedores/proveedor_autenticacion.dart';
import '../caracteristicas/autenticacion/proveedores/proveedor_onboarding.dart';
import '../caracteristicas/avistamientos/pantallas/pantalla_reportar_avistamiento.dart';
import '../caracteristicas/mapa/pantallas/pantalla_mapa.dart';
import '../caracteristicas/mascotas/pantallas/pantalla_agregar_mascota.dart';
import '../caracteristicas/mascotas/pantallas/pantalla_detalle_mascota.dart';
import '../caracteristicas/perfil/pantallas/pantalla_perfil.dart';
import '../caracteristicas/publicaciones/modelos/modelo_publicacion.dart';
import '../caracteristicas/publicaciones/pantallas/pantalla_admin_pendientes.dart';
import '../caracteristicas/publicaciones/pantallas/pantalla_adoptar.dart';
import '../caracteristicas/publicaciones/pantallas/pantalla_crear_publicacion.dart';
import '../caracteristicas/publicaciones/pantallas/pantalla_detalle_publicacion.dart';
import '../caracteristicas/publicaciones/pantallas/pantalla_feed.dart';
import '../caracteristicas/publicaciones/pantallas/pantalla_publicacion_guardada.dart';
import '../nucleo/constantes/rutas.dart';

final proveedorEnrutador = Provider<GoRouter>((ref) {
  final autenticacion = ref.watch(proveedorAutenticacion);
  final onboarding = ref.watch(proveedorOnboarding);
  return GoRouter(
    initialLocation: Rutas.cargaInicial,
    redirect: (_, state) {
      final ruta = state.uri.path;
      final estaCargandoOnboarding = onboarding.isLoading;
      final onboardingCompletado = onboarding.valueOrNull ?? false;
      final estaCargando = autenticacion.isLoading;
      final estaAutenticado = autenticacion.valueOrNull != null;
      final estaEnCarga = ruta == Rutas.cargaInicial;
      final estaEnOnboarding = ruta == Rutas.onboarding;
      final estaEnAuth = ruta == Rutas.inicioSesion || ruta == Rutas.registro;

      if (estaCargandoOnboarding) {
        return estaEnCarga ? null : Rutas.cargaInicial;
      }
      if (!onboardingCompletado) {
        return estaEnOnboarding ? null : Rutas.onboarding;
      }
      if (estaEnOnboarding) return Rutas.cargaInicial;
      if (estaCargando) return estaEnCarga ? null : Rutas.cargaInicial;
      if (estaAutenticado && (estaEnCarga || estaEnAuth || ruta == Rutas.raiz)) {
        return Rutas.inicio;
      }
      if (!estaAutenticado && estaEnCarga) return Rutas.inicioSesion;
      return null;
    },
    routes: [
      GoRoute(path: Rutas.raiz, redirect: (_, __) => Rutas.cargaInicial),
      GoRoute(
          path: Rutas.cargaInicial,
          builder: (_, __) => const PantallaCargaInicial()),
      GoRoute(
          path: Rutas.onboarding,
          builder: (_, __) => const PantallaOnboarding()),
      GoRoute(
          path: Rutas.inicioSesion,
          builder: (_, __) => const PantallaInicioSesion()),
      GoRoute(
          path: Rutas.registro, builder: (_, __) => const PantallaRegistro()),
      ShellRoute(
        builder: (_, __, child) => PantallaInicioDueno(child: child),
        routes: [
          GoRoute(
            path: Rutas.inicio,
            builder: (_, __) => const PantallaFeed(),
            routes: [
              GoRoute(path: 'feed', builder: (_, __) => const PantallaFeed()),
              GoRoute(path: 'mapa', builder: (_, __) => const PantallaMapa()),
              GoRoute(
                  path: 'adoptar',
                  builder: (_, __) => const PantallaAdoptar()),
              GoRoute(
                  path: 'admin-pendientes',
                  builder: (_, __) => const PantallaAdminPendientes()),
              GoRoute(
                  path: 'perfil', builder: (_, __) => const PantallaPerfil()),
            ],
          ),
        ],
      ),
      GoRoute(
          path: Rutas.agregarMascota,
          builder: (_, __) => const PantallaAgregarMascota()),
      GoRoute(
          path: '/mascota/:id',
          builder: (_, state) =>
              PantallaDetalleMascota(id: state.pathParameters['id']!)),
      GoRoute(
          path: Rutas.crearPublicacion,
          builder: (_, __) => const PantallaCrearPublicacion()),
      GoRoute(
          path: '${Rutas.editarPublicacion}/:id',
          builder: (_, state) => PantallaCrearPublicacion(
              publicacionId: state.pathParameters['id'])),
      GoRoute(
          path: '${Rutas.publicacionGuardada}/:tipo',
          builder: (_, state) => PantallaPublicacionGuardada(
                tipo: TipoPublicacion.fromString(
                    state.pathParameters['tipo'] ?? 'lost'),
              )),
      GoRoute(
          path: '/publicacion/:id',
          builder: (_, state) =>
              PantallaDetallePublicacion(id: state.pathParameters['id']!)),
      GoRoute(
          path: '/avistamiento/:postId',
          builder: (_, state) => PantallaReportarAvistamiento(
              postId: state.pathParameters['postId']!)),
      GoRoute(
          path: '/vacunas/:mascotaId',
          builder: (_, state) =>
              PantallaDetalleMascota(id: state.pathParameters['mascotaId']!)),
      GoRoute(
          path: '/perfil/:usuarioId',
          builder: (_, state) =>
              PantallaPerfil(usuarioId: state.pathParameters['usuarioId'])),
    ],
  );
});

class PantallaInicioDueno extends ConsumerWidget {
  const PantallaInicioDueno({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final esAdmin =
        ref.watch(proveedorAutenticacion).valueOrNull?.esAdmin ?? false;
    final ruta = GoRouterState.of(context).uri.path;
    final indice = ruta == Rutas.mapa
        ? 1
        : ruta == Rutas.adoptar
            ? 2
            : ruta == Rutas.adminPendientes && esAdmin
                ? 3
            : ruta == Rutas.perfil
                ? esAdmin
                    ? 4
                    : 3
                : 0;
    final destinos = <NavigationDestination>[
      const NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Inicio'),
      const NavigationDestination(
          icon: Icon(Icons.map_outlined),
          selectedIcon: Icon(Icons.map),
          label: 'Mapa'),
      const NavigationDestination(
          icon: Icon(Icons.favorite_border),
          selectedIcon: Icon(Icons.favorite),
          label: 'Adoptar'),
      if (esAdmin)
        const NavigationDestination(
            icon: Icon(Icons.fact_check_outlined),
            selectedIcon: Icon(Icons.fact_check),
            label: 'Revision'),
      const NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Perfil'),
    ];
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: indice,
        onDestinationSelected: (valor) {
          final destino = esAdmin
              ? switch (valor) {
                  0 => Rutas.feed,
                  1 => Rutas.mapa,
                  2 => Rutas.adoptar,
                  3 => Rutas.adminPendientes,
                  _ => Rutas.perfil,
                }
              : switch (valor) {
                  0 => Rutas.feed,
                  1 => Rutas.mapa,
                  2 => Rutas.adoptar,
                  _ => Rutas.perfil,
                };
          context.go(destino);
        },
        destinations: destinos,
      ),
    );
  }
}
