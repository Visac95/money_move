import 'package:flutter/material.dart';
import 'package:money_move/l10n/app_localizations.dart';
import 'package:money_move/providers/transaction_provider.dart';
import 'package:money_move/widgets/add_transaction_button.dart';
import 'package:money_move/widgets/balance_card.dart';
import 'package:money_move/widgets/category_filter_button.dart';
import 'package:money_move/widgets/lista_de_transacciones.dart';
import 'package:money_move/widgets/settings_button.dart';
import 'package:provider/provider.dart';
// import 'package:provider/provider.dart'; // Descomenta si usas Provider para el saldo

class AllTransactionsScreen extends StatefulWidget {
  const AllTransactionsScreen({super.key});

  @override
  State<AllTransactionsScreen> createState() => _AllTransactionsScreenState();
}

class _AllTransactionsScreenState extends State<AllTransactionsScreen> {
  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final provider = Provider.of<TransactionProvider>(context);
    // Usamos NestedScrollView: El rey de los efectos de scroll
    return Scaffold(
      body: NestedScrollView(
        // headerSliverBuilder: Aquí construimos la parte de arriba que se anima/fija
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              pinned: true,
              floating: true,
              elevation: 0,
              forceElevated: innerBoxIsScrolled, // Sombra suave al scrollear
              centerTitle: true,
              title: Row(
                children: [
                  Icon(Icons.payments),
                  SizedBox(width: 5),
                  Text(
                    strings.titleTransactionsScreen,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              actions: [settingsButton(context), const SizedBox(width: 10)],

              // 3. AQUÍ VA EL BALANCE (Propiedad 'bottom')
              // Usamos 'bottom' y 'PreferredSize' para anclar el balance a la barra.
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(
                  216,
                ), // Altura de tu widget de balance
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(
                    bottom: 10,
                    left: 10,
                    right: 10,
                  ),
                  child: BalanceCard(
                    expenseAmount: provider.filteredEgresos,
                    incomeAmount: provider.filteredIngresos,
                    totalAmount: provider.filteredsaldoActual,
                    withFilterButton: true,
                  ),
                ),
              ),
            ),
          ];
        },
        // ... dentro del NestedScrollView ...
        body: Column(
          children: [
            // Espacio separador entre la tarjeta y la lista
            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment
                    .spaceBetween, // <--- La clave: Extremos opuestos
                children: [
                  // 1. IZQUIERDA: Título de la sección
                  Text(
                    "${strings.filtrosText}:", // Asegúrate de tener este string o usa uno fijo
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Spacer(),

                  // --- FILTRO 1: CATEGORÍA (El nuevo widget) ---
                  Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    // ¡AQUÍ ESTÁ! 👇 Simplemente lo llamas
                    child: const CategoryFilterButton(),
                  ),

                  const SizedBox(width: 8), // Espacio entre filtros
                  // --- FILTRO 2: TIEMPO (El que ya tenías) ---
                  Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    child: _popupMenuFilter(
                      colorScheme,
                      context,
                      provider,
                      strings,
                    ),
                  ),
                ],
              ),
            ),

            // El resto de la lista (envuelta en Expanded para que ocupe lo que sobra)
            const Expanded(child: ListaDeTransacciones()),
          ],
        ),
      ),
      floatingActionButton: const AddTransactionButton(),
    );
  }

  PopupMenuButton<String> _popupMenuFilter(
    ColorScheme colorScheme,
    BuildContext context,
    TransactionProvider provider,
    AppLocalizations strings,
  ) {
    return PopupMenuButton<String>(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(colorScheme.primary),
        foregroundColor: WidgetStateProperty.all(colorScheme.secondary),
      ),
      // 'child': Es lo que se ve en la pantalla antes de presionar (Texto + Flecha)
      child: Row(
        mainAxisSize: MainAxisSize.min, // Para que ocupe solo lo necesario
        children: [
          Text(
            Provider.of<TransactionProvider>(
              context,
            ).getActualFilterString(context),

            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 4), // Espacio chiquito
          const Icon(Icons.keyboard_arrow_down), // La flechita hacia abajo
        ],
      ),

      onSelected: (String valorElegido) {
        provider.cambiarFiltro(valorElegido);
      },

      // 'itemBuilder': La lista de opciones que aparecen al presionar
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(value: "all", child: Text(strings.todoText)),
        PopupMenuItem<String>(value: "today", child: Text(strings.hoyText)),
        PopupMenuItem<String>(value: "week", child: Text(strings.thisWeekText)),
        PopupMenuItem<String>(
          value: "month",
          child: Text(strings.thisMonthText),
        ),
        PopupMenuItem<String>(value: "year", child: Text(strings.thisYearText)),
      ],
    );
  }
}
