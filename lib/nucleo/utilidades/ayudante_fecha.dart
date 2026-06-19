// Ofrece utilidades de fecha para UI y recordatorios.
import 'package:intl/intl.dart';

class AyudanteFecha {
  const AyudanteFecha._();

  static final _formatoCorto = DateFormat('dd/MM/yyyy', 'es_PE');

  static String fechaCorta(DateTime fecha) => _formatoCorto.format(fecha);

  static String saludo(DateTime ahora) {
    if (ahora.hour < 12) return 'Buenos dias';
    if (ahora.hour < 19) return 'Buenas tardes';
    return 'Buenas noches';
  }

  static String estadoVacuna(DateTime? siguiente) {
    if (siguiente == null) return 'Al dia';
    final dias = siguiente.difference(DateTime.now()).inDays;
    if (dias < 0) return 'Vencida';
    if (dias <= 30) return 'Proxima';
    return 'Al dia';
  }
}
