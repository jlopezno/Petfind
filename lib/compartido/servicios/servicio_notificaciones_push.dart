// Gestiona Firebase Cloud Messaging y eventos push enviados desde Supabase.
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'servicio_supabase.dart';

class ResultadoNotificacionPush {
  const ResultadoNotificacionPush({
    required this.ok,
    this.mensaje = '',
  });

  final bool ok;
  final String mensaje;
}

@pragma('vm:entry-point')
Future<void> manejadorMensajesFirebaseEnSegundoPlano(RemoteMessage message) async {
  await Firebase.initializeApp();
}

class ServicioNotificacionesPush {
  ServicioNotificacionesPush._();

  static final instancia = ServicioNotificacionesPush._();

  final FirebaseMessaging _mensajeria = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _inicializado = false;

  Future<void> inicializar() async {
    if (_inicializado) return;

    FirebaseMessaging.onBackgroundMessage(
      manejadorMensajesFirebaseEnSegundoPlano,
    );

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _localNotifications.initialize(initSettings);

    const canal = AndroidNotificationChannel(
      'petfindr_push',
      'PetFindr',
      description: 'Notificaciones de publicaciones, adopciones y apoyos.',
      importance: Importance.high,
    );
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(canal);

    FirebaseMessaging.onMessage.listen(_mostrarNotificacionLocal);
    _inicializado = true;
  }

  Future<void> registrarTokenUsuario(String usuarioId) async {
    await inicializar();
    await _mensajeria.requestPermission();

    final token = await _mensajeria.getToken();
    if (token != null) {
      await _guardarToken(usuarioId, token);
    }

    _mensajeria.onTokenRefresh.listen((nuevoToken) {
      _guardarToken(usuarioId, nuevoToken);
    });
  }

  Future<ResultadoNotificacionPush> notificarPublicacionCreada(
      String publicacionId) {
    return _enviarEvento('post_created', publicacionId);
  }

  Future<ResultadoNotificacionPush> notificarInteresAdopcion(
      String publicacionId) {
    return _enviarEvento('adoption_interest', publicacionId);
  }

  Future<ResultadoNotificacionPush> notificarInteresApoyo(String publicacionId) {
    return _enviarEvento('rescue_support_interest', publicacionId);
  }

  Future<void> _guardarToken(String usuarioId, String token) async {
    try {
      await ServicioSupabase.instancia.cliente.from('fcm_tokens').upsert({
        'user_id': usuarioId,
        'token': token,
        'platform': 'android',
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'token');
    } catch (_) {
      // Si la tabla aun no existe, no bloquea el login.
    }
  }

  Future<ResultadoNotificacionPush> _enviarEvento(
      String evento, String publicacionId) async {
    try {
      final respuesta = await ServicioSupabase.instancia.cliente.functions.invoke(
        'notificaciones-push',
        body: {
          'event': evento,
          'post_id': publicacionId,
        },
      );
      final data = respuesta.data;
      final enviados = data is Map ? data['sent'] : null;
      final ok = respuesta.status >= 200 &&
          respuesta.status < 300 &&
          (enviados == null || enviados != 0);
      return ResultadoNotificacionPush(
        ok: ok,
        mensaje: data?.toString() ?? 'status ${respuesta.status}',
      );
    } catch (error) {
      // La accion principal no debe fallar si la push no esta desplegada.
      return ResultadoNotificacionPush(ok: false, mensaje: error.toString());
    }
  }

  Future<void> _mostrarNotificacionLocal(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'petfindr_push',
          'PetFindr',
          channelDescription:
              'Notificaciones de publicaciones, adopciones y apoyos.',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      payload: message.data['post_id'] as String?,
    );
  }
}
