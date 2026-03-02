import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:money_move/config/app_colors.dart';
import 'package:money_move/l10n/app_localizations.dart';
import 'package:money_move/providers/space_provider.dart';
import 'package:money_move/providers/user_provider.dart';
import 'package:money_move/screens/join_space_screen.dart';
import 'package:money_move/utils/clipboard_utils.dart';
import 'package:money_move/utils/share_invitation_code.dart';
import 'package:money_move/utils/ui_utils.dart';
import 'package:provider/provider.dart';

class SharedIntroScreen extends StatelessWidget {
  const SharedIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final accentColor = const Color(0xFFF59E0B);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final strings = AppLocalizations.of(context)!;
    final spaceProvider = Provider.of<SpaceProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(
        context,
      ).scaffoldBackgroundColor, // Mismo color que la app
      body: SafeArea(
        // Protege contra el notch y la barra de estado
        child: Stack(
          children: [
            // CAPA 1: EL CONTENIDO CENTRADO
            Center(
              child: SingleChildScrollView(
                // Por si la pantalla es muy pequeña
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Tu icono
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.people_alt_outlined,
                        size: 80,
                        color: accentColor,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Título
                    Text(
                      strings.sharedSpaceText,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),

                    // Descripción
                    Text(
                      strings.sharedSpaceLargeDescriptionText,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),

                    userProvider.usuarioActual!.spaceId != null
                        ? Column(
                            children: [
                              Text(
                                strings.alreadyInSharedSpaceText,
                                style: TextStyle(
                                  color: colorScheme.inversePrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _cancelExitSpaceButton(
                                context,
                                strings,
                                colorScheme,
                                spaceProvider,
                                userProvider,
                              ),
                            ],
                          )
                        : _createSpaceButtons(
                            context,
                            spaceProvider,
                            strings,
                            accentColor,
                            colorScheme,
                          ),
                  ],
                ),
              ),
            ),

            // CAPA 2: EL BOTÓN DE ATRÁS (Flotando arriba a la izquierda)
            Positioned(
              top: 10,
              left: 10,
              child: IconButton.filledTonal(
                onPressed: () => Navigator.pop(context),
                style: IconButton.styleFrom(
                  backgroundColor: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.05),
                ),
                icon: Icon(
                  Icons.arrow_back_rounded,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  SizedBox _cancelExitSpaceButton(
    BuildContext context,
    AppLocalizations strings,
    ColorScheme colorScheme,
    SpaceProvider spaceProv,
    UserProvider userProv,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: FilledButton.icon(
        onPressed: () async {
          bool? deleteSpace = await _showDialogExitSpace(
            context,
            strings,
            colorScheme,
          );

          if (deleteSpace == null ||
              deleteSpace == false ||
              userProv.usuarioActual!.spaceId == null) {
            return;
          }

          final exitSpaceStatus = await spaceProv.exitSpace();
          if (!context.mounted) return;
          if (exitSpaceStatus) {
            UiUtils.scaffoldMessengerSnackBar(
              context,
              strings.leftSharedSpaceSuccessText,
              colorScheme.secondary,
            );
          } else {
            UiUtils.scaffoldMessengerSnackBar(
              context,
              strings.errorHasOccurredText,
              colorScheme.error,
            );
          }
        },
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.expense,
          foregroundColor: colorScheme.surface,
        ),
        icon: const Icon(Icons.exit_to_app, size: 24),
        label: Text(
          strings.exitSharedSpaceText,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
      ),
    );
  }

  Future<bool?> _showDialogExitSpace(
    BuildContext context,
    AppLocalizations strings,
    ColorScheme colorScheme,
  ) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(strings.areYouSureExitText),
              SizedBox(height: 10),
              Text(strings.exitSharedSpaceDescriptionText),
              SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FilledButton.icon(
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(
                        colorScheme.onSurface,
                      ),
                    ),
                    onPressed: () {
                      //cancelar
                      Navigator.pop(context, false);
                    },
                    label: Text(
                      strings.cancelText,
                      style: TextStyle(color: colorScheme.surface),
                    ),
                  ),
                  SizedBox(width: 10),
                  FilledButton.icon(
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(
                        AppColors.expense,
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context, true);
                    },
                    label: Text(
                      strings.exitText,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: colorScheme.surface),
                    ),
                    icon: Icon(Icons.exit_to_app),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Column _createSpaceButtons(
    BuildContext context,
    SpaceProvider spaceProvider,
    AppLocalizations strings,
    Color accentColor,
    ColorScheme colorScheme,
  ) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: FilledButton.icon(
            onPressed: () async {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) {
                  return const Center(child: CircularProgressIndicator());
                },
              );

              final invitacion = await spaceProvider.generateInvitacion();

              if (!context.mounted) return;
              Navigator.of(context).pop(); // Esto cierra el diálogo de carga

              // 4. LÓGICA FINAL
              if (invitacion != null) {
                showModalBottomSheet(
                  backgroundColor: colorScheme.surface,
                  showDragHandle: true,
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    // Redondeamos las esquinas de arriba
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(15),
                    ),
                  ),
                  builder: (context) {
                    return Container(
                      margin: EdgeInsets.only(right: 20, left: 20, bottom: 20),
                      child: SingleChildScrollView(
                        physics: BouncingScrollPhysics(),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              strings.invitationCreatedText,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              "${strings.invitationCreatedText}:",
                              style: const TextStyle(fontSize: 20),
                            ),
                            Card(
                              elevation: 6,
                              margin: const EdgeInsets.all(5),
                              color: colorScheme.surfaceContainer,
                              // 1. Clips the ripple effect to the card's rounded corners
                              clipBehavior: Clip.hardEdge,
                              child: InkWell(
                                // 2. InkWell gives the visual "splash" feedback
                                splashColor: colorScheme.primary.withValues(
                                  alpha: 0.1,
                                ),
                                onTap: () async {
                                  await copyToClipboard(
                                    context,
                                    invitacion.codeInvitacion,
                                    message: strings.copiedToClipboardText,
                                  );
                                },
                                child: Padding(
                                  // 3. Padding goes INSIDE InkWell so the ripple covers the whole area
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment
                                        .center, // Center content
                                    children: [
                                      Text(
                                        invitacion.codeInvitacion,
                                        style: TextStyle(
                                          fontSize: 35,
                                          letterSpacing:
                                              4, // Increased slightly for "code" look
                                          fontWeight: FontWeight
                                              .bold, // Makes it pop more
                                          color: colorScheme.onSurface,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 16,
                                      ), // More breathing room
                                      Icon(
                                        Icons.copy,
                                        color: colorScheme
                                            .primary, // Tint the icon for style
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Card(
                              elevation: 5,
                              color: colorScheme.surfaceContainer,
                              // 1. Clips the ripple effect to the card's rounded corners
                              clipBehavior: Clip.hardEdge,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: QrImageView(
                                  data: invitacion.linkInvitacion,
                                  version: QrVersions.auto,
                                  size: 320,
                                  backgroundColor: colorScheme
                                      .surface, // Fundamental para modo oscuro
                                  eyeStyle: QrEyeStyle(
                                    eyeShape: QrEyeShape.square,
                                    color: colorScheme.onSurface,
                                  ),
                                  dataModuleStyle: QrDataModuleStyle(
                                    dataModuleShape: QrDataModuleShape.square,
                                    color: colorScheme.onSurface,
                                  ),
                                  errorCorrectionLevel: QrErrorCorrectLevel.H,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.copy),
                                  label: Text(strings.copyLinkText),
                                  onPressed: () async {
                                    await copyToClipboard(
                                      context,
                                      invitacion.linkInvitacion,
                                      message: strings.copiedToClipboardText,
                                    );
                                  },
                                ),
                                Spacer(),
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.share_rounded),
                                  label: Text(strings.shareInvitationText),
                                  onPressed: () async {
                                    print("🥹🥹🥹🥹 empezando");
                                    final result = await shareInvitationCode(
                                      context,
                                      invitacion.codeInvitacion,
                                      invitacion.linkInvitacion,
                                    );
                                    print("🥹🥹🥹🥹 que paso?");

                                    if (result == ShareResultStatus.success) {
                                      print(
                                        '😊🙂🤨🫤😖🥹🤢Thank you for sharing the picture!',
                                      );
                                    } else {
                                      print("something went wrong🤢🤢🤢🤢");
                                    }
                                  },
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                          ],
                        ),
                      ),
                    );
                  },
                );
                print(
                  "${strings.invitationCreatedText}: ${invitacion.codeInvitacion}",
                );
              } else {
                // ❌ ERROR:
                // Puedes mostrar un snackbar o una alerta de error
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(strings.errorCreatingInvitationText)),
                );
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.link, size: 24),
            label: Text(
              strings.inviteSomeoneText,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Botón Secundario
        TextButton(
          onPressed: () async {
            final String code = await _showInputDialog(context, strings);

            if (code.isEmpty) return;
            if (!context.mounted) return;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => JoinSpaceScreen(code: code),
              ),
            );
          },
          child: Text(
            strings.uHaveCodeEnterHere,
            style: TextStyle(color: accentColor),
          ),
        ),
      ],
    );
  }
}

Future<String> _showInputDialog(
  BuildContext context,
  AppLocalizations strings,
) async {
  String tempCode = ""; // Variable temporal

  // 1. AWAIT: Esperamos a que el diálogo se cierre y nos devuelva un valor
  final result = await showDialog<String>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(strings.enterInviteCodeText),
        content: TextField(
          autofocus: true, // Para que el teclado salga automático
          onChanged: (value) {
            tempCode = value; // Guardamos lo que escribe
          },
          decoration: InputDecoration(hintText: strings.inviteCodeHintText),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Cierra sin devolver nada (null)
            },
            child: Text(strings.cancelText),
          ),
          TextButton(
            onPressed: () {
              // Devolvemos el código escrito al cerrar
              Navigator.pop(context, tempCode);
            },
            child: Text(strings.okText),
          ),
        ],
      );
    },
  );

  // Devolvemos el resultado o vacío si canceló
  return result ?? "";
}
