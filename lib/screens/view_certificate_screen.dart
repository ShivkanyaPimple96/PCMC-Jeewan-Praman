import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../config/app_theme.dart';
import '../config/routes.dart';
import '../providers/kyc_provider.dart';
import '../utils/helpers.dart';
import '../widgets/detail_row.dart';
import '../widgets/kyc_header.dart';

class ViewCertificateScreen extends StatelessWidget {
  const ViewCertificateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const KycHeader(title: 'Life Certificate'),
      backgroundColor: AppTheme.pageBg,
      body: Consumer<KycProvider>(
        builder: (_, provider, __) {
          final certNo = certificateNumber(provider.certificateId);
          final certUrl =
              certificateUrl(provider.financialYear, provider.certificateId);

          return Center(
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(maxWidth: AppTheme.maxBodyWidth),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 80),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Certificate header card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: AppTheme.cardBorder, width: 1.5),
                      ),
                      child: Column(
                        children: [
                          // Logo row
                          Row(
                            children: [
                              Container(
                                width: 100,
                                height: 105,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: AppTheme.lightBlueBg,
                                  border:
                                      Border.all(color: AppTheme.cardBorder),
                                ),
                                child: const Icon(Icons.account_balance,
                                    size: 40, color: AppTheme.primaryBlue),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'पिंपरी चिंचवड महानगरपालिका',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: AppTheme.headerBlue,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    const Text(
                                      'Life Certificate',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      certNo,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.primaryBlue,
                                      ),
                                    ),
                                    Text(
                                      'Year: ${provider.financialYear ?? ''}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.textTertiary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // QR Code
                              if (certUrl.isNotEmpty)
                                QrImageView(
                                  data: certUrl,
                                  version: QrVersions.auto,
                                  size: 80,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Section 1: Pensioner details
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: AppTheme.cardBorder, width: 1.5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Pensioner Details',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.headerBlue,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Photo + details row
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Photo box
                              Container(
                                width: 100,
                                height: 120,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: const Color(0xFFCCCCCC),
                                      width: 1.5),
                                  color: const Color(0xFFE8E8E8),
                                ),
                                child: provider.photoUrl != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(7),
                                        child: Image.network(
                                          provider.photoUrl!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              const Icon(Icons.person,
                                                  size: 40,
                                                  color: AppTheme.textTertiary),
                                        ),
                                      )
                                    : const Icon(Icons.person,
                                        size: 40, color: AppTheme.textTertiary),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _certRow('Name', provider.name ?? '—'),
                                    _certRow('PPO No.', provider.ppoNo),
                                    _certRow('Gender', provider.gender ?? '—'),
                                    _certRow('Aadhaar',
                                        maskAadhaar(provider.aadhaarNumber)),
                                    _certRow('Mobile',
                                        maskMobile(provider.mobileNumber)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Section 2: Declaration
                    if (provider.declaration != null)
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppTheme.cardBorder, width: 1.5),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Declaration / घोषणापत्र',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.headerBlue,
                              ),
                            ),
                            const SizedBox(height: 10),
                            DetailRow(
                              label: 'Re-employed',
                              value: provider.declaration!.hasReemployed
                                  ? 'Yes / होय'
                                  : 'No / नाही',
                            ),
                            if (provider.declaration!.hasReemployed) ...[
                              DetailRow(
                                label: 'Organisation',
                                value: provider
                                        .declaration!.reemployedOrganisation ??
                                    '—',
                              ),
                              DetailRow(
                                label: 'Date',
                                value:
                                    provider.declaration!.reemployedDate ?? '—',
                              ),
                            ],
                            DetailRow(
                              label: 'Remarried',
                              value: provider.declaration!.hasRemarried
                                  ? 'Yes / होय'
                                  : 'No / नाही',
                            ),
                            if (provider.declaration!.hasRemarried) ...[
                              DetailRow(
                                label: 'Marriage Date',
                                value:
                                    provider.declaration!.marriageDate ?? '—',
                              ),
                              DetailRow(
                                label: 'Location',
                                value: provider.declaration!.marriageLocation ??
                                    '—',
                                isLast: true,
                              ),
                            ],
                          ],
                        ),
                      ),

                    const SizedBox(height: 24),

                    // Back to Home
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            AppRoutes.start,
                            (route) => false,
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                          side: const BorderSide(
                              color: AppTheme.primaryBlue, width: 1.5),
                        ),
                        child: const Text('Back to Home'),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _certRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Text(label,
                style: const TextStyle(
                    fontSize: 11, color: AppTheme.textTertiary)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark)),
          ),
        ],
      ),
    );
  }
}
