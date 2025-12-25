import 'package:flutter/material.dart';
import 'package:money_move/config/app_colors.dart';
import 'package:money_move/providers/deuda_provider.dart';
import 'package:money_move/screens/edit_deuda_screen.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class ListaDeudasWidget extends StatefulWidget {
  bool deboList;
  ListaDeudasWidget({super.key, this.deboList = true});

  @override
  State<ListaDeudasWidget> createState() => _ListaDeudasWidget();
}

class _ListaDeudasWidget extends State<ListaDeudasWidget> {
  @override
  void initState() {
    super.initState();
    Provider.of<DeudaProvider>(context, listen: false).loadDeudas();
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DeudaProvider>(context);
    final lista = provider.deudas
        .where((deuda) => deuda.debo == widget.deboList)
        .toList();

    // 1. Quitamos el SizedBox que forzaba la altura
    if (lista.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 30),
        child: _buildEmptyState(),
      );
    }

    // 2. Usamos ListView con shrinkWrap y sin scroll propio
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
      itemCount: lista.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),

      // LA CLAVE ESTÁ AQUÍ:
      shrinkWrap: true, // "Encógete al tamaño de tus hijos"
      physics:
          const NeverScrollableScrollPhysics(), // "No hagas scroll tú, deja que la pantalla principal lo haga"

      itemBuilder: (context, index) {
        final deuda = lista[index];
        return _buildDebtCard(context, deuda, provider);
      },
    );
  }

  Widget _buildDebtCard(
    BuildContext context,
    dynamic deuda,
    DeudaProvider provider,
  ) {
    // Definimos colores según si YO DEBO o ME DEBEN
    final bool soyDeudor = deuda.debo; // true = Yo debo, false = Me deben

    final Color mainColor = soyDeudor
        ? AppColors.accentColor
        : AppColors.incomeColor;
    final Color bgColor = soyDeudor
        ? Colors.orange.shade50
        : Colors.teal.shade50;
    final String label = soyDeudor ? "POR PAGAR" : "POR COBRAR";
    final IconData iconStatus = soyDeudor
        ? Icons.arrow_outward_rounded
        : Icons.arrow_downward_rounded;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        // Para que la franja de color respete el borde
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          // Hace que la franja mida lo mismo que la tarjeta
          child: Row(
            children: [
              // 1. FRANJA LATERAL DE COLOR (Semáforo visual)
              Container(width: 6, color: mainColor),

              // 2. CONTENIDO PRINCIPAL
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Encabezado: Etiqueta y Monto
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Chip de estado (Por pagar / Por cobrar)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: bgColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(iconStatus, size: 12, color: mainColor),
                                const SizedBox(width: 4),
                                Text(
                                  label,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: mainColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Menú de opciones (3 puntos)
                          _buildPopupMenu(context, deuda, provider),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Información Principal: Avatar y Título
                      Row(
                        children: [
                          // AVATAR CON INICIAL (Mucho más personal que un icono de categoría)
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: AppColors.backgroundColor,
                            child: Text(
                              deuda.involucrado.isNotEmpty
                                  ? deuda.involucrado[0].toUpperCase()
                                  : "?",
                              style: TextStyle(
                                color: AppColors.textDark,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Textos centrales
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  deuda.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  "Con: ${deuda.involucrado}",
                                  style: TextStyle(
                                    color: AppColors.textDark,
                                    fontSize: 13,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),

                          // MONTO (Grande y legible)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "\$${deuda.monto.toStringAsFixed(2)}",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: mainColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.event_busy_rounded,
                                    size: 12,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    "Vence: ${_formatDate(deuda.fechaLimite)}",
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Menú PopUp extraído para limpieza
  Widget _buildPopupMenu(
    BuildContext context,
    dynamic deuda,
    DeudaProvider provider,
  ) {
    return SizedBox(
      height: 24,
      width: 24,
      child: PopupMenuButton(
        padding: EdgeInsets.zero,
        icon: Icon(Icons.more_vert, size: 20, color: Colors.grey.shade400),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onSelected: (value) {
          if (value == "borrar") {
            provider.deleteDeuda(deuda.id);
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Deuda eliminada')));
          }
          if (value == "editar") {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => EditDeudaScreen(deuda: deuda),
              ),
            );
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: "editar",
            child: Row(
              children: [
                Icon(Icons.edit, size: 18),
                SizedBox(width: 8),
                Text("Editar"),
              ],
            ),
          ),
          const PopupMenuItem(
            value: "borrar",
            child: Row(
              children: [
                Icon(Icons.delete, color: Colors.red, size: 18),
                SizedBox(width: 8),
                Text("Borrar", style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.handshake_outlined,
            size: 70,
            color: Colors.grey.shade200,
          ), // Icono más acorde a deudas
          const SizedBox(height: 16),
          const Text(
            "Todo saldado 🎉",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "No tienes deudas pendientes",
            style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
