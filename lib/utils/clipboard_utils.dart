import 'dart:async'; // Need this for the Timer
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:money_move/config/app_colors.dart';

Future<void> copyToClipboard(
  BuildContext context,
  String text, {
  required String message,
}) async {
  if (text.isEmpty) return;

  // 1. Copy the text (This part is perfect)
  await Clipboard.setData(ClipboardData(text: text));

  // 2. Check if widget is still valid
  if (!context.mounted) return;

  // 3. SHOW TOP NOTIFICATION (The new logic)
  // We use Overlay to float above everything (even the AppBar)
  final overlayState = Overlay.of(context);

  late OverlayEntry overlayEntry;

  overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      top: MediaQuery.of(context).padding.top + 10, // Just below status bar
      left: 20,
      right: 20,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.income, // Your custom green color
            borderRadius: BorderRadius.circular(30), // Pill shape
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  // Insert the notification
  overlayState.insert(overlayEntry);

  // Remove it automatically after 2 seconds
  Timer(const Duration(seconds: 2), () {
    if (overlayEntry.mounted) {
      overlayEntry.remove();
    }
  });
}
