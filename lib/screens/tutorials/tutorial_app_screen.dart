import 'package:flutter/material.dart';
import 'package:money_move/config/app_colors.dart';
import 'package:money_move/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TutorialAppScreen extends StatefulWidget {
  const TutorialAppScreen({super.key});

  @override
  State<TutorialAppScreen> createState() => _TutorialAppScreenState();
}

class _TutorialAppScreenState extends State<TutorialAppScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;
  late int _totalPages;
  void onChanged(double d) {}

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final strings = AppLocalizations.of(context)!;

    List<Widget> pages = [
      _buildTutorialPage(
        context,
        colorScheme,
        strings.tutorialTitle,
        strings.tutorialSubtitle,
        colorScheme.primary,
        Icons.account_balance_wallet,
      ),
      _buildTutorialPage(
        context,
        colorScheme,
        strings.tutorialTitle1,
        strings.tutorialSubtitle1,
        colorScheme.surface,
        Icons.payments,
      ),
      _buildTutorialPage(
        context,
        colorScheme,
        strings.tutorialTitle2,
        strings.tutorialSubtitle2,
        colorScheme.inversePrimary,
        Icons.bar_chart,
      ),
      _buildTutorialPage(
        context,
        colorScheme,
        strings.tutorialTitle3,
        strings.tutorialSubtitle3,
        AppColors.income,
        Icons.receipt_long,
      ),
    ];

    _totalPages = pages.length;

    return Scaffold(
      body: Stack(
        children: [
          // LAYER 1: The Sliding Content (Bottom)
          PageView(
            controller: _controller,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            children: pages,
          ),

          // LAYER 2: The Skip Button (Top Right)
          Positioned(
            top: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(
                  16.0,
                ), // Add some spacing from the edge
                child: TextButton(
                  onPressed: () {
                    _finishTutorial(context); // Call your save & exit function
                  },
                  style: TextButton.styleFrom(
                    // Optional: Add a subtle background so it's visible on any color
                    backgroundColor: Colors.black.withValues(alpha: 0.1),
                    foregroundColor: Colors.white, // Text color
                    shape: StadiumBorder(),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("Skip"),
                      SizedBox(width: 5),
                      Icon(Icons.close, size: 18), // Nice "X" icon or arrow
                    ],
                  ),
                ),
              ),
            ),
          ),

          if (_currentPage > 0)
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: _buildCircleButton(
                  context,
                  icon: Icons.arrow_back_ios_new,
                  onTap: () {
                    _controller.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                ),
              ),
            ),

          // ---------------------------------------------
          // LAYER 4: The RIGHT Arrow (Next / Finish)
          // ---------------------------------------------
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 10),
              child: _buildCircleButton(
                context,
                icon: _currentPage == _totalPages - 1
                    ? Icons.check
                    : Icons.arrow_forward_ios,
                onTap: () {
                  if (_currentPage == _totalPages - 1) {
                    _finishTutorial(context); // Finish if last page
                  } else {
                    _controller.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 1. The Design of the Round Buttons
  Widget _buildCircleButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent, // Required for InkWell ripple
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            // Semi-transparent background for contrast
            color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: Theme.of(context).colorScheme.primary),
        ),
      ),
    );
  }

  void _finishTutorial(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('skipAppTutorial', true);
    if (!context.mounted) return;
    Navigator.pop(context);
  }
}

Widget _buildTutorialPage(
  BuildContext context,
  ColorScheme colorScheme, // El "color echem"
  String title,
  String subtitle,
  Color mainColor,
  IconData icon, // Agregué esto para que se vea Pro (el ícono visual)
) {
  return Container(
    color: mainColor, // El color de fondo principal de la página
    child: SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 80.0, vertical: 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1. ESPACIO SUPERIOR (Opcional, para empujar el contenido)
            const Spacer(flex: 1),

            // 2. LA IMAGEN O ÍCONO (Círculo con fondo suave)
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(
                  0.2,
                ), // Círculo semitransparente
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 80,
                color: Colors.white, // Ícono blanco para contraste
              ),
            ),

            const SizedBox(height: 40),

            // 3. TÍTULO
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white, // Forzamos blanco sobre fondo de color
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),

            const SizedBox(height: 16),

            // 4. SUBTÍTULO
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white.withOpacity(0.9), // Blanco suave
                height: 1.5, // Mejor lectura
                fontSize: 16,
              ),
            ),

            // 5. ESPACIO INFERIOR (Empuja todo hacia arriba visualmente)
            const Spacer(flex: 2),
          ],
        ),
      ),
    ),
  );
}
