// Guía de Documentación (Conceptos):**
// En Dart, una clase de modelo generalmente necesita:
// 1.  **Propiedades:** Variables que describen el objeto. Recuerda usar
//        `final` si no van a cambiar después de crearse el objeto (inmutabilidad recomendada).
// 2.  **Constructor:** La función que construye la clase. En Dart se usan
//           "Named Parameters" (parámetros con nombre) usando `{}` para que sea más legible.
// 3.  **Tipos de datos:**
//     * `String` para texto.
//     * `double` para dinero (permite decimales).
//     * `DateTime` para fechas.
//     * `bool` para verdadero/falso (útil para saber si es Ingreso o Egreso).

// **Tu Misión:**
// Intenta escribir la clase `Transaction` (o `Transaccion` si prefieres español) que tenga:
// * Un identificador (id).
// * Un título o descripción.
// * El monto.
// * La fecha.
// * La categoría.
// * Un booleano para saber si es gasto o ingreso.

// Intenta escribir ese código en tu archivo y muéstramel

class Transaction {
  final String id;
  final String title;
  final String description;
  final double monto;
  final DateTime fecha;
  final String categoria;
  final bool isExpense; // true = Gasto, false = Ingreso

  Transaction({
    required this.id,
    required this.title,
    required this.description,
    required this.monto,
    required this.fecha,
    required this.categoria,
    required this.isExpense
  });
}
