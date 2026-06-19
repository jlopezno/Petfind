// Pantalla para iniciar sesion con Supabase Auth.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../nucleo/constantes/rutas.dart';
import '../../../nucleo/utilidades/traductor_error_autenticacion.dart';
import '../../../nucleo/utilidades/validadores.dart';
import '../proveedores/proveedor_autenticacion.dart';

class PantallaInicioSesion extends ConsumerStatefulWidget {
  const PantallaInicioSesion({super.key});

  @override
  ConsumerState<PantallaInicioSesion> createState() =>
      _PantallaInicioSesionState();
}

class _PantallaInicioSesionState extends ConsumerState<PantallaInicioSesion> {
  static const _claveRecordarCuenta = 'recordar_cuenta_login';
  static const _claveCorreoRecordado = 'correo_login_recordado';

  final _formulario = GlobalKey<FormState>();
  final _correo = TextEditingController();
  final _contrasenia = TextEditingController();
  final _recordarCuenta = ValueNotifier<bool>(false);
  final _mostrarContrasenia = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _cargarCuentaRecordada();
  }

  @override
  void dispose() {
    _correo.dispose();
    _contrasenia.dispose();
    _recordarCuenta.dispose();
    _mostrarContrasenia.dispose();
    super.dispose();
  }

  Future<void> _cargarCuentaRecordada() async {
    final preferencias = await SharedPreferences.getInstance();
    final recordar = preferencias.getBool(_claveRecordarCuenta) ?? false;
    final correo = preferencias.getString(_claveCorreoRecordado);

    _recordarCuenta.value = recordar;
    if (recordar && correo != null && correo.isNotEmpty) {
      _correo.text = correo;
    }
  }

  Future<void> _guardarCuentaRecordada() async {
    final preferencias = await SharedPreferences.getInstance();
    final recordar = _recordarCuenta.value;
    await preferencias.setBool(_claveRecordarCuenta, recordar);

    if (recordar) {
      await preferencias.setString(
        _claveCorreoRecordado,
        _correo.text.trim(),
      );
    } else {
      await preferencias.remove(_claveCorreoRecordado);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(proveedorAutenticacion, (anterior, siguiente) async {
      if (siguiente.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
                Text(TraductorErrorAutenticacion.traducir(siguiente.error))));
      }
      if (siguiente.valueOrNull != null) {
        await _guardarCuentaRecordada();
        if (context.mounted) {
          context.go(Rutas.inicio);
        }
      }
    });

    final cargando = ref.watch(proveedorAutenticacion).isLoading;
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F7),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.sizeOf(context).height -
                  MediaQuery.paddingOf(context).top -
                  MediaQuery.paddingOf(context).bottom -
                  52,
            ),
            child: Form(
              key: _formulario,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () => context.go(Rutas.inicioSesion),
                      icon: const Icon(Icons.chevron_left, size: 30),
                      padding: EdgeInsets.zero,
                      constraints:
                          const BoxConstraints.tightFor(width: 40, height: 40),
                    ),
                  ),
                  const SizedBox(height: 38),
                  Text(
                    'Iniciar Sesion',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Ingrese sus credenciales para acceder a su cuenta',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF949494),
                          fontWeight: FontWeight.w700,
                          height: 1.45,
                        ),
                  ),
                  const SizedBox(height: 46),
                  _EtiquetaCampo(texto: 'Correo electronico'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _correo,
                    validator: Validadores.correo,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                    decoration: _decoracionCampo(),
                  ),
                  const SizedBox(height: 26),
                  _EtiquetaCampo(texto: 'Contrasenia'),
                  const SizedBox(height: 8),
                  ValueListenableBuilder<bool>(
                    valueListenable: _mostrarContrasenia,
                    builder: (context, mostrarContrasenia, _) {
                      return TextFormField(
                        controller: _contrasenia,
                        validator: Validadores.contrasenia,
                        obscureText: !mostrarContrasenia,
                        textInputAction: TextInputAction.done,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                        decoration: _decoracionCampo(
                          suffixIcon: IconButton(
                            tooltip: mostrarContrasenia
                                ? 'Ocultar contrasenia'
                                : 'Mostrar contrasenia',
                            icon: Icon(
                              mostrarContrasenia
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: const Color(0xFF6C4DF6),
                            ),
                            onPressed: () {
                              _mostrarContrasenia.value = !mostrarContrasenia;
                            },
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      ValueListenableBuilder<bool>(
                        valueListenable: _recordarCuenta,
                        builder: (context, recordar, _) {
                          return Checkbox(
                            value: recordar,
                            activeColor: const Color(0xFF6C4DF6),
                            visualDensity: VisualDensity.compact,
                            onChanged: (valor) {
                              _recordarCuenta.value = valor ?? false;
                            },
                          );
                        },
                      ),
                      const Expanded(
                        child: Text(
                          'Recordar cuenta',
                          style: TextStyle(
                            color: Color(0xFF949494),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () =>
                          ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Recuperacion de contrasenia pendiente')),
                      ),
                      child: const Text(
                        'Olvidaste tu contrasenia?',
                        style: TextStyle(
                          color: Color(0xFF6C4DF6),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 76),
                  SizedBox(
                    height: 60,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF6C4DF6),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      onPressed: cargando
                          ? null
                          : () {
                              if (_formulario.currentState!.validate()) {
                                ref
                                    .read(proveedorAutenticacion.notifier)
                                    .iniciarSesion(
                                        _correo.text, _contrasenia.text);
                              }
                            },
                      child: Text(cargando ? 'Ingresando...' : 'Ingresar'),
                    ),
                  ),
                  const SizedBox(height: 96),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'No tienes cuenta? ',
                        style: TextStyle(
                          color: Color(0xFF949494),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      TextButton(
                        onPressed:
                            cargando ? null : () => context.go(Rutas.registro),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'Crear Cuenta',
                          style: TextStyle(
                            color: Color(0xFF6C4DF6),
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _decoracionCampo({Widget? suffixIcon}) {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xFFE8E8E9),
      contentPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFF6C4DF6), width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
      ),
    );
  }
}

class _EtiquetaCampo extends StatelessWidget {
  const _EtiquetaCampo({required this.texto});

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Text(
      texto,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: const Color(0xFF8F8F8F),
            fontWeight: FontWeight.w900,
          ),
    );
  }
}
