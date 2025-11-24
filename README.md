# Finanzas Familiares 💰

Aplicación móvil desarrollada en Flutter para la gestión colaborativa de ingresos y gastos del hogar. Diseñada con un enfoque en la simplicidad y la usabilidad para usuarios no técnicos.

## 📋 Descripción
Este proyecto busca resolver la necesidad de llevar un control financiero familiar centralizado. Permite registrar movimientos, categorizarlos y visualizar el estado financiero del hogar de manera intuitiva.

## 🚀 Características Principales
- **Registro de Movimientos:** Ingreso de gastos e ingresos con fecha, monto y descripción.
- **Categorización:** Clasificación de movimientos (Comida, Servicios, Regalos, etc.).
- **Resumen Financiero:** Balance general de cuentas.
- **Modo Offline-First:** Arquitectura preparada para sincronización local y posterior migración a nube.
- **(Futuro) Integración IA:** Clasificación automática de gastos mediante lenguaje natural.

## 🛠 Stack Tecnológico
- **Framework:** Flutter (Dart).
- **Gestión de Estado:** Provider.
- **Arquitectura:** MVVM (Model-View-ViewModel) adaptado con Providers.
- **Persistencia:** - Fase 1: Almacenamiento Local (Shared Preferences / SQflite).
    - Fase 2: Base de datos en la nube (Backend as a Service).

## 📂 Estructura del Proyecto
```text
lib/
├── config/      # Temas, constantes y rutas
├── models/      # Definición de datos (Data Classes)
├── providers/   # Lógica de negocio y Estado (ChangeNotifiers)
├── services/    # Conexión con APIs o Base de Datos externa
├── screens/     # Pantallas de la aplicación
└── widgets/     # Componentes de UI reutilizables




# money_move

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
