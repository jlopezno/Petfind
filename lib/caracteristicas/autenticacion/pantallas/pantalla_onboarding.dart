// Onboarding inicial de PetFindr.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../nucleo/constantes/rutas.dart';
import '../proveedores/proveedor_onboarding.dart';

class PantallaOnboarding extends ConsumerStatefulWidget {
  const PantallaOnboarding({super.key});

  @override
  ConsumerState<PantallaOnboarding> createState() => _PantallaOnboardingState();
}

class _PantallaOnboardingState extends ConsumerState<PantallaOnboarding> {
  final _controlador = PageController();
  int _paginaActual = 0;

  static const _paginas = [
    _DatosOnboarding(
      imagen: 'mockups/Onboarding/for_onboarding1.png',
      titulo: 'Ayudanos a ayudar',
      descripcion:
          'Conseguiremos que su mascota reciba la ayuda que necesite mediante nuestra comunidad!',
    ),
    _DatosOnboarding(
      imagen: 'mockups/Onboarding/for_onboarding2.png',
      titulo: 'Encuentra un companero',
      descripcion: 'En esta comunidad podras encontrar a tu fiel amig@.',
    ),
    _DatosOnboarding(
      imagen: 'mockups/Onboarding/for_onboarding3.png.png',
      titulo: 'Apoyo entre todos',
      descripcion: 'Aqui te ayudamos a encontrar a tu mascota perdida.',
    ),
  ];

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  Future<void> _finalizar() async {
    await ref.read(proveedorOnboarding.notifier).completar();
    if (mounted) {
      context.go(Rutas.cargaInicial);
    }
  }

  void _siguiente() {
    if (_paginaActual == _paginas.length - 1) {
      _finalizar();
      return;
    }
    _controlador.nextPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    final esUltimaPagina = _paginaActual == _paginas.length - 1;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F9),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controlador,
                itemCount: _paginas.length,
                onPageChanged: (pagina) {
                  setState(() => _paginaActual = pagina);
                },
                itemBuilder: (context, indice) {
                  final pagina = _paginas[indice];
                  return Column(
                    children: [
                      Expanded(
                        flex: 6,
                        child: Image.asset(
                          pagina.imagen,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Expanded(
                        flex: 5,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 48, 24, 0),
                          child: Column(
                            children: [
                              Text(
                                pagina.titulo,
                                textAlign: TextAlign.center,
                                style: texto.headlineSmall?.copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                pagina.descripcion,
                                textAlign: TextAlign.center,
                                style: texto.bodyMedium?.copyWith(
                                  color: const Color(0xFF8F8F8F),
                                  fontWeight: FontWeight.w800,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            _IndicadoresOnboarding(
              total: _paginas.length,
              paginaActual: _paginaActual,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 48, 20, 28),
              child: Row(
                children: [
                  TextButton(
                    onPressed: _finalizar,
                    child: Text(
                      'Saltar',
                      style: TextStyle(
                        color: esUltimaPagina
                            ? const Color(0xFFD8D8D8)
                            : const Color(0xFF8F8F8F),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _siguiente,
                    child: Text(
                      esUltimaPagina ? 'Empezar' : 'Siguiente',
                      style: const TextStyle(
                        color: Color(0xFF6C4DF6),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IndicadoresOnboarding extends StatelessWidget {
  const _IndicadoresOnboarding({
    required this.total,
    required this.paginaActual,
  });

  final int total;
  final int paginaActual;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (indice) {
        final activo = indice == paginaActual;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: activo ? 10 : 10,
          height: 10,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: activo ? const Color(0xFF6C4DF6) : const Color(0xFFD9D9D9),
          ),
        );
      }),
    );
  }
}

class _DatosOnboarding {
  const _DatosOnboarding({
    required this.imagen,
    required this.titulo,
    required this.descripcion,
  });

  final String imagen;
  final String titulo;
  final String descripcion;
}
