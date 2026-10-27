import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../config/app_theme.dart';
import '../config/routes.dart';
import '../data/models/declaration_dto.dart';
import '../providers/kyc_provider.dart';
import '../widgets/green_button.dart';
import '../widgets/kyc_header.dart';

class DeclarationScreen extends StatefulWidget {
  const DeclarationScreen({super.key});

  @override
  State<DeclarationScreen> createState() => _DeclarationScreenState();
}

class _DeclarationScreenState extends State<DeclarationScreen> {
  bool _hasReemployed = false;
  bool _hasRemarried = false;
  final _orgController = TextEditingController();
  final _reemployedDateController = TextEditingController();
  final _marriageDateController = TextEditingController();
  final _marriageLocationController = TextEditingController();

  DateTime? _reemployedDate;
  DateTime? _marriageDate;

  @override
  void dispose() {
    _orgController.dispose();
    _reemployedDateController.dispose();
    _marriageDateController.dispose();
    _marriageLocationController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({
    required BuildContext context,
    required TextEditingController controller,
    required DateTime? currentValue,
    required ValueChanged<DateTime> onDateSelected,
  }) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: currentValue ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryBlue,
              onPrimary: Colors.white,
              onSurface: AppTheme.textDark,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primaryBlue,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onDateSelected(picked);
      controller.text = DateFormat('dd/MM/yyyy').format(picked);
    }
  }

  // ── CONFIRMATION DIALOG ────────────────────────────────────────────────
  Future<void> _showSubmitConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: const Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.green, size: 28),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Confirm Submission',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Divider(thickness: 2.5),
              SizedBox(height: 8),
              Text(
                'Are you sure you want to submit all this data?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 6),
              Text(
                'तुम्हाला खात्री आहे की तुम्ही हा सर्व डेटा सबमिट करू इच्छिता?',
                style: TextStyle(fontSize: 14, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Divider(thickness: 2.5),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // close dialog first
                _submit(); // then submit
              },
              child: const Text(
                'Submit',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ── ACTUAL SUBMIT ──────────────────────────────────────────────────────
  Future<void> _submit() async {
    final provider = context.read<KycProvider>();

    final declaration = DeclarationDto(
      hasReemployed: _hasReemployed,
      reemployedOrganisation:
          _hasReemployed ? _orgController.text.trim() : null,
      reemployedDate:
          _hasReemployed ? _reemployedDateController.text.trim() : null,
      hasRemarried: _hasRemarried,
      marriageDate: _hasRemarried ? _marriageDateController.text.trim() : null,
      marriageLocation:
          _hasRemarried ? _marriageLocationController.text.trim() : null,
    );

    final success = await provider.submitCertificate(declaration);
    if (success && mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.success);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<KycProvider>();
    final isNew = !provider.isKycCompleted && !provider.isReturningPensioner;
    final stepNum = isNew ? 'Step-6' : 'Step-5';

    return Scaffold(
      appBar: KycHeader(title: 'Declaration [$stepNum]'),
      backgroundColor: AppTheme.pageBg,
      body: Consumer<KycProvider>(
        builder: (_, provider, __) {
          return ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppTheme.maxBodyWidth),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Q1: Re-employment ──────────────────────────────
                  _buildDeclarationCard(
                    question:
                        'सेवानिवृत्तीनंतर महाराष्ट्र शासनाचे अधिपत्याखालील तसेच सार्वजनिक उपक्रम किंवा स्थानिक प्राधिकरणातील कोणतीही नोकरी स्विकारलेली आहे का ?',
                    questionEn:
                        'Have you accepted any employment after retirement?',
                    isYes: _hasReemployed,
                    onChanged: (val) => setState(() => _hasReemployed = val),
                    children: _hasReemployed
                        ? [
                            const SizedBox(height: 12),
                            const Text(
                              'कार्यरत असलेली संस्था / कार्यालयाचे नांव व पत्ता',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextField(
                              controller: _orgController,
                              decoration: const InputDecoration(
                                hintText: 'Organisation Name and Address',
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'नवीन नियुक्तीचा दिनांक',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextField(
                              controller: _reemployedDateController,
                              readOnly: true,
                              onTap: () => _pickDate(
                                context: context,
                                controller: _reemployedDateController,
                                currentValue: _reemployedDate,
                                onDateSelected: (date) =>
                                    setState(() => _reemployedDate = date),
                              ),
                              decoration: InputDecoration(
                                hintText: 'Date of New Appointment',
                                suffixIcon: const Icon(
                                  Icons.calendar_today_outlined,
                                  size: 18,
                                ),
                                suffixIconConstraints: const BoxConstraints(
                                  minWidth: 40,
                                  minHeight: 40,
                                ),
                              ),
                            ),
                          ]
                        : [],
                  ),

                  const SizedBox(height: 16),

                  // ── Q2: Remarriage ─────────────────────────────────
                  _buildDeclarationCard(
                    question: 'पुनर्विवाह केला आहे का?',
                    questionEn: 'Have you remarried?',
                    isYes: _hasRemarried,
                    onChanged: (val) => setState(() => _hasRemarried = val),
                    children: _hasRemarried
                        ? [
                            const SizedBox(height: 12),
                            const Text(
                              'विवाहाची तारीख',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextField(
                              controller: _marriageDateController,
                              readOnly: true,
                              onTap: () => _pickDate(
                                context: context,
                                controller: _marriageDateController,
                                currentValue: _marriageDate,
                                onDateSelected: (date) =>
                                    setState(() => _marriageDate = date),
                              ),
                              decoration: InputDecoration(
                                hintText: 'Marriage Date',
                                suffixIcon: const Icon(
                                  Icons.calendar_today_outlined,
                                  size: 18,
                                ),
                                suffixIconConstraints: const BoxConstraints(
                                  minWidth: 40,
                                  minHeight: 40,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'विवाहाचे ठिकाण',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextField(
                              controller: _marriageLocationController,
                              decoration: const InputDecoration(
                                hintText: 'Marriage Location',
                              ),
                            ),
                          ]
                        : [],
                  ),

                  const SizedBox(height: 28),

                  // ── KEY CHANGE: calls dialog instead of _submit directly ──
                  GreenButton(
                    onPressed: provider.isLoading
                        ? null
                        : _showSubmitConfirmationDialog,
                    isLoading: provider.isLoading,
                    child: const Column(
                      children: [
                        Text(
                          'Submit Certificate',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'प्रमाणपत्र सादर करा',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // if (provider.error != null) ...[
                  //   const SizedBox(height: 16),
                  //   Container(
                  //     padding: const EdgeInsets.all(12),
                  //     decoration: BoxDecoration(
                  //       color: AppTheme.red.withValues(alpha: 0.1),
                  //       borderRadius: BorderRadius.circular(12),
                  //     ),
                  //     child: Text(
                  //       provider.error!,
                  //       style: const TextStyle(color: AppTheme.red),
                  //       textAlign: TextAlign.center,
                  //     ),
                  //   ),
                  // ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDeclarationCard({
    required String question,
    required String questionEn,
    required bool isYes,
    required ValueChanged<bool> onChanged,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.cardBorder, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            questionEn,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textTertiary,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _toggleButton('Yes / होय', isYes, () => onChanged(true)),
              const SizedBox(width: 10),
              _toggleButton('No / नाही', !isYes, () => onChanged(false)),
            ],
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _toggleButton(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppTheme.primaryBlue : const Color(0xFFCCCCCC),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : AppTheme.textSecondary,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
