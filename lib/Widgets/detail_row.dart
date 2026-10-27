import 'package:flutter/material.dart';
import '../config/app_theme.dart';

/// Matches WebApp's .detail-row style
class DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;

  const DetailRow({
    super.key,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: isLast
          ? null
          : const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppTheme.detailBorder)),
            ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppTheme.textTertiary,
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
