import 'package:flutter/material.dart';

class AppColors {
  // --- PALETA BASE (Los "ingredientes" puros) ---
  // Estos son tus colores de marca, no cambian.
  static const Color brandPrimary = Color(0xFF4F46E5); // Tu índigo principal
  static const Color brandSecondary = Colors.orange;
  
  // Finanzas (Iguales para ambos, o ligeramente ajustados si quisieras)
  static const Color expense = Color(0xFFEF4444); 
  static const Color income = Color(0xFF10B981); 
  static const Color accent = Color(0xFFF59E0B);

  // --- MODO CLARO (Light Mode) ---
  static const Color lightPrimary = brandPrimary;
  static const Color lightBackground = Color(0xFFF9FAFB); // Tu blanco humo
  static const Color lightSurface = Colors.white;         // Para tarjetas
  static const Color lightTextPrimary = Color(0xFF1F2937); // Tu negro suave
  static const Color lightTextSecondary = Color(0xFF6B7280); // Tu gris subtítulos
  static const Color lightIcon = Color(0xFF1F2937);
  static const Color lightOutlineVariant = Color.fromARGB(176, 175, 175, 175); // Gris claro para bordes
  static const Color lightSurfaceContainer = Color(0xFFF3F4F6);

  // --- MODO OSCURO (Dark Mode) ---
  // Aquí corregimos: El fondo pasa a ser oscuro y el texto claro.
  static const Color darkPrimary = Color(0xFF818CF8); // Un índigo más pastel para que no brille tanto en lo oscuro
  static const Color darkBackground = Color(0xFF121212); // Negro casi puro
  static const Color darkSurface = Color(0xFF1E1E1E);    // Gris oscuro para tarjetas
  static const Color darkTextPrimary = Color(0xFFF3F4F6); // Blanco hueso
  static const Color darkTextSecondary = Color(0xFF9CA3AF); // Gris claro
  static const Color darkIcon = Color(0xFFF3F4F6);
  static const Color darkOutlineVariant = Color.fromARGB(174, 92, 92, 92);
  static const Color darkSurfaceContainer = Color.fromARGB(255, 38, 38, 38);
}