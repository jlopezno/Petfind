// Pantalla de confirmacion animada al guardar una publicacion.
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../nucleo/constantes/rutas.dart';
import '../modelos/modelo_publicacion.dart';

class PantallaPublicacionGuardada extends StatefulWidget {
  const PantallaPublicacionGuardada({super.key, required this.tipo});

  final TipoPublicacion tipo;

  @override
  State<PantallaPublicacionGuardada> createState() =>
      _PantallaPublicacionGuardadaState();
}

class _PantallaPublicacionGuardadaState
    extends State<PantallaPublicacionGuardada> {
  static const _morado = Color(0xFF6C4DF6);

  bool _expandido = false;
  bool _mostrarContenido = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _expandido = true);
      Future.delayed(const Duration(milliseconds: 520), () {
        if (mounted) setState(() => _mostrarContenido = true);
      });
      Future.delayed(const Duration(milliseconds: 2600), () {
        if (mounted) context.go(Rutas.feed);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final circuloFinal = size.longestSide * 1.7;
    final mensaje = _mensaje(widget.tipo);

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 680),
              curve: Curves.easeOutCubic,
              width: _expandido ? circuloFinal : 0,
              height: _expandido ? circuloFinal : 0,
              decoration: const BoxDecoration(
                color: _morado,
                shape: BoxShape.circle,
              ),
            ),
            SafeArea(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 420),
                opacity: _mostrarContenido ? 1 : 0,
                child: AnimatedScale(
                  duration: const Duration(milliseconds: 420),
                  curve: Curves.easeOutBack,
                  scale: _mostrarContenido ? 1 : .82,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 112,
                          height: 112,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: .12),
                                blurRadius: 28,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.pets,
                            color: _morado,
                            size: 58,
                          ),
                        ),
                        const SizedBox(height: 28),
                        Text(
                          mensaje.titulo,
                          textAlign: TextAlign.center,
                          style:
                              Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0,
                                  ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          mensaje.descripcion,
                          textAlign: TextAlign.center,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.white.withValues(alpha: .88),
                                    fontWeight: FontWeight.w700,
                                    height: 1.35,
                                  ),
                        ),
                        const SizedBox(height: 34),
                        const SizedBox(
                          width: 30,
                          height: 30,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _MensajeConfirmacion _mensaje(TipoPublicacion tipo) => switch (tipo) {
        TipoPublicacion.perdido => const _MensajeConfirmacion(
            titulo: 'Estamos para ayudarte',
            descripcion:
                'Tu busqueda quedo registrada y esta pendiente de aprobacion.',
          ),
        TipoPublicacion.adopcion => const _MensajeConfirmacion(
            titulo: 'Gracias por dar una oportunidad',
            descripcion:
                'Tu publicacion de adopcion esta pendiente de aprobacion.',
          ),
        TipoPublicacion.rescatado => const _MensajeConfirmacion(
            titulo: 'Tu apoyo puede cambiarlo todo',
            descripcion:
                'El caso de rescate quedo pendiente de aprobacion.',
          ),
      };
}

class _MensajeConfirmacion {
  const _MensajeConfirmacion({
    required this.titulo,
    required this.descripcion,
  });

  final String titulo;
  final String descripcion;
}
