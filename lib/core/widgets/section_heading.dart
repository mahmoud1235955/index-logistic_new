import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

class SectionHeading extends StatelessWidget {
  const SectionHeading({super.key, required this.title, required this.subtitle, required this.action});
  final String title;
  final String subtitle;
  final String action;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: AppTokens.space5),
        child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 4),
            Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
          ])),
          TextButton(onPressed: () {}, child: Row(children: [Text(action), const SizedBox(width: 4), const Icon(Icons.arrow_forward_rounded, size: 17)])),
        ]),
      );
}
