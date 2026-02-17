import 'package:firebase_auth/firebase_auth.dart'; // Necesario para manejar errores
import 'package:flutter/material.dart';
import 'package:money_move/l10n/app_localizations.dart';
import 'package:money_move/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  bool _isLoading = false;

  // --- NUEVO: Variable para saber si estamos en modo Login o Registro ---
  bool _isLogin = true;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final strings = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Center(
          // Center para que se vea bien en tablets/web también
          child: SingleChildScrollView(
            // Scroll por si el teclado tapa los campos
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. TÍTULO O LOGO
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: colorScheme.outline.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(
                    'assets/logo.png',
                    width: 100,
                    height: 100,
                    //errorBuilder: (c, o, s) =>
                    //   const Icon(Icons.account_balance_wallet, size: 80),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  // Cambia el texto según el modo
                  _isLogin ? strings.welcomeText : "Crear Cuenta",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),

                // 2. CAMPOS DE TEXTO
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: strings.emailText,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: _passController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: strings.paswordText,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.lock),
                  ),
                ),
                const SizedBox(height: 24),

                // 3. BOTÓN PRINCIPAL (Login o Registro)
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: () =>
                            _submitForm(strings), // Función conectada
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: colorScheme.primary,
                        ),
                        child: Text(
                          // Cambia texto del botón
                          _isLogin ? strings.loginText : "Registrarse",
                          style: TextStyle(
                            fontSize: 16,
                            color: colorScheme.surface,
                          ),
                        ),
                      ),

                const SizedBox(height: 16),

                // --- NUEVO: Switch para cambiar entre Login y Registro ---
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isLogin = !_isLogin; // Invierte el valor
                    });
                  },
                  child: Text(
                    _isLogin
                        ? strings.dontHaveAccountText
                        : strings.haveAccountText,
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(strings.orContinueWithText),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),

                const SizedBox(height: 20),

                // 4. BOTÓN DE GOOGLE
                OutlinedButton.icon(
                  onPressed: () async {
                    await _handleGoogleLogin(strings);
                  },
                  icon: const Icon(Icons.g_mobiledata, size: 30),
                  label: const Text("Google"),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- LÓGICA DE LOGIN / REGISTRO ---
  Future<void> _submitForm(strings) async {
    final email = _emailController.text.trim();
    final password = _passController.text.trim();

    // Validaciones básicas
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor llena todos los campos")),
      );
      return;
    }

    // Validación de longitud de contraseña (Firebase pide min 6)
    if (!_isLogin && password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("La contraseña debe tener al menos 6 caracteres"),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_isLogin) {
        // MODO LOGIN
        await AuthService().signInWithEmail(email, password);
      } else {
        // MODO REGISTRO
        await AuthService().registerWithEmail(email, password);
      }
      // Si todo sale bien, el AuthGate detecta el usuario y cambia de pantalla solo.
    } on FirebaseAuthException catch (e) {
      String message = "Ocurrió un error";

      // Mensajes de error amigables en español
      if (e.code == 'user-not-found') {
        message = "No existe usuario con ese correo.";
      } else if (e.code == 'wrong-password') {
        message = "Contraseña incorrecta.";
      } else if (e.code == 'email-already-in-use') {
        message = "Este correo ya está registrado.";
      } else if (e.code == 'invalid-email') {
        message = "El correo no es válido.";
      } else if (e.code == 'weak-password') {
        message = "La contraseña es muy débil.";
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Lógica de Google (Sin cambios)
  Future<void> _handleGoogleLogin(strings) async {
    setState(() => _isLoading = true);
    try {
      await AuthService().signInWithGoogle();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${strings.errorAlEntrarEnText} $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
