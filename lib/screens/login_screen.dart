import 'package:flutter/material.dart';
import 'package:money_move/services/auth_service.dart'; // Asegúrate de importar tu servicio

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controladores para leer lo que escribe el usuario
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  
  // Para mostrar la ruedita de carga
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Fondo suave
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. TÍTULO O LOGO
              const Icon(Icons.account_balance_wallet, size: 80, color: Colors.blueAccent),
              const SizedBox(height: 20),
              const Text(
                'Bienvenido',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),

              // 2. CAMPOS DE TEXTO
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Correo Electrónico',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              
              TextField(
                controller: _passController,
                obscureText: true, // Ocultar contraseña
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 24),

              // 3. BOTÓN DE ENTRAR (EMAIL)
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: () {
                        // Aquí conectaremos el login normal luego
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Iniciar Sesión', style: TextStyle(fontSize: 16)),
                    ),
              
              const SizedBox(height: 20),
              
              const Row(children: [
                Expanded(child: Divider()),
                Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text("O continúa con")),
                Expanded(child: Divider()),
              ]),
              
              const SizedBox(height: 20),

              // 4. BOTÓN DE GOOGLE
              OutlinedButton.icon(
                onPressed: () async {
                   // LÓGICA DE GOOGLE AQUÍ
                   await _handleGoogleLogin();
                },
                icon: const Icon(Icons.g_mobiledata, size: 30), // Icono simple, puedes poner el logo real luego
                label: const Text("Google"),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Función auxiliar para manejar el login de Google
  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);
    try {
      // Llamamos a nuestro servicio
      await AuthService().signInWithGoogle();
      // No necesitamos navegar manualmente a Home. 
      // El AuthGate escuchará el cambio y nos llevará solos.
    } catch (e) {
      // Si falla, mostramos un aviso
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al entrar: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}