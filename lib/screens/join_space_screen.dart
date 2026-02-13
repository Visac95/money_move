import 'package:flutter/material.dart';
import 'package:money_move/l10n/app_localizations.dart';
import 'package:money_move/models/invitacion.dart';
import 'package:money_move/models/user_model.dart';
import 'package:money_move/providers/space_provider.dart';
import 'package:money_move/providers/user_provider.dart';
import 'package:money_move/screens/main_screen.dart';
import 'package:provider/provider.dart';

class JoinSpaceScreen extends StatelessWidget {
  final String code;
  const JoinSpaceScreen({super.key, required this.code});

  // 1. CREAMOS ESTA FUNCIÓN AUXILIAR PARA TRAER TODO JUNTO
  Future<(Invitacion?, InvitacionStatus, UserModel?)> _fetchFullData(
    BuildContext context,
  ) async {
    final spaceProv = Provider.of<SpaceProvider>(context, listen: false);
    final userProv = Provider.of<UserProvider>(context, listen: false);

    // A. Buscamos la invitación
    final (invitacion, status) = await spaceProv.getInvitacionByCode(code);

    // B. Si la invitación es válida, buscamos al creador
    UserModel? creatorUser;
    if (status == InvitacionStatus.success && invitacion != null) {
      creatorUser = await userProv.getUserByUid(invitacion.creatorId);
    }

    // C. Devolvemos las 3 cosas juntas
    return (invitacion, status, creatorUser);
  }

  @override
  Widget build(BuildContext context) {
    // Nota: Ya no necesitamos los providers aquí arriba para el Future,
    // los usamos dentro de la función auxiliar.
    final colorScheme = Theme.of(context).colorScheme;
    final userProv = Provider.of<UserProvider>(context, listen: false);
    final strings = AppLocalizations.of(context)!;
    final spaceProv = Provider.of<SpaceProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: Text(strings.joinSpaceText)),

      // 2. CAMBIAMOS EL TIPO DEL FUTURE BUILDER PARA QUE ACEPTE 3 COSAS
      body: FutureBuilder<(Invitacion?, InvitacionStatus, UserModel?)>(
        future: _fetchFullData(context), // Llamamos a nuestra función combinada

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text("Ocurrió un error al cargar"));
          }

          // 3. DESEMPAQUETAMOS LAS 3 COSAS (invitación, estatus y usuario)
          final (invitacion, status, guestUser) = snapshot.data!;

          if (status == InvitacionStatus.success && invitacion != null) {
            // ¡YA TIENES EL GUEST USER AQUÍ! NO NECESITAS AWAIT

            return Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Tu UI bonita aquí
                      Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: colorScheme.inversePrimary.withAlpha(30),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.center, // Centrar el Row
                              children: [
                                _profilePhoto(
                                  colorScheme,
                                  guestUser,
                                  colorScheme.inversePrimary,
                                ),
                                const SizedBox(width: 25),
                                Icon(Icons.handshake, size: 50),
                                const SizedBox(width: 25),
                                _profilePhoto(
                                  colorScheme,
                                  userProv.usuarioActual,
                                  colorScheme.primary,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        guestUser!.name,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        strings.invitationMessageText,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 20),
                      Text(
                        strings.acceptInvitationAlertText,
                        style: TextStyle(
                          fontSize: 16,
                          color: colorScheme.outline,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),

                      //---------Boton------------
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: FilledButton.icon(
                          onPressed: () async {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              },
                            );

                            final invitacion = await spaceProv.joinSpace(code);

                            if (!context.mounted) return;
                            Navigator.of(
                              context,
                            ).pop(); // Esto cierra el diálogo de carga
                            final String mensaje;
                            switch (invitacion) {
                              case InvitacionStatus.noUser:
                                mensaje = strings.noLogInAlertText;
                                break;
                              case InvitacionStatus.invalid:
                                mensaje = strings.invitationCodeErrorText;
                                break;
                              case InvitacionStatus.expired:
                                mensaje = strings.invitationExpiredText;
                                break;
                              case InvitacionStatus.selfInvitacion:
                                mensaje = strings.invitationSelfErrorText;
                                break;
                              case InvitacionStatus.success:
                                mensaje = strings.invitationSuccessText;
                                break;
                              case InvitacionStatus.error:
                                mensaje = strings.errorHasOccurredText;
                                break;
                              case InvitacionStatus.alreadyInSpace:
                                mensaje = strings.alreadyInSharedSpaceText;
                                break;
                            }

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(mensaje),
                                backgroundColor:
                                    invitacion == InvitacionStatus.success
                                    ? Colors.green[700]
                                    : Colors.orange[800],
                                duration: Duration(seconds: 3),
                              ),
                            );

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MainScreen(),
                              ),
                            );
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.inversePrimary,
                            foregroundColor: Colors.white,
                          ),
                          icon: const Icon(Icons.link, size: 24),
                          label: Text(
                            strings.aceptInvitationText,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else {
            // --- PINTAR EL ERROR ---
            String mensajeError = "";
            switch (status) {
              case InvitacionStatus.expired:
                mensajeError = "Esta invitación ya expiró";
                break;
              case InvitacionStatus.alreadyInSpace:
                mensajeError = "Ya perteneces a un Space";
                break;
              case InvitacionStatus.selfInvitacion:
                mensajeError = "No puedes invitarte a ti mismo";
                break;
              default:
                mensajeError = "Invitación no válida";
            }

            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 10),
                  Text(mensajeError, style: const TextStyle(fontSize: 18)),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Container _profilePhoto(
    ColorScheme colorScheme,
    UserModel? guestUser,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: color.withValues(
            alpha: 0.8,
          ), // withValues -> withOpacity es más común
          width: 2,
        ),
      ),
      child: CircleAvatar(
        radius: 40,
        backgroundColor: colorScheme.surfaceContainerHighest,
        // Validamos que el usuario y la foto existan
        backgroundImage: (guestUser?.photoUrl != null)
            ? NetworkImage(guestUser!.photoUrl!)
            : null,
        child: guestUser?.photoUrl == null
            ? Icon(
                Icons.person_rounded,
                size: 40,
                color: colorScheme.onSurfaceVariant,
              )
            : null,
      ),
    );
  }
}
