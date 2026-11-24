import 'package:flutter/material.dart';

class IndexSearchField extends StatelessWidget {
  const IndexSearchField({
    super.key,
    required this.hint,
    this.compact = false,
    this.controller,
    this.onChanged,
    this.onSubmitted,
  });
  final String hint;
  final bool compact;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: compact ? 48 : 52,
    child: TextField(
      controller: controller,
      textInputAction: TextInputAction.search,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.search_rounded, size: 20),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 13),
      ),
    ),
  );
}
