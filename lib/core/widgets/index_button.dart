import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

class IndexButton extends StatelessWidget {
  const IndexButton({super.key, required this.label, required this.onPressed, this.secondary = false, this.icon});
  final String label;
  final VoidCallback onPressed;
  final bool secondary;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final child = Row(mainAxisSize: MainAxisSize.min, children: [
      if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 8)],
      Text(label),
    ]);
    return secondary
        ? OutlinedButton(onPressed: onPressed, style: OutlinedButton.styleFrom(foregroundColor: AppTokens.navy, side: const BorderSide(color: AppTokens.line), padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTokens.radiusSm))), child: child)
        : FilledButton(onPressed: onPressed, style: FilledButton.styleFrom(backgroundColor: AppTokens.navy, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTokens.radiusSm))), child: child);
  }
}
