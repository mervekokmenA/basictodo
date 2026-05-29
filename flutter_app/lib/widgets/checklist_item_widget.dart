import 'package:flutter/material.dart';

class ChecklistItemWidget extends StatelessWidget {
  final bool checked;
  final ValueChanged<bool?> onToggle;
  final String label;
  final String? sublabel;
  final int streak;
  final bool dimmed;
  final bool recentlyDone; // "3 günde 1" mantığı için

  const ChecklistItemWidget({
    super.key,
    required this.checked,
    required this.onToggle,
    required this.label,
    this.sublabel,
    this.streak = 0,
    this.dimmed = false,
    this.recentlyDone = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Opacity(
      opacity: dimmed ? 0.55 : 1.0,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
        decoration: BoxDecoration(
          color: checked
              ? (isDark
                  ? const Color(0xFF1a3020)
                  : const Color(0xFFe8f5ec))
              : (isDark
                  ? const Color(0xFF162030)
                  : Colors.white),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: checked
                ? const Color(0xFF2e8b57)
                : (isDark
                    ? const Color(0xFF2a3a4a)
                    : const Color(0xFFd0dce8)),
            width: 1.2,
          ),
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          leading: Checkbox(
            value: checked,
            onChanged: dimmed && recentlyDone ? null : onToggle,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
          title: Text(
            label,
            style: TextStyle(
              decoration: checked ? TextDecoration.lineThrough : null,
              color: checked
                  ? Colors.grey
                  : theme.colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: _buildSubtitle(context),
          trailing: _buildTrailing(context),
        ),
      ),
    );
  }

  Widget? _buildSubtitle(BuildContext context) {
    if (recentlyDone && !checked) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF2e8b57), size: 14),
          const SizedBox(width: 4),
          Text(
            'Son 3 günde yapıldı',
            style: TextStyle(
              fontSize: 11,
              color: const Color(0xFF2e8b57),
            ),
          ),
        ],
      );
    }
    if (sublabel != null) {
      return Text(
        sublabel!,
        style: TextStyle(
          fontSize: 12,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        ),
      );
    }
    return null;
  }

  Widget? _buildTrailing(BuildContext context) {
    if (streak > 1) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFc9a227),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🔥', style: TextStyle(fontSize: 13)),
            const SizedBox(width: 2),
            Text(
              '$streak',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }
    return null;
  }
}
