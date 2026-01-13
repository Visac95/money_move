import 'package:flutter/material.dart';

class ChartSlider extends StatefulWidget {
  final List<Widget> charts;

  const ChartSlider({super.key, required this.charts});

  @override
  State<ChartSlider> createState() => _ChartSliderState();
}

class _ChartSliderState extends State<ChartSlider> {
  // Controlador para manejar el deslizamiento
  final PageController _pageController = PageController(viewportFraction: 0.93);

  // Variable para saber en qué página estamos (para pintar los puntitos)
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final charts = widget.charts;

    return Column(
      children: [
        // 1. EL SLIDER (PageView)
        // El PageView necesita una altura definida, por eso usamos SizedBox
        SizedBox(
          height: 320, // Altura suficiente para tus gráficos
          child: PageView.builder(
            controller: _pageController,
            itemCount: charts.length,
            onPageChanged: (int index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              // Agregamos un pequeño padding lateral para que se vean separados
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: charts[index],
              );
            },
          ),
        ),

        const SizedBox(height: 10),

        // 2. LOS PUNTITOS INDICADORES (Dots)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            charts.length,
            (index) => _buildDot(index, context),
          ),
        ),
      ],
    );
  }

  // Widget para dibujar cada puntito
  Widget _buildDot(int index, BuildContext context) {
    final bool isSelected = _currentIndex == index;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300), // Animación suave
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isSelected ? 24 : 8, // El seleccionado es más largo
      decoration: BoxDecoration(
        color: isSelected
            ? Theme.of(context).colorScheme.primary
            : Colors.grey.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
