// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'MoneyMove';

  @override
  String get noDescription => 'Sin descripción';

  @override
  String get editText => 'Editar';

  @override
  String get cancelText => 'Cancelar';

  @override
  String get deleteText => 'Eliminar';

  @override
  String get navigationTextHome => 'Inicio';

  @override
  String get navigationTextTransactions => 'Movimientos';

  @override
  String get navigationTextDeudas => 'Deudas';

  @override
  String get titleText => 'Título';

  @override
  String get dateText => 'Fecha';

  @override
  String get descriptionText => 'Descripción';

  @override
  String get category => 'Categoría';

  @override
  String get titleTransactionsScreen => 'Movimientos';

  @override
  String get noTransactionsYet => 'No hay movimientos aún 😴';

  @override
  String get addTransaction => 'Añadir Movimiento';

  @override
  String get chooseCategoryManualTitle =>
      'Elija la categoría para su movimiento';

  @override
  String get editTransaccionText => 'Editar Movimiento';

  @override
  String get accitionNotUndone => 'Esta acción no se puede deshacer.';

  @override
  String get deleteTransactionquestionText =>
      '¿Desea eliminar este movimiento?';

  @override
  String get deleteTransactionText => 'Eliminar Movimiento';

  @override
  String get deletedTransactionMessage => 'Movimiento eliminado';

  @override
  String get titleDeudasScreen => 'Deudas';

  @override
  String get noDeudasYet => 'No hay deudas aún 😴';

  @override
  String get addDeuda => 'Añadir Deuda';

  @override
  String get editDeudaText => 'Editar Deuda';

  @override
  String get changeLanguage => 'Idioma cambiado';

  @override
  String get seeAllTransactionsText => 'Ver todos los movimientos';

  @override
  String get transactionNotExist => 'La transacción no existe';

  @override
  String get transactionDetailsTitle => 'Detalle del Movimiento';

  @override
  String get expenseMade => 'Gasto Realizado';

  @override
  String get incomeReceived => 'Ingreso Recibido';
}
