import 'dart:math';
import 'package:flutter/material.dart';

class CaptchaDialog extends StatefulWidget {
  const CaptchaDialog({super.key});

  @override
  State<CaptchaDialog> createState() => _CaptchaDialogState();
}

class _CaptchaDialogState extends State<CaptchaDialog> {
  late List<Color> colors; // 3 colors: 2 bright, 1 dull
  late int dullIndex; // index of dull color in colors list
  String message = 'Select the dull color';

  final Random random = Random();

  // Generate bright colors and dull color
  Color _randomBrightColor() {
    // Bright colors: high saturation and value
    const brightColors = [
      Color(0xFFFF0000), // bright red
      Color(0xFF00FF00), // bright green
      Color(0xFF0000FF), // bright blue
      Color(0xFFFFFF00), // bright yellow
      Color(0xFFFFA500), // orange
      Color(0xFF00FFFF), // cyan
      Color(0xFFFF00FF), // magenta
    ];
    return brightColors[random.nextInt(brightColors.length)];
  }

  Color _dullColor() {
    // Dull color: desaturated, grayish
    const dullColors = [
      Color(0xFF7F7F7F),
      Color(0xFF9E9E9E),
      Color(0xFF8B8B8B),
      Color(0xFFA9A9A9),
      Color(0xFF6E6E6E),
    ];
    return dullColors[random.nextInt(dullColors.length)];
  }

  void _generateColors() {
    colors = [];
    dullIndex = random.nextInt(3);
    for (int i = 0; i < 3; i++) {
      if (i == dullIndex) {
        colors.add(_dullColor());
      } else {
        colors.add(_randomBrightColor());
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _generateColors();
  }

  void _onColorSelected(int index) {
    if (index == dullIndex) {
      Navigator.of(context).pop(true); // CAPTCHA passed
    } else {
      setState(() {
        message = 'Wrong color! Try again.';
        _generateColors();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text('CAPTCHA Verification', style: theme.textTheme.titleLarge),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(3, (index) {
              return GestureDetector(
                onTap: () => _onColorSelected(index),
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: colors[index],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black54, width: 1.5),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}