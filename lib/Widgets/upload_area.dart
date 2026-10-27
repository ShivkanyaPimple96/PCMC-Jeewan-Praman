import 'dart:io';
import 'package:flutter/material.dart';
import '../config/app_theme.dart';

/// Matches WebApp's upload card with icon circle
class UploadArea extends StatelessWidget {
  final String label;
  final String sublabel;
  final String hint;
  final IconData icon;
  final File? imageFile;
  final VoidCallback onTap;

  const UploadArea({
    super.key,
    required this.label,
    required this.sublabel,
    required this.hint,
    required this.icon,
    required this.onTap,
    this.imageFile,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.cardRadius),
          border: Border.all(color: AppTheme.cardBorder, width: 1.5),
        ),
        child: imageFile != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                child: Image.file(
                  imageFile!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              )
            : Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon circle
                    Container(
                      width: 60,
                      height: 60,
                      decoration: const BoxDecoration(
                        color: AppTheme.cardBorder,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, size: 28, color: AppTheme.primaryBlue),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      label,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      sublabel,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hint,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textHint,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
