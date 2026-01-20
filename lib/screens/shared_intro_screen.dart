import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:money_move/l10n/app_localizations.dart';
import 'package:money_move/providers/space_provider.dart';
import 'package:provider/provider.dart';

class SharedIntroScreen extends StatelessWidget {
  const SharedIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final accentColor = const Color(0xFFF59E0B);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final strings = AppLocalizations.of(context)!;
    final spaceProvider = Provider.of<SpaceProvider>(context);

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

                    // Botón Principal
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

                          final invitacion = await spaceProvider
                              .generateInvitacion();

                          if (!context.mounted) return;
                          Navigator.of(
                            context,
                          ).pop(); // Esto cierra el diálogo de carga

                          // 4. LÓGICA FINAL
                          if (invitacion != null) {
                            showModalBottomSheet(
                              showDragHandle: true,
                              context: context,
                              shape: const RoundedRectangleBorder(
                                // Redondeamos las esquinas de arriba
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(15),
                                ),
                              ),
                              builder: (context) {
                                return Container(
                                  margin: EdgeInsets.only(
                                    right: 20,
                                    left: 20,
                                    bottom: 20,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "¡Invitación Creada!",
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      Text(
                                        "Tu código: ${invitacion.codeInvitacion}",
                                        style: const TextStyle(
                                          fontSize: 30,
                                          letterSpacing: 2,
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      Row(
                                        children: [
                                          ElevatedButton.icon(
                                            icon: const Icon(Icons.copy),
                                            label: const Text("Copiar Link"),
                                            onPressed: () async {
                                              // 1. Copiar al portapapeles
                                              await Clipboard.setData(
                                                ClipboardData(
                                                  text:
                                                      invitacion.linkInvitacion,
                                                ),
                                              );

                                              // 2. Cerrar el modal (Opcional, a veces es mejor dejarlo abierto)
                                              // Navigator.pop(context);

                                              // 3. Dar feedback al usuario (¡Muy importante!)
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    "¡Copiado al portapapeles!",
                                                  ),
                                                  backgroundColor: Colors.green,
                                                  duration: Duration(
                                                    seconds: 2,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                            print(
                              "¡Listo! Invitación creada: ${invitacion.codeInvitacion}",
                            );
                          } else {
                            // ❌ ERROR:
                            // Puedes mostrar un snackbar o una alerta de error
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Error al crear la invitación'),
                              ),
                            );
                          }
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.inversePrimary,
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.link, size: 24),
                        label: Text(
                          strings.inviteSomeoneText,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Botón Secundario
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        strings.uHaveCodeEnterHere,
                        style: TextStyle(color: accentColor),
                      ),
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
}
