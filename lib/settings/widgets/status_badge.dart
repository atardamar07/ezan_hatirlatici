import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final ColorScheme colorScheme;

  const StatusBadge({
    super.key,
    required this.icon,
    required this.label,
    required this.isActive,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isActive
        ? colorScheme.primaryContainer
        : colorScheme.errorContainer.withOpacity(0.15);
    final borderColor = isActive
        ? colorScheme.primary.withOpacity(0.3)
        : colorScheme.error.withOpacity(0.4);
    final foregroundColor = isActive
        ? colorScheme.onPrimaryContainer
        : colorScheme.error;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: foregroundColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: foregroundColor,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}