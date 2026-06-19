// Pantalla para registrar duenos y refugios.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../compartido/widgets/widget_boton_primario.dart';
import '../../../nucleo/constantes/rutas.dart';
import '../../../nucleo/utilidades/traductor_error_autenticacion.dart';
import '../../../nucleo/utilidades/validadores.dart';
import '../modelos/modelo_usuario.dart';
import '../proveedores/proveedor_autenticacion.dart';

class PantallaRegistro extends ConsumerStatefulWidget {
  const PantallaRegistro({super.key});

  @override
  ConsumerState<PantallaRegistro> createState() => _PantallaRegistroState();
}

class _PantallaRegistroState extends ConsumerState<PantallaRegistro> {
  final _formulario = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _correo = TextEditingController();
  final _contrasenia = TextEditingController();
  final _confirmar = TextEditingController();
  final _refugio = TextEditingController();
  final _ruc = TextEditingController();
  RolUsuario _rol = RolUsuario.dueno;

  @override
  void dispose() {
    _nombre.dispose();
    _correo.dispose();
    _contrasenia.dispose();
    _confirmar.dispose();
    _refugio.dispose();
    _ruc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cargando = ref.watch(proveedorAutenticacion).isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Registro')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Form(
            key: _formulario,
            child: Column(
              children: [
                TextFormField(
                    controller: _nombre,
                    validator: Validadores.requerido,
                    decoration:
                        const InputDecoration(labelText: 'Nombre completo')),
                const SizedBox(height: 12),
                TextFormField(
                    controller: _correo,
                    validator: Validadores.correo,
                    decoration: const InputDecoration(labelText: 'Correo')),
                const SizedBox(height: 12),
                TextFormField(
                    controller: _contrasenia,
                    validator: Validadores.contrasenia,
                    obscureText: true,
                    decoration:
                        const InputDecoration(labelText: 'Contrasenia')),
                const SizedBox(height: 12),
                TextFormField(
                    controller: _confirmar,
                    obscureText: true,
                    decoration: const InputDecoration(
                        labelText: 'Confirmar contrasenia')),
                const SizedBox(height: 12),
                DropdownButtonFormField<RolUsuario>(
                  initialValue: _rol,
                  decoration:
                      const InputDecoration(labelText: 'Tipo de usuario'),
                  items: const [
                    DropdownMenuItem(
                        value: RolUsuario.dueno, child: Text('Dueno')),
                    DropdownMenuItem(
                        value: RolUsuario.refugio, child: Text('Refugio')),
                  ],
                  onChanged: (valor) => _rol = valor ?? RolUsuario.dueno,
                ),
                const SizedBox(height: 12),
                TextFormField(
                    controller: _refugio,
                    decoration:
                        const InputDecoration(labelText: 'Nombre del refugio')),
                const SizedBox(height: 12),
                TextFormField(
                    controller: _ruc,
                    decoration:
                        const InputDecoration(labelText: 'RUC del refugio')),
                const SizedBox(height: 20),
                WidgetBotonPrimario(
                  texto: cargando ? 'Registrando...' : 'Registrarme',
                  icono: Icons.person_add_alt,
                  onPressed: cargando
                      ? null
                      : () async {
                          if (_contrasenia.text != _confirmar.text) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Las contrasenias no coinciden')));
                            return;
                          }
                          if (_formulario.currentState!.validate()) {
                            await ref
                                .read(proveedorAutenticacion.notifier)
                                .registrar(
                                  nombreCompleto: _nombre.text,
                                  correo: _correo.text,
                                  contrasenia: _contrasenia.text,
                                  rol: _rol,
                                  nombreRefugio: _refugio.text,
                                  rucRefugio: _ruc.text,
                                );
                            final estado = ref.read(proveedorAutenticacion);
                            if (!context.mounted) return;
                            if (estado.hasError) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    TraductorErrorAutenticacion.traducir(
                                      estado.error,
                                    ),
                                  ),
                                ),
                              );
                              return;
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Cuenta creada. Si Supabase pide confirmacion, revisa tu correo.',
                                ),
                              ),
                            );
                            context.go(Rutas.inicioSesion);
                          }
                        },
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: cargando ? null : () => context.go(Rutas.inicioSesion),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Volver al login'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
