import 'package:flutter/material.dart';
import 'package:money_move/l10n/app_localizations.dart';

class SpaceTutorialScreen extends StatelessWidget {
  const SpaceTutorialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final strings = AppLocalizations.of(context)!;
    return Scaffold(
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.only(
            left: 15,
            right: 15,
            bottom: 15,
            top: 60,
          ),
          child: Column(
            children: [
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: colorScheme.inversePrimary.withValues(alpha: 0.1),
                  ),
                  padding: EdgeInsets.all(20),
                  child: Icon(
                    Icons.group,
                    size: 100,
                    color: colorScheme.inversePrimary,
                  ),
                ),
              ),
              SizedBox(height: 40),
              Text(
                strings.spaceTutorialTitle,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Text(
                strings.spaceTutorialSubtitle,
                style: TextStyle(fontSize: 17),
              ),
              SizedBox(height: 10),
              _listItem(
                context,
                Icons.sync,
                strings.spaceTutorialPoint1Title,
                strings.spaceTutorialPoint1Subtitle,
              ),
              _listItem(
                context,
                Icons.lock,
                strings.spaceTutorialPoint2Title,
                strings.spaceTutorialPoint2Subtitle,
              ),
              _listItem(
                context,
                Icons.toggle_on,
                strings.spaceTutorialPoint3Title,
                strings.spaceTutorialPoint3Subtitle,
              ),
              _listItem(
                context,
                Icons.warning_amber_rounded,
                strings.spaceTutorialPoint4Title,
                strings.spaceTutorialPoint4Subtitle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _listItem(
  BuildContext context,
  IconData icon,
  String title,
  String text,
) {
  final colorScheme = Theme.of(context).colorScheme;
  return Padding(
    padding: const EdgeInsets.only(top: 8.0, bottom: 8, left: 10),
    child: Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Icon(icon, size: 20, color: colorScheme.inversePrimary),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 17,
                  color: colorScheme.inversePrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 25),
          child: Text(text, style: TextStyle(fontSize: 16)),
        ),
      ],
    ),
  );
}
