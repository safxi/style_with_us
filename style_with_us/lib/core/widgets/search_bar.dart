import 'package:flutter/material.dart';
import '../theme/style_tokens.dart';
import 'glass_card.dart';

class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFilterTap;
  final String hintText;

  const SearchBarWidget({
    super.key,
    required this.controller,
    this.onChanged,
    this.onFilterTap,
    this.hintText = 'Search...',
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      blur: 20,
      opacity: 0.7,
      padding: const EdgeInsets.symmetric(horizontal: space16, vertical: space12),
      child: Row(
        children: [
          const Icon(Icons.search, color: textMuted),
          const SizedBox(width: space12),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              decoration: InputDecoration(
                isDense: true,
                hintText: hintText,
                hintStyle: bodyMedium.copyWith(color: textMuted),
                border: InputBorder.none,
              ),
            ),
          ),
          if (onFilterTap != null)
            IconButton(
              icon: const Icon(Icons.tune, color: textSecondary),
              onPressed: onFilterTap,
            ),
        ],
      ),
    );
  }
}

