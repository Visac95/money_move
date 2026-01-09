import 'package:flutter/material.dart';
import 'package:money_move/l10n/app_localizations.dart';
import 'package:money_move/widgets/add_transaction_button.dart';
import 'package:money_move/widgets/balance_card.dart';
import 'package:money_move/widgets/lista_de_transacciones.dart';
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

    // Usamos NestedScrollView: El rey de los efectos de scroll
    return Scaffold(
      body: NestedScrollView(
        // headerSliverBuilder: Aquí construimos la parte de arriba que se anima/fija
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              // 1. PINNED: TRUE -> LA CLAVE DEL ÉXITO
              // Esto hace que la barra y el balance NUNCA desaparezcan del todo.
              pinned: true,

              // 2. FLOATING: TRUE -> Opcional
              // Si lo pones true, la barra intenta aparecer apenas subes el dedo.
              floating: true,

              // Configuración visual básica
              elevation: 0,
              forceElevated: innerBoxIsScrolled, // Sombra suave al scrollear
              centerTitle: true,
              title: Text(
                strings.titleTransactionsScreen,
                style: const TextStyle(fontWeight: FontWeight.bold),
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
                    left: 20,
                    right: 20,
                  ),
                  child: BalanceCard(),
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
