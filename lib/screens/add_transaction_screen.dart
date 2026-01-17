import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:money_move/config/app_colors.dart';
import 'package:money_move/l10n/app_localizations.dart';
import 'package:money_move/providers/ai_category_provider.dart';
import 'package:money_move/utils/ui_utils.dart';
import 'package:money_move/widgets/select_category_window.dart';
import 'package:money_move/widgets/transaction_form.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction.dart';
import 'dart:async';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final titleController = TextEditingController();
  final amountController = TextEditingController();
  final descriptionController = TextEditingController();
  bool isExpense = true;
  Timer? debounce;

  @override
  void initState() {
    super.initState();
    // Escuchamos cambios en el título para activar la IA
    titleController.addListener(_classifyTitle);
  }

  @override
  void dispose() {
    debounce?.cancel();
    titleController.dispose();
    amountController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  // --- LÓGICA IA LIMPIA ---
  void _classifyTitle() {
    final aiProvider = Provider.of<AiCategoryProvider>(context, listen: false);
    aiProvider.resetCategory();

    // 1. REGLA DE ORO: Si el usuario ya eligió manualmente, la IA no hace NADA.
    if (aiProvider.manualCategory != null) return;

    // Debounce para no llamar a la API por cada letra
    if (debounce?.isActive ?? false) debounce!.cancel();

    debounce = Timer(const Duration(milliseconds: 1000), () {
      // Doble chequeo por si el usuario eligió una categoría mientras corría el timer
      if (aiProvider.manualCategory != null) return;

      // Si el título no está vacío, pedimos ayuda a la IA
      if (titleController.text.trim().isNotEmpty) {
        aiProvider.requestClassification(titleController.text);
      }
    });
  }

  Future<void> _saveTransaction() async {
    // 1. Validaciones básicas
    if (titleController.text.isEmpty || amountController.text.isEmpty) return;

    final double? enteredAmount = double.tryParse(amountController.text);
    if (enteredAmount == null) return;

    final aiProvider = Provider.of<AiCategoryProvider>(context, listen: false);
    final transactionProvider = Provider.of<TransactionProvider>(
      context,
      listen: false,
    );

    // Obtenemos el saldo actual en este momento exacto
    final double saldoActualDelProvider = transactionProvider.saldoActual;

    // 3. DECISIÓN DE CATEGORÍA
    String finalCategory =
        aiProvider.manualCategory ?? aiProvider.suggestedCategory;

    // 4. DIÁLOGO ASINCRÓNICO (Si aplica)
    if (finalCategory.isEmpty || finalCategory == 'manual_category') {
      if (!mounted) return; // Verificación de seguridad

      final String? selectedManual = await showDialog<String>(
        context: context,
        builder: (context) => const SelectCategoryWindow(),
      );

      if (selectedManual != null) {
        finalCategory = selectedManual;
      } else {
        return;
      }
    }

    // 5. CÁLCULO DEL NUEVO SALDO
    // Calculamos cómo quedará la cuenta después de esta transacción
    double nuevoSaldoCalculado;
    if (isExpense) {
      nuevoSaldoCalculado = saldoActualDelProvider;
    } else {
      nuevoSaldoCalculado = saldoActualDelProvider;
    }
    final nuevaTransaccion = Transaction(
      userId: FirebaseAuth.instance.currentUser!.uid,
      title: titleController.text,
      description: descriptionController.text,
      monto: enteredAmount,
      saldo: nuevoSaldoCalculado, // AQUÍ ASIGNAMOS EL VALOR CALCULADO
      fecha: DateTime.now(),
      categoria: finalCategory,
      isExpense: isExpense,
    );
    // 6. GUARDAR

    try {
      transactionProvider.addTransaction(nuevaTransaccion);
      final connectivityResult = await Connectivity().checkConnectivity();
      bool sinInternet = connectivityResult.contains(ConnectivityResult.none);

      if (mounted) {
        String mensaje;
        if (sinInternet) {
          mensaje = AppLocalizations.of(context)!.noConecctionAddTraxText;
        } else {
          mensaje = AppLocalizations.of(context)!.savedTrasactionSuccessText;
        }

        //Navigator.pop(context);
        // Mostramos el mensaje personalizado
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(mensaje),
            backgroundColor: sinInternet
                ? Colors.orange[800]
                : Colors.green[700],
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e, /*stackTrace*/ _) {
      // // EN VEZ DE PRINT O GUARDAR EN FIRESTORE:

      // FirebaseCrashlytics.instance.recordError(
      //   e, // El error
      //   stackTrace, // El "rastro" de dónde vino
      //   reason: 'Falló al intentar guardar la transacción', // Tu nota personal
      //   fatal: false, // false porque la app no se cerró, solo falló esa acción
      // );

      // // Y aquí muestras tu SnackBar al usuario para que sepa que algo pasó
      // mounted
      //     ? UiUtils.showSnackBar(
      //         context,
      //         "Ocurrió un error inesperado",
      //         AppColors.brandSecondary as MaterialColor?,
      //       )
      //     : {};
    }

    if (mounted) Navigator.of(context).pop();

    aiProvider.resetCategory();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.addTransaction,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
      ),
      body: TransactionForm(
        titleController: titleController,
        amountController: amountController,
        descriptionController: descriptionController,
        isExpense: isExpense,
        onTypeChanged: (bool value) {
          setState(() {
            isExpense = value;
          });
        },
        onSave: _saveTransaction,
      ),
    );
  }
}
