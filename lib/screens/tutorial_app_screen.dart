import 'package:flutter/material.dart';
import 'package:money_move/config/app_colors.dart';
import 'package:money_move/screens/main_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TutorialAppScreen extends StatefulWidget {
  const TutorialAppScreen({super.key});

  @override
  State<TutorialAppScreen> createState() => _TutorialAppScreenState();
}

class _TutorialAppScreenState extends State<TutorialAppScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;
  final int _totalPages = 3;
  void onChanged(double d) {}

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
            children: [
              // ... your pages here
              Container(
                color: colorScheme.surface,
                child: Center(child: _page1()),
              ),
              Container(
                color: colorScheme.primary,
                child: Center(child: _page2()),
              ),
              Container(
                color: AppColors.income,
                child: Center(child: _page3()),
              ),
              Container(
                color: colorScheme.inversePrimary,
                child: Center(child: _page3()),
              ),
            ],
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
                    _finishTutorial(); // Call your save & exit function
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
                // Change icon if on last page
                icon: _currentPage == _totalPages - 1
                    ? Icons.check
                    : Icons.arrow_forward_ios,
                onTap: () {
                  if (_currentPage == _totalPages - 1) {
                    _finishTutorial(); // Finish if last page
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
  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent, // Required for InkWell ripple
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            // Semi-transparent background for contrast
            color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
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

  void _finishTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('skipAppTutorial', true);
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MainScreen()),
      );
    }
  }
}

Widget _page1() {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,

    children: [Text("Bienvenido 1")],
  );
}

Widget _page2() {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [Text("Bienvenido 2")],
  );
}

Widget _page3() {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [Text("Bienvenido 3")],
  );
}
