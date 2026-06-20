// Pantalla para registrar duenos y refugios.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
  bool _mostrarContrasenia = false;
  bool _mostrarConfirmacion = false;

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

  Future<void> _registrar() async {
    if (_contrasenia.text != _confirmar.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Las contrasenias no coinciden')),
      );
      return;
    }
    if (!_formulario.currentState!.validate()) return;

    await ref.read(proveedorAutenticacion.notifier).registrar(
          nombreCompleto: _nombre.text,
          correo: _correo.text,
          contrasenia: _contrasenia.text,
          rol: _rol,
          nombreRefugio: _refugio.text,
          rucRefugio: _ruc.text,
        );
    final estado = ref.read(proveedorAutenticacion);
    if (!mounted) return;
    if (estado.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(TraductorErrorAutenticacion.traducir(estado.error)),
        ),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cuenta creada. Revisa tu correo para confirmarla.'),
      ),
    );
    context.go(Rutas.inicioSesion);
  }

  @override
  Widget build(BuildContext context) {
    final cargando = ref.watch(proveedorAutenticacion).isLoading;
    final esRefugio = _rol == RolUsuario.refugio;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F7),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Form(
            key: _formulario,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: cargando
                        ? null
                        : () => context.go(Rutas.inicioSesion),
                    icon: const Icon(Icons.chevron_left, size: 30),
                    padding: EdgeInsets.zero,
                    constraints:
                        const BoxConstraints.tightFor(width: 40, height: 40),
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  'Crea tu cuenta',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Unete a la comunidad que ayuda a las mascotas a volver a casa.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF949494),
                        fontWeight: FontWeight.w700,
                        height: 1.45,
                      ),
                ),
                const SizedBox(height: 32),
                const _EtiquetaCampo(texto: 'Nombre completo'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nombre,
                  validator: Validadores.requerido,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  decoration: _decoracionCampo(hintText: 'Como te llamamos?'),
                ),
                const SizedBox(height: 20),
                const _EtiquetaCampo(texto: 'Correo electronico'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _correo,
                  validator: Validadores.correo,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: _decoracionCampo(hintText: 'tu@correo.com'),
                ),
                const SizedBox(height: 20),
                const _EtiquetaCampo(texto: 'Contrasenia'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _contrasenia,
                  validator: Validadores.contrasenia,
                  obscureText: !_mostrarContrasenia,
                  textInputAction: TextInputAction.next,
                  decoration: _decoracionCampo(
                    hintText: 'Crea una contrasenia segura',
                    suffixIcon: IconButton(
                      tooltip: _mostrarContrasenia
                          ? 'Ocultar contrasenia'
                          : 'Mostrar contrasenia',
                      onPressed: () => setState(
                        () => _mostrarContrasenia = !_mostrarContrasenia,
                      ),
                      icon: Icon(
                        _mostrarContrasenia
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: const Color(0xFF6C4DF6),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const _EtiquetaCampo(texto: 'Confirmar contrasenia'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _confirmar,
                  obscureText: !_mostrarConfirmacion,
                  textInputAction: TextInputAction.next,
                  decoration: _decoracionCampo(
                    hintText: 'Repite tu contrasenia',
                    suffixIcon: IconButton(
                      tooltip: _mostrarConfirmacion
                          ? 'Ocultar contrasenia'
                          : 'Mostrar contrasenia',
                      onPressed: () => setState(
                        () => _mostrarConfirmacion = !_mostrarConfirmacion,
                      ),
                      icon: Icon(
                        _mostrarConfirmacion
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: const Color(0xFF6C4DF6),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                const _EtiquetaCampo(texto: 'Como deseas participar?'),
                const SizedBox(height: 10),
                _SelectorRol(
                  rol: _rol,
                  onChanged: (rol) => setState(() => _rol = rol),
                ),
                if (esRefugio) ...[
                  const SizedBox(height: 24),
                  const _EtiquetaCampo(texto: 'Nombre del refugio'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _refugio,
                    validator: Validadores.requerido,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    decoration: _decoracionCampo(
                      hintText: 'Nombre de tu organizacion',
                    ),
                  ),
                  const SizedBox(height: 20),
                  const _EtiquetaCampo(texto: 'RUC del refugio'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _ruc,
                    validator: Validadores.requerido,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    decoration: _decoracionCampo(hintText: 'Numero de RUC'),
                  ),
                ],
                const SizedBox(height: 36),
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
                    onPressed: cargando ? null : _registrar,
                    child: Text(cargando ? 'Creando cuenta...' : 'Crear cuenta'),
                  ),
                ),
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Ya tienes cuenta? ',
                      style: TextStyle(
                        color: Color(0xFF949494),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    TextButton(
                      onPressed: cargando
                          ? null
                          : () => context.go(Rutas.inicioSesion),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Iniciar sesion',
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
    );
  }

  InputDecoration _decoracionCampo({
    required String hintText,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        color: Color(0xFFABABAD),
        fontWeight: FontWeight.w600,
      ),
      filled: true,
      fillColor: const Color(0xFFE8E8E9),
      contentPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
      suffixIcon: suffixIcon,
      border: _bordeCampo(),
      enabledBorder: _bordeCampo(),
      focusedBorder: _bordeCampo(
        const BorderSide(color: Color(0xFF6C4DF6), width: 1.4),
      ),
      errorBorder: _bordeCampo(
        BorderSide(color: Theme.of(context).colorScheme.error),
      ),
      focusedErrorBorder: _bordeCampo(
        BorderSide(color: Theme.of(context).colorScheme.error),
      ),
    );
  }

  OutlineInputBorder _bordeCampo([BorderSide lado = BorderSide.none]) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: lado,
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

class _SelectorRol extends StatelessWidget {
  const _SelectorRol({required this.rol, required this.onChanged});

  final RolUsuario rol;
  final ValueChanged<RolUsuario> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _OpcionRol(
            titulo: 'Persona',
            icono: Icons.person_outline_rounded,
            seleccionada: rol == RolUsuario.dueno,
            onTap: () => onChanged(RolUsuario.dueno),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _OpcionRol(
            titulo: 'Refugio',
            icono: Icons.home_work_outlined,
            seleccionada: rol == RolUsuario.refugio,
            onTap: () => onChanged(RolUsuario.refugio),
          ),
        ),
      ],
    );
  }
}

class _OpcionRol extends StatelessWidget {
  const _OpcionRol({
    required this.titulo,
    required this.icono,
    required this.seleccionada,
    required this.onTap,
  });

  final String titulo;
  final IconData icono;
  final bool seleccionada;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const morado = Color(0xFF6C4DF6);
    return Material(
      color: seleccionada ? const Color(0xFFEDE9FF) : const Color(0xFFE8E8E9),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: 86,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: seleccionada ? morado : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icono, color: seleccionada ? morado : const Color(0xFF8F8F8F)),
              const SizedBox(height: 6),
              Text(
                titulo,
                style: TextStyle(
                  color: seleccionada ? morado : const Color(0xFF6F6F71),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
