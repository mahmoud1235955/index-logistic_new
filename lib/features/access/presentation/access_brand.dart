import 'package:flutter/material.dart';

import '../../../core/theme/app_tokens.dart';

class AccessBrand extends StatelessWidget {
  const AccessBrand({super.key, this.inverse = false, this.compact = false});
  final bool inverse;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final foreground = inverse ? AppTokens.white : AppTokens.navy;
    return Semantics(
      label: 'Index Logistics',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: compact ? 38 : 48,
            height: compact ? 38 : 48,
            decoration: BoxDecoration(
              color: inverse
                  ? Colors.white.withValues(alpha: .12)
                  : AppTokens.navy,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.local_shipping_outlined,
              color: inverse ? AppTokens.white : AppTokens.white,
              size: compact ? 21 : 26,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'INDEX',
                style: TextStyle(
                  color: foreground,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                  fontSize: compact ? 14 : 17,
                ),
              ),
              Text(
                'LOGISTICS',
                style: TextStyle(
                  color: foreground.withValues(alpha: .72),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.1,
                  fontSize: compact ? 9 : 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
