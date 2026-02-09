import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

Future<ShareResultStatus> shareInvitationCode(BuildContext context, String code, String link) async {
  print("🥹🥹🥹🥹 entramos a la funcion");
  final String message =
      "Hey! 👋 I'm using Money Move to manage my finances. "
      "Join me using my invitation link:\n\n"
      "$link\n\n"
      "You can also write the code in the secction of 'Shared Space'\n\n"
      "$code\n\n";
  print("🥹🥹🥹🥹 intento compartir");

  final sharePlus = await SharePlus.instance.share(
    ShareParams(
      text: message,
      subject: "Invitation to Money Move",
      sharePositionOrigin: findRenderObject(context),
    ),
  );
  print("🥹🥹🥹🥹 Termine");
  
  return sharePlus.status;
}

// Helper to find the button's position for iPad
Rect? findRenderObject(BuildContext context) {
  final box = context.findRenderObject() as RenderBox?;
  return box != null ? box.localToGlobal(Offset.zero) & box.size : null;
}
