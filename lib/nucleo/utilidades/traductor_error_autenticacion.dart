// Traduce errores tecnicos de Supabase Auth a mensajes para el usuario.
class TraductorErrorAutenticacion {
  const TraductorErrorAutenticacion._();

  static String traducir(Object? error) {
    final texto = error.toString().toLowerCase();

    if (texto.contains('email_not_confirmed') ||
        texto.contains('email not confirmed')) {
      return 'Tu correo aun no esta confirmado. Revisa tu bandeja de entrada o desactiva la confirmacion de correo para pruebas.';
    }

    if (texto.contains('invalid_credentials') ||
        texto.contains('invalid login credentials')) {
      return 'Correo o contrasenia incorrectos.';
    }

    if (texto.contains('over_email_send_rate_limit') ||
        texto.contains('email rate limit exceeded') ||
        texto.contains('rate limit exceeded') ||
        texto.contains('only request this after')) {
      return 'Supabase limito temporalmente el envio de correos. Espera unos minutos antes de registrar otra cuenta.';
    }

    if (texto.contains('user_already_exists') ||
        texto.contains('already registered')) {
      return 'Este correo ya esta registrado. Inicia sesion o usa otro correo.';
    }

    return 'No se pudo completar la autenticacion. Intenta nuevamente.';
  }
}
