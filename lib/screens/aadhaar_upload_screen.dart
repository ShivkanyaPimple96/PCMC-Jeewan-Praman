import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../config/routes.dart';
import '../providers/kyc_provider.dart';
import '../widgets/kyc_header.dart';
import '../widgets/upload_area.dart';
import '../widgets/green_button.dart';

class AadhaarUploadScreen extends StatefulWidget {
  const AadhaarUploadScreen({super.key});

  @override
  State<AadhaarUploadScreen> createState() => _AadhaarUploadScreenState();
}

class _AadhaarUploadScreenState extends State<AadhaarUploadScreen> {
  File? _frontImage;
  File? _backImage;
  bool _uploading = false;

  Future<void> _pickImage(bool isFront) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
      maxWidth: 1200,
    );
    if (image != null) {
      setState(() {
        if (isFront) {
          _frontImage = File(image.path);
        } else {
          _backImage = File(image.path);
        }
      });
    }
  }

  Future<void> _upload() async {
    if (_frontImage == null || _backImage == null) return;

    setState(() => _uploading = true);
    final provider = context.read<KycProvider>();

    try {
      final frontResp = await provider.api.uploadFile(
        file: _frontImage!,
        endpoint: 'aadhaar-front',
        ppoNo: provider.ppoNo,
        year: provider.uploadYear,
      );
      if (frontResp.url != null) provider.aadhaarFrontUrl = frontResp.url;

      final backResp = await provider.api.uploadFile(
        file: _backImage!,
        endpoint: 'aadhaar-back',
        ppoNo: provider.ppoNo,
        year: provider.uploadYear,
      );
      if (backResp.url != null) provider.aadhaarBackUrl = backResp.url;

      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.photoCapture);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Upload failed. Please try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const KycHeader(title: 'Upload Aadhaar Card'),
      backgroundColor: AppTheme.pageBg,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppTheme.maxBodyWidth),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 80),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Front
                UploadArea(
                  label: 'Aadhaar Front Photo',
                  sublabel: 'आधार कार्डचा समोरील फोटो काढा',
                  hint: 'Tap to capture',
                  icon: Icons.camera_alt,
                  imageFile: _frontImage,
                  onTap: () => _pickImage(true),
                ),
                if (_frontImage != null) ...[
                  const SizedBox(height: 6),
                  _retakeButton(() => _pickImage(true)),
                ],
                const SizedBox(height: 16),

                // Back
                UploadArea(
                  label: 'Aadhaar Back Photo',
                  sublabel: 'आधार कार्डचा मागील फोटो काढा',
                  hint: 'Tap to capture',
                  icon: Icons.camera_alt,
                  imageFile: _backImage,
                  onTap: () => _pickImage(false),
                ),
                if (_backImage != null) ...[
                  const SizedBox(height: 6),
                  _retakeButton(() => _pickImage(false)),
                ],
                const SizedBox(height: 28),

                GreenButton(
                  onPressed:
                      (_frontImage != null && _backImage != null && !_uploading)
                          ? _upload
                          : null,
                  isLoading: _uploading,
                  child: const Text('Submit & Continue'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _retakeButton(VoidCallback onTap) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: const Text(
          'Retake Photo',
          style: TextStyle(
            color: AppTheme.primaryBlue,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }
}
