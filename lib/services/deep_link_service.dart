import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:money_move/main.dart';
import 'package:money_move/screens/join_space_screen.dart';
import 'package:flutter/material.dart' as material;

class DeepLinkService {
  // Instancia única (Singleton) para usarla en toda la app
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  final _appLinks = AppLinks();

  // Aquí guardaremos el código cuando llegue para que la UI lo use
  String? pendingInviteCode;

  // Esta función inicia la escucha
  Future<void> initDeepLinks() async {
    // 1. Escuchar links cuando la app ya está abierta en segundo plano
    _appLinks.uriLinkStream.listen(
      (Uri? uri) {
        if (uri != null) {
          _handleLink(uri);
        }
      },
      onError: (err) {
        if (kDebugMode) print('Error en Deep Link: $err');
      },
    );

    // 2. Escuchar link inicial (cuando la app estaba cerrada y se abre por el link)
    final appLink = await _appLinks.getInitialLink();
    if (appLink != null) {
      _handleLink(appLink);
    }
  }

  // La lógica para procesar el link
  void _handleLink(Uri uri) {
    if (kDebugMode) {
      // print('🔗 Link recibido: $uri');
    }
    // Verificamos si es un link de invitación
    // Buscamos que la ruta contenga "/invite"
    if (uri.path.contains('/invite')) {
      // Extraemos el código "code"
      final code = uri.queryParameters['code'];

      if (code != null) {
        print('✅ Código de invitación detectado: $code');
        pendingInviteCode = code;
        // Usamos la llave para acceder al estado actual del Navigator
        navigatorKey.currentState?.push(
          material.MaterialPageRoute(
            builder: (context) => JoinSpaceScreen(code: code),
          ),
        );
      }
    }
  }
}

class MaterialPageRoute {}
