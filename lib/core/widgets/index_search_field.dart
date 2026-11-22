import 'package:flutter/material.dart';

class IndexSearchField extends StatelessWidget {
  const IndexSearchField({super.key, required this.hint, this.compact = false});
  final String hint;
  final bool compact;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: compact ? 44 : 52,
        child: TextField(
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: const Icon(Icons.search_rounded, size: 20),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 13),
          ),
        ),
      );
}
