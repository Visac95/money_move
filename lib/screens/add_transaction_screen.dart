import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:money_move/l10n/app_localizations.dart';
import 'package:money_move/providers/ai_category_provider.dart';
import 'package:money_move/providers/user_provider.dart';
import 'package:money_move/utils/mode_color_app_bar.dart';
import 'package:money_move/widgets/mode_toggle.dart';
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

  // --- LÓGICA IA CORREGIDA ---
  void _classifyTitle() {
    // 1. Debounce: Esperamos a que el usuario deje de escribir
    if (debounce?.isActive ?? false) debounce!.cancel();

    debounce = Timer(const Duration(milliseconds: 800), () {
      // Verificamos que el widget siga vivo
      if (!mounted) return;

      final aiProvider = Provider.of<AiCategoryProvider>(
        context,
        listen: false,
      );

      // 2. REGLA DE ORO: Si ya eligió manual, no molestamos
      if (aiProvider.manualCategory != null) return;

      final text = titleController.text.trim();

      // 3. Solo reseteamos y buscamos si hay texto real y ha cambiado
      if (text.isNotEmpty) {
        // Opcional: Solo resetear justo antes de buscar nueva clasificacion
        // para evitar notificar a los listeners en cada tecla pulsada.
        aiProvider.resetCategory();
        aiProvider.requestClassification(text);
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
    if (!mounted) return;
    final userProv = Provider.of<UserProvider>(context, listen: false);
    final nuevaTransaccion = Transaction(
      userId: !transactionProvider.isSpaceMode
          ? FirebaseAuth.instance.currentUser!.uid
          : userProv.usuarioActual!.spaceId!,
      title: titleController.text,
      description: descriptionController.text,
      monto: enteredAmount,
      saldo: nuevoSaldoCalculado, // AQUÍ ASIGNAMOS EL VALOR CALCULADO
      fecha: DateTime.now(),
      categoria: finalCategory,
      isExpense: isExpense,
    );
    print("🐈‍⬛💀datos de la trasaccion: ${nuevaTransaccion.toMap()}");
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
      //hi
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
        backgroundColor: modeColorAppbar(context, 0.4),
        elevation: 0,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        actions: [ModeToggle(bigWidget: false), SizedBox(width: 10)],
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
