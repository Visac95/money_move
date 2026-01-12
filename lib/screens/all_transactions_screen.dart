import 'package:flutter/material.dart';
import 'package:money_move/l10n/app_localizations.dart';
import 'package:money_move/providers/transaction_provider.dart';
import 'package:money_move/widgets/add_transaction_button.dart';
import 'package:money_move/widgets/balance_card.dart';
import 'package:money_move/widgets/lista_de_transacciones.dart';
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
              title: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    strings.titleTransactionsScreen,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: PopupMenuButton<String>(
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(
                          colorScheme.primary,
                        ),
                        foregroundColor: WidgetStateProperty.all(
                          colorScheme.secondary,
                        ),
                      ),
                      // 'child': Es lo que se ve en la pantalla antes de presionar (Texto + Flecha)
                      child: Row(
                        mainAxisSize: MainAxisSize
                            .min, // Para que ocupe solo lo necesario
                        children: [
                          Text(
                            Provider.of<TransactionProvider>(
                              context,
                            ).getActualFilterString(context),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 4), // Espacio chiquito
                          const Icon(
                            Icons.keyboard_arrow_down,
                          ), // La flechita hacia abajo
                        ],
                      ),

                      onSelected: (String valorElegido) {
                        provider.cambiarFiltro(valorElegido);
                      },

                      // 'itemBuilder': La lista de opciones que aparecen al presionar
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuEntry<String>>[
                            PopupMenuItem<String>(
                              value: "all",
                              child: Text(strings.todoText),
                            ),
                            PopupMenuItem<String>(
                              value: "today",
                              child: Text(strings.hoyText),
                            ),
                            PopupMenuItem<String>(
                              value: "week",
                              child: Text(strings.thisWeekText),
                            ),
                            PopupMenuItem<String>(
                              value: "month",
                              child: Text(strings.thisMonthText),
                            ),
                            PopupMenuItem<String>(
                              value: "year",
                              child: Text(strings.thisYearText),
                            ),
                          ],
                    ),
                  ),
                ],
              ),

              // 3. AQUÍ VA EL BALANCE (Propiedad 'bottom')
              // Usamos 'bottom' y 'PreferredSize' para anclar el balance a la barra.
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(
                  248,
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
        // body: Aquí va tu lista normal. ¡No necesitas cambiar nada en ella!
        body: ListaDeTransacciones(),
      ),
      floatingActionButton: const AddTransactionButton(),
    );
  }
}
