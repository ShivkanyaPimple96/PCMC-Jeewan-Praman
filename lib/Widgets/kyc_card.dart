import 'package:flutter/material.dart';
import '../config/app_theme.dart';

/// Matches WebApp's .kyc-card style
class KycCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const KycCard({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        border: Border.all(color: AppTheme.cardBorder, width: 1.5),
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(18),
        child: child,
      ),
    );
  }
}
