// Encapsula acceso al cliente Supabase.
import 'package:supabase_flutter/supabase_flutter.dart';

class ServicioSupabase {
  ServicioSupabase._();

  static final instancia = ServicioSupabase._();

  SupabaseClient get cliente => Supabase.instance.client;
}
