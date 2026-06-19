// Controla si el onboarding inicial ya fue visto en este dispositivo.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final proveedorOnboarding =
    AsyncNotifierProvider<ProveedorOnboarding, bool>(ProveedorOnboarding.new);

class ProveedorOnboarding extends AsyncNotifier<bool> {
  static const _claveOnboardingCompletado = 'onboarding_completado';

  @override
  Future<bool> build() async {
    final preferencias = await SharedPreferences.getInstance();
    return preferencias.getBool(_claveOnboardingCompletado) ?? false;
  }

  Future<void> completar() async {
    final preferencias = await SharedPreferences.getInstance();
    await preferencias.setBool(_claveOnboardingCompletado, true);
    state = const AsyncData(true);
  }
}
