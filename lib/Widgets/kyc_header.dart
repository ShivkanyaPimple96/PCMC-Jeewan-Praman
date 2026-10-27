import 'package:flutter/material.dart';
import '../config/app_theme.dart';

/// Sticky KYC header matching WebApp's .kyc-header
class KycHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBack;

  const KycHeader({super.key, required this.title, this.showBack = true});

  @override
  Size get preferredSize => const Size.fromHeight(50);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.primaryBlue,
        boxShadow: [
          BoxShadow(
              color: Color(0x26000000), blurRadius: 6, offset: Offset(0, 2))
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 50,
          child: Row(
            children: [
              if (showBack)
                GestureDetector(
                  onTap: () => Navigator.maybePop(context),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child:
                        Icon(Icons.arrow_back, color: Colors.black, size: 22),
                  ),
                )
              else
                const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
