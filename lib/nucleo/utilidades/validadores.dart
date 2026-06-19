// Reune validadores de formularios usados por las pantallas.
class Validadores {
  const Validadores._();

  static String? requerido(String? valor) {
    if (valor == null || valor.trim().isEmpty) return 'Este campo es obligatorio';
    return null;
  }

  static String? correo(String? valor) {
    final texto = valor?.trim() ?? '';
    if (texto.isEmpty) return 'Ingresa tu correo';
    if (!texto.contains('@')) return 'Correo no valido';
    return null;
  }

  static String? contrasenia(String? valor) {
    if ((valor ?? '').length < 6) return 'Minimo 6 caracteres';
    return null;
  }
}
