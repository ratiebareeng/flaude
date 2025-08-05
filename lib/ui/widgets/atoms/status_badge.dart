import 'package:flutter/material.dart';

enum BadgeType { success, warning, error, info }

class StatusBadge extends StatelessWidget {
  final String text;
  final BadgeType type;
  final IconData? icon;

  const StatusBadge({
    super.key,
    required this.text,
    required this.type,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _getBadgeColors(context, type);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colors.backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 12,
              color: colors.foregroundColor,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              color: colors.foregroundColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  _BadgeColors _getBadgeColors(BuildContext context, BadgeType type) {
    switch (type) {
      case BadgeType.success:
        return _BadgeColors(
          backgroundColor: Colors.green.withOpacity(0.1),
          foregroundColor: Colors.green.shade700,
        );
      case BadgeType.warning:
        return _BadgeColors(
          backgroundColor: Colors.orange.withOpacity(0.1),
          foregroundColor: Colors.orange.shade700,
        );
      case BadgeType.error:
        return _BadgeColors(
          backgroundColor: Colors.red.withOpacity(0.1),
          foregroundColor: Colors.red.shade700,
        );
      case BadgeType.info:
        return _BadgeColors(
          backgroundColor: Colors.blue.withOpacity(0.1),
          foregroundColor: Colors.blue.shade700,
        );
    }
  }
}

class _BadgeColors {
  final Color backgroundColor;
  final Color foregroundColor;

  const _BadgeColors({
    required this.backgroundColor,
    required this.foregroundColor,
  });
}
