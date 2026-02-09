import 'package:flutter/material.dart';
import 'package:money_move/l10n/app_localizations.dart';
import 'package:share_plus/share_plus.dart';

Future<ShareResultStatus> shareInvitationCode(
  BuildContext context,
  String code,
  String link,
) async {
  final strings = AppLocalizations.of(context)!;
  print("🥹🥹🥹🥹 entramos a la funcion");
  final String message =
      "${strings.invitationShareText1} "
      "${strings.invitationShareText2}:\n\n"
      "$link\n\n"
      "${strings.invitationShareText3}\n\n"
      "$code\n\n";
  print("🥹🥹🥹🥹 intento compartir");

  final sharePlus = await SharePlus.instance.share(
    ShareParams(
      text: message,
      subject: strings.invitationShareText4,
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
