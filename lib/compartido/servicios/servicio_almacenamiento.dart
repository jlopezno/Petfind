// Maneja subida y eliminacion de fotos en Supabase Storage.
import 'dart:io';

import 'servicio_supabase.dart';

class ServicioAlmacenamiento {
  const ServicioAlmacenamiento();

  Future<String> subirFoto(String bucket, File archivo) async {
    final nombre = '${DateTime.now().microsecondsSinceEpoch}_${archivo.uri.pathSegments.last}';
    await ServicioSupabase.instancia.cliente.storage.from(bucket).upload(nombre, archivo);
    return ServicioSupabase.instancia.cliente.storage.from(bucket).getPublicUrl(nombre);
  }

  Future<void> eliminarFoto(String bucket, String ruta) async {
    await ServicioSupabase.instancia.cliente.storage.from(bucket).remove([ruta]);
  }
}
