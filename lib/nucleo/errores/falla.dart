// Define fallas de dominio para mostrar errores claros al usuario.
sealed class Falla implements Exception {
  const Falla(this.mensaje);

  final String mensaje;

  @override
  String toString() => mensaje;
}

class FallaRed extends Falla {
  const FallaRed(super.mensaje);
}

class FallaServidor extends Falla {
  const FallaServidor(super.mensaje, {this.codigo});

  final int? codigo;
}

class FallaAutenticacion extends Falla {
  const FallaAutenticacion(super.mensaje);
}

class FallaValidacion extends Falla {
  const FallaValidacion(super.mensaje);
}
