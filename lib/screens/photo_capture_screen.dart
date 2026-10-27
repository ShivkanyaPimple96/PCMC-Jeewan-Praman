import 'dart:io';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../config/app_theme.dart';
import '../config/routes.dart';
import '../providers/kyc_provider.dart';
import '../widgets/green_button.dart';
import '../widgets/kyc_header.dart';

// ─────────────────────────────────────────────────────────────────────────────
// OVAL OVERLAY PAINTER
// ─────────────────────────────────────────────────────────────────────────────

class _OvalOverlayPainter extends CustomPainter {
  final double animValue;
  final bool faceDetected;

  _OvalOverlayPainter({required this.animValue, required this.faceDetected});

  @override
  void paint(Canvas canvas, Size size) {
    final ovalW = size.width * 0.72;
    final ovalH = ovalW * 1.28;
    final ovalRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height * 0.46),
      width: ovalW,
      height: ovalH,
    );

    // Scrim — darken everything outside the oval
    final scrimPaint = Paint()..color = Colors.black.withOpacity(0.55);
    final scrimPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addOval(ovalRect);
    canvas.drawPath(scrimPath..fillType = PathFillType.evenOdd, scrimPaint);

    // Spinning arc border
    final borderColor =
        faceDetected ? Colors.greenAccent : Colors.white.withOpacity(0.9);
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    const arcSpan = math.pi * 1.6;
    final startAngle = animValue * 2 * math.pi;
    canvas.drawArc(ovalRect, startAngle, arcSpan, false, borderPaint);

    // Static thin base ring
    final basePaint = Paint()
      ..color = Colors.white.withOpacity(0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawOval(ovalRect, basePaint);
  }

  @override
  bool shouldRepaint(_OvalOverlayPainter old) =>
      old.animValue != animValue || old.faceDetected != faceDetected;
}

// ─────────────────────────────────────────────────────────────────────────────
// LIVE CAMERA CAPTURE SCREEN  (full-screen with oval overlay)
// ─────────────────────────────────────────────────────────────────────────────

class _LiveCaptureScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  final void Function(File photo) onCaptured;

  const _LiveCaptureScreen({required this.cameras, required this.onCaptured});

  @override
  State<_LiveCaptureScreen> createState() => _LiveCaptureScreenState();
}

class _LiveCaptureScreenState extends State<_LiveCaptureScreen>
    with TickerProviderStateMixin {
  CameraController? _controller;
  late AnimationController _spinCtrl;
  bool _capturing = false;

  CameraLensDirection _currentDirection = CameraLensDirection.front;
  bool _switching = false;

  @override
  void initState() {
    super.initState();
    _spinCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _initCamera(_currentDirection);
  }

  Future<void> _initCamera(CameraLensDirection direction) async {
    final selected = widget.cameras.firstWhere(
      (c) => c.lensDirection == direction,
      orElse: () => widget.cameras.first,
    );

    final oldController = _controller;
    _controller = null;
    if (mounted) setState(() {});
    await oldController?.dispose();

    final newController = CameraController(
      selected,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    await newController.initialize();
    if (!mounted) {
      await newController.dispose();
      return;
    }

    _controller = newController;
    _currentDirection = direction;
    setState(() {});
  }

  Future<void> _switchCamera() async {
    if (_switching || _capturing) return;

    final nextDirection = _currentDirection == CameraLensDirection.front
        ? CameraLensDirection.back
        : CameraLensDirection.front;

    final hasNext = widget.cameras.any((c) => c.lensDirection == nextDirection);
    if (!hasNext) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('No other camera found on this device.')),
        );
      }
      return;
    }

    setState(() => _switching = true);
    await _initCamera(nextDirection);
    if (mounted) setState(() => _switching = false);
  }

  @override
  void dispose() {
    _spinCtrl.dispose();
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _capture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (_capturing) return;

    setState(() => _capturing = true);
    try {
      final xFile = await _controller!.takePicture();
      final compressed = await _compressImage(File(xFile.path));
      widget.onCaptured(compressed);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Capture failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _capturing = false);
    }
  }

  Future<File> _compressImage(File file) async {
    final dir = await getTemporaryDirectory();
    final targetPath =
        '${dir.path}/photo_compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 30,
      minWidth: 640,
      minHeight: 640,
      // format: CompressFormat.jpeg,
    );
    return result != null ? File(result.path) : file;
  }

  @override
  Widget build(BuildContext context) {
    final isReady = _controller != null && _controller!.value.isInitialized;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Camera Preview ──────────────────────────────────────────────
          if (isReady)
            CameraPreview(_controller!)
          else
            const Center(child: CircularProgressIndicator(color: Colors.white)),

          // ── Animated Oval Overlay ───────────────────────────────────────
          if (isReady)
            AnimatedBuilder(
              animation: _spinCtrl,
              builder: (_, __) => CustomPaint(
                painter: _OvalOverlayPainter(
                  animValue: _spinCtrl.value,
                  faceDetected: false,
                ),
              ),
            ),

          // ── Top bar: [Close] ··· [Switch Camera] ───────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black38,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.close,
                                color: Colors.white, size: 22),
                          ),
                        ),
                        if (widget.cameras.length > 1)
                          GestureDetector(
                            onTap: _switching ? null : _switchCamera,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _switching
                                    ? Colors.black12
                                    : Colors.black38,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: _switching
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.flip_camera_ios_rounded,
                                      color: Colors.white, size: 26),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Get ready...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _currentDirection == CameraLensDirection.front
                          ? 'Position your face inside the oval'
                          : 'Using back camera — aim at the subject',
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Bottom: Tips + Shutter + active-camera label ────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '• Look straight  • Good lighting  • No glasses',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(width: 80),
                        // Shutter button
                        GestureDetector(
                          onTap: _capturing ? null : _capture,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _capturing
                                  ? Colors.grey.shade400
                                  : Colors.white,
                              border:
                                  Border.all(color: Colors.white54, width: 4),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.25),
                                  blurRadius: 16,
                                ),
                              ],
                            ),
                            child: _capturing
                                ? const Padding(
                                    padding: EdgeInsets.all(20),
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.white),
                                  )
                                : const Icon(Icons.camera_alt_rounded,
                                    size: 32, color: Colors.black87),
                          ),
                        ),
                        // Active-camera badge
                        SizedBox(
                          width: 80,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.black45,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _currentDirection == CameraLensDirection.front
                                    ? '🤳 Front'
                                    : '📷 Back',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Tap to capture',
                      style: TextStyle(color: Colors.white60, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PHOTO CAPTURE SCREEN  (Orchestrator: Tutorial → Live Camera → Preview)
// ─────────────────────────────────────────────────────────────────────────────

enum _CaptureStep { tutorial, camera, preview }

class PhotoCaptureScreen extends StatefulWidget {
  const PhotoCaptureScreen({super.key});

  @override
  State<PhotoCaptureScreen> createState() => _PhotoCaptureScreenState();
}

class _PhotoCaptureScreenState extends State<PhotoCaptureScreen> {
  _CaptureStep _step = _CaptureStep.tutorial;
  File? _photo;
  bool _uploading = false;
  bool _locationGranted = false;
  List<CameraDescription> _cameras = [];

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // LOCATION PERMISSION  (unchanged)
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        _showLocationRequiredDialog(
          'Location services are disabled. Please enable GPS to proceed.\n\nजीपीएस सक्षम करा.',
        );
      }
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      if (mounted) {
        _showLocationRequiredDialog(
          'Location permission is required to submit your photo. Please allow location access.\n\nकृपया स्थान परवानगी द्या.',
        );
      }
      return;
    }

    setState(() => _locationGranted = true);
  }

  void _showLocationRequiredDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Location Required',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await Geolocator.openLocationSettings();
              await Future.delayed(const Duration(seconds: 1));
              if (mounted) _checkLocationPermission();
            },
            child: const Text('Open Settings'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _checkLocationPermission();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // OPEN LIVE CAMERA  (replaces ImagePicker)
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _openCamera() async {
    if (!_locationGranted) {
      _checkLocationPermission();
      return;
    }

    // Load available cameras once
    try {
      _cameras = await availableCameras();
    } catch (_) {
      _cameras = [];
    }

    if (_cameras.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No cameras available on this device.')),
        );
      }
      return;
    }

    if (mounted) setState(() => _step = _CaptureStep.camera);
  }

  void _onPhotoCaptured(File photo) {
    setState(() {
      _photo = photo;
      _step = _CaptureStep.preview;
    });
  }

  void _retakePhoto() {
    setState(() {
      _photo = null;
      _step = _CaptureStep.camera;
    });
  }

  // ─────────────────────────────────────────────────────────────────────────
  // LOCATION FETCH  (unchanged)
  // ─────────────────────────────────────────────────────────────────────────

  Future<Position> _getLocation() async {
    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // CONFIRMATION DIALOG  (unchanged)
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _showSubmitConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          title: const Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.green, size: 28),
              SizedBox(width: 10),
              Text(
                'Confirm Submission',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Divider(thickness: 2.5),
              SizedBox(height: 8),
              Text(
                'Are you sure you want to submit the photo?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 6),
              Text(
                'तुम्हाला खात्री आहे की तुम्ही हा फोटो सबमिट करू इच्छिता?',
                style: TextStyle(fontSize: 14, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Divider(thickness: 2.5),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                    fontSize: 15),
              ),
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _uploadAndContinue();
              },
              child: const Text(
                'Submit',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15),
              ),
            ),
          ],
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // UPLOAD  (unchanged)
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _uploadAndContinue() async {
    if (_photo == null || !_locationGranted) return;

    setState(() => _uploading = true);
    final provider = context.read<KycProvider>();

    try {
      final position = await _getLocation();
      provider.latitude = position.latitude;
      provider.longitude = position.longitude;

      final resp = await provider.api.uploadFile(
        file: _photo!,
        endpoint: 'photo',
        ppoNo: provider.ppoNo,
        year: provider.uploadYear,
      );
      if (resp.url != null) provider.photoUrl = resp.url;

      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.videoCapture);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed: ${e.toString().contains('Location') ? 'Could not get location. Please enable GPS.' : 'Upload failed. Please try again.'}',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // DO / DON'T GUIDE  (unchanged)
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildDoDontGuide() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF92B7F7), width: 1.5),
        boxShadow: const [
          BoxShadow(
              color: Color(0x1A000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              'assets/images/capture_image.jpeg',
              width: double.infinity,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Container(
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.image_not_supported,
                          size: 40, color: Colors.grey),
                      SizedBox(height: 8),
                      Text(
                        'Add your image to:\nassets/images/capture_image.jpeg',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          // ── Click Photo button now opens the live camera ───────────────
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed:
                  _locationGranted ? _openCamera : _checkLocationPermission,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF92B7F7),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 2,
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Click Photo',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'फोटो काढा',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // CAPTURED PHOTO PREVIEW  (unchanged)
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildPhotoPreview() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF92B7F7), width: 1.5),
        boxShadow: const [
          BoxShadow(
              color: Color(0x1A000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.file(
              _photo!,
              width: double.infinity,
              height: 280,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _retakePhoto,
              icon: const Icon(Icons.camera_alt,
                  color: Color(0xFF92B7F7), size: 20),
              label: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Retake Photo',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF92B7F7)),
                  ),
                  Text(
                    'पुन्हा फोटो काढा',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF92B7F7)),
                  ),
                ],
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF92B7F7), width: 1.5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // TUTORIAL / PREVIEW SCAFFOLD  (shared wrapper)
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildMainScaffold() {
    final provider = context.watch<KycProvider>();
    final isNew = !provider.isKycCompleted && !provider.isReturningPensioner;
    final stepNum = isNew ? 'Step-4' : 'Step-3';

    return Scaffold(
      appBar: KycHeader(title: 'Upload Photo [$stepNum]'),
      backgroundColor: AppTheme.pageBg,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppTheme.maxBodyWidth),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 80),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Click Pensioner Photo',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      letterSpacing: 0.5),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                const Text(
                  'पेन्शनर व्यक्तीचा फोटो काढा',
                  style: TextStyle(fontSize: 15, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Location warning banner
                if (!_locationGranted) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3CD),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFFE69C)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_off,
                            color: AppTheme.pendingOrange, size: 22),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Location permission is required',
                                style: TextStyle(
                                    fontWeight: FontWeight.w700, fontSize: 14),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'स्थान परवानगी आवश्यक आहे',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textSecondary),
                              ),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: _checkLocationPermission,
                                child: const Text(
                                  'Tap to enable / सक्षम करण्यासाठी टॅप करा',
                                  style: TextStyle(
                                      color: AppTheme.primaryBlue,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                      decoration: TextDecoration.underline),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Guide card OR photo preview
                _photo == null ? _buildDoDontGuide() : _buildPhotoPreview(),

                const SizedBox(height: 28),

                // Submit button
                GreenButton(
                  onPressed: (_photo != null && !_uploading && _locationGranted)
                      ? _showSubmitConfirmationDialog
                      : null,
                  isLoading: _uploading,
                  child: const Column(
                    children: [
                      Text(
                        'Submit Photo',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'फोटो सबमिट करा',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ROOT BUILD
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_step == _CaptureStep.camera) {
      if (_cameras.isEmpty) {
        return const Scaffold(
          body: Center(child: Text('No cameras available.')),
        );
      }
      return _LiveCaptureScreen(
        cameras: _cameras,
        onCaptured: _onPhotoCaptured,
      );
    }

    // tutorial or preview step — both use the same KYC scaffold
    return _buildMainScaffold();
  }
}

// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:flutter_image_compress/flutter_image_compress.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:provider/provider.dart';

// import '../config/app_theme.dart';
// import '../config/routes.dart';
// import '../providers/kyc_provider.dart';
// import '../widgets/green_button.dart';
// import '../widgets/kyc_header.dart';

// class PhotoCaptureScreen extends StatefulWidget {
//   const PhotoCaptureScreen({super.key});

//   @override
//   State<PhotoCaptureScreen> createState() => _PhotoCaptureScreenState();
// }

// class _PhotoCaptureScreenState extends State<PhotoCaptureScreen> {
//   File? _photo;
//   bool _uploading = false;
//   bool _locationGranted = false;

//   @override
//   void initState() {
//     super.initState();
//     _checkLocationPermission();
//   }

//   // ─────────────────────────────────────────────────────────────────────────
//   // LOCATION PERMISSION
//   // ─────────────────────────────────────────────────────────────────────────

//   Future<void> _checkLocationPermission() async {
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       if (mounted) {
//         _showLocationRequiredDialog(
//           'Location services are disabled. Please enable GPS to proceed.\n\nजीपीएस सक्षम करा.',
//         );
//       }
//       return;
//     }

//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//     }

//     if (permission == LocationPermission.denied ||
//         permission == LocationPermission.deniedForever) {
//       if (mounted) {
//         _showLocationRequiredDialog(
//           'Location permission is required to submit your photo. Please allow location access.\n\nकृपया स्थान परवानगी द्या.',
//         );
//       }
//       return;
//     }

//     setState(() => _locationGranted = true);
//   }

//   void _showLocationRequiredDialog(String message) {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (_) => AlertDialog(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16),
//         ),
//         title: const Text(
//           'Location Required',
//           style: TextStyle(fontWeight: FontWeight.w700),
//         ),
//         content: Text(message),
//         actions: [
//           TextButton(
//             onPressed: () async {
//               Navigator.pop(context);
//               await Geolocator.openLocationSettings();
//               await Future.delayed(const Duration(seconds: 1));
//               if (mounted) _checkLocationPermission();
//             },
//             child: const Text('Open Settings'),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//               _checkLocationPermission();
//             },
//             child: const Text('Retry'),
//           ),
//         ],
//       ),
//     );
//   }

//   // ─────────────────────────────────────────────────────────────────────────
//   // PHOTO CAPTURE & COMPRESS
//   // ─────────────────────────────────────────────────────────────────────────

//   Future<void> _capturePhoto() async {
//     if (!_locationGranted) {
//       _checkLocationPermission();
//       return;
//     }

//     final picker = ImagePicker();
//     final image = await picker.pickImage(
//       source: ImageSource.camera,
//       preferredCameraDevice: CameraDevice.front,
//       imageQuality: 85,
//       maxWidth: 1024,
//     );
//     if (image == null) return;

//     final compressed = await _compressImage(File(image.path));
//     setState(() => _photo = compressed);
//   }

//   Future<File> _compressImage(File file) async {
//     final dir = await getTemporaryDirectory();
//     final targetPath =
//         '${dir.path}/photo_compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';

//     final result = await FlutterImageCompress.compressAndGetFile(
//       file.absolute.path,
//       targetPath,
//       quality: 70,
//       minWidth: 640,
//       minHeight: 640,
//       format: CompressFormat.jpeg,
//     );

//     return result != null ? File(result.path) : file;
//   }

//   // ─────────────────────────────────────────────────────────────────────────
//   // LOCATION FETCH
//   // ─────────────────────────────────────────────────────────────────────────

//   Future<Position> _getLocation() async {
//     return await Geolocator.getCurrentPosition(
//       locationSettings: const LocationSettings(
//         accuracy: LocationAccuracy.high,
//         timeLimit: Duration(seconds: 10),
//       ),
//     );
//   }

//   // ─────────────────────────────────────────────────────────────────────────
//   // CONFIRMATION DIALOG
//   // ─────────────────────────────────────────────────────────────────────────

//   Future<void> _showSubmitConfirmationDialog() async {
//     return showDialog<void>(
//       context: context,
//       barrierDismissible: true,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20.0),
//           ),
//           title: const Row(
//             children: [
//               Icon(Icons.check_circle_outline, color: Colors.green, size: 28),
//               SizedBox(width: 10),
//               Text(
//                 'Confirm Submission',
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//           content: const Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Divider(thickness: 2.5),
//               SizedBox(height: 8),
//               Text(
//                 'Are you sure you want to submit the photo?',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//               SizedBox(height: 6),
//               Text(
//                 'तुम्हाला खात्री आहे की तुम्ही हा फोटो सबमिट करू इच्छिता?',
//                 style: TextStyle(fontSize: 14, color: Colors.black54),
//                 textAlign: TextAlign.center,
//               ),
//               SizedBox(height: 8),
//               Divider(thickness: 2.5),
//             ],
//           ),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: const Text(
//                 'Cancel',
//                 style: TextStyle(
//                   color: Colors.red,
//                   fontWeight: FontWeight.w600,
//                   fontSize: 15,
//                 ),
//               ),
//             ),
//             TextButton(
//               style: TextButton.styleFrom(
//                 backgroundColor: Colors.green,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12.0),
//                 ),
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 20,
//                   vertical: 10,
//                 ),
//               ),
//               onPressed: () {
//                 Navigator.of(context).pop();
//                 _uploadAndContinue();
//               },
//               child: const Text(
//                 'Submit',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.w700,
//                   fontSize: 15,
//                 ),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   // ─────────────────────────────────────────────────────────────────────────
//   // UPLOAD
//   // ─────────────────────────────────────────────────────────────────────────

//   Future<void> _uploadAndContinue() async {
//     if (_photo == null || !_locationGranted) return;

//     setState(() => _uploading = true);
//     final provider = context.read<KycProvider>();

//     try {
//       final position = await _getLocation();
//       provider.latitude = position.latitude;
//       provider.longitude = position.longitude;

//       final resp = await provider.api.uploadFile(
//         file: _photo!,
//         endpoint: 'photo',
//         ppoNo: provider.ppoNo,
//         year: provider.uploadYear,
//       );
//       if (resp.url != null) provider.photoUrl = resp.url;

//       if (mounted) {
//         Navigator.pushReplacementNamed(context, AppRoutes.videoCapture);
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//               'Failed: ${e.toString().contains('Location') ? 'Could not get location. Please enable GPS.' : 'Upload failed. Please try again.'}',
//             ),
//           ),
//         );
//       }
//     } finally {
//       if (mounted) setState(() => _uploading = false);
//     }
//   }

//   // ─────────────────────────────────────────────────────────────────────────
//   // DO / DON'T GUIDE  — single combined image
//   // Put your image at:  assets/images/photo_do_dont.png
//   // ─────────────────────────────────────────────────────────────────────────

//   Widget _buildDoDontGuide() {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: const Color(0xFF92B7F7), width: 1.5),
//         boxShadow: const [
//           BoxShadow(
//             color: Color(0x1A000000),
//             blurRadius: 8,
//             offset: Offset(0, 2),
//           ),
//         ],
//       ),
//       padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
//       child: Column(
//         children: [
//           // ── Combined DO / DON'T image ──────────────────────────
//           ClipRRect(
//             borderRadius: BorderRadius.circular(10),
//             child: Image.asset(
//               'assets/images/capture_image.jpeg',
//               width: double.infinity,
//               fit: BoxFit.contain,
//               errorBuilder: (_, __, ___) => Container(
//                 height: 180,
//                 decoration: BoxDecoration(
//                   color: Colors.grey.shade100,
//                   borderRadius: BorderRadius.circular(10),
//                   border: Border.all(color: Colors.grey.shade300),
//                 ),
//                 child: const Center(
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Icon(Icons.image_not_supported,
//                           size: 40, color: Colors.grey),
//                       SizedBox(height: 8),
//                       Text(
//                         'Add your image to:\nassets/images/photo_do_dont.png',
//                         textAlign: TextAlign.center,
//                         style: TextStyle(color: Colors.grey, fontSize: 12),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),

//           const SizedBox(height: 14),

//           // ── Click Photo button inside the card ─────────────────
//           SizedBox(
//             width: double.infinity,
//             child: ElevatedButton(
//               onPressed:
//                   _locationGranted ? _capturePhoto : _checkLocationPermission,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF92B7F7),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(30),
//                 ),
//                 padding: const EdgeInsets.symmetric(vertical: 14),
//                 elevation: 2,
//               ),
//               child: const Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     'Click Photo',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w700,
//                       color: Colors.black,
//                     ),
//                   ),
//                   SizedBox(height: 2),
//                   Text(
//                     'फोटो काढा',
//                     style: TextStyle(
//                       fontSize: 13,
//                       fontWeight: FontWeight.w500,
//                       color: Colors.black87,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ─────────────────────────────────────────────────────────────────────────
//   // CAPTURED PHOTO PREVIEW
//   // ─────────────────────────────────────────────────────────────────────────

//   Widget _buildPhotoPreview() {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: const Color(0xFF92B7F7), width: 1.5),
//         boxShadow: const [
//           BoxShadow(
//             color: Color(0x1A000000),
//             blurRadius: 8,
//             offset: Offset(0, 2),
//           ),
//         ],
//       ),
//       padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
//       child: Column(
//         children: [
//           // ── Preview image ──────────────────────────────────────
//           ClipRRect(
//             borderRadius: BorderRadius.circular(10),
//             child: Image.file(
//               _photo!,
//               width: double.infinity,
//               height: 280,
//               fit: BoxFit.cover,
//             ),
//           ),

//           const SizedBox(height: 14),

//           // ── Retake button ──────────────────────────────────────
//           SizedBox(
//             width: double.infinity,
//             child: OutlinedButton.icon(
//               onPressed: _capturePhoto,
//               icon: const Icon(Icons.camera_alt,
//                   color: Color(0xFF92B7F7), size: 20),
//               label: const Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     'Retake Photo',
//                     style: TextStyle(
//                       fontSize: 15,
//                       fontWeight: FontWeight.w700,
//                       color: Color(0xFF92B7F7),
//                     ),
//                   ),
//                   Text(
//                     'पुन्हा फोटो काढा',
//                     style: TextStyle(
//                       fontSize: 12,
//                       fontWeight: FontWeight.w500,
//                       color: Color(0xFF92B7F7),
//                     ),
//                   ),
//                 ],
//               ),
//               style: OutlinedButton.styleFrom(
//                 side: const BorderSide(color: Color(0xFF92B7F7), width: 1.5),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(30),
//                 ),
//                 padding: const EdgeInsets.symmetric(vertical: 12),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ─────────────────────────────────────────────────────────────────────────
//   // BUILD
//   // ─────────────────────────────────────────────────────────────────────────

//   @override
//   Widget build(BuildContext context) {
//     final provider = context.watch<KycProvider>();
//     final isNew = !provider.isKycCompleted && !provider.isReturningPensioner;
//     final stepNum = isNew ? 'Step-4' : 'Step-3';

//     return Scaffold(
//       appBar: KycHeader(title: 'Upload Photo [$stepNum]'),
//       backgroundColor: AppTheme.pageBg,
//       body: Center(
//         child: ConstrainedBox(
//           constraints: const BoxConstraints(maxWidth: AppTheme.maxBodyWidth),
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.fromLTRB(16, 20, 16, 80),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 // ── Page title ───────────────────────────────────────────
//                 const Text(
//                   'Click Pensioner Photo',
//                   style: TextStyle(
//                     fontSize: 22,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black87,
//                     letterSpacing: 0.5,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 4),
//                 const Text(
//                   'पेन्शनर व्यक्तीचा फोटो काढा',
//                   style: TextStyle(
//                     fontSize: 15,
//                     color: Colors.black54,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 16),

//                 // ── Location warning banner ──────────────────────────────
//                 if (!_locationGranted) ...[
//                   Container(
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       color: const Color(0xFFFFF3CD),
//                       borderRadius: BorderRadius.circular(12),
//                       border: Border.all(color: const Color(0xFFFFE69C)),
//                     ),
//                     child: Row(
//                       children: [
//                         const Icon(
//                           Icons.location_off,
//                           color: AppTheme.pendingOrange,
//                           size: 22,
//                         ),
//                         const SizedBox(width: 10),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               const Text(
//                                 'Location permission is required',
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.w700,
//                                   fontSize: 14,
//                                 ),
//                               ),
//                               const SizedBox(height: 2),
//                               const Text(
//                                 'स्थान परवानगी आवश्यक आहे',
//                                 style: TextStyle(
//                                   fontSize: 12,
//                                   color: AppTheme.textSecondary,
//                                 ),
//                               ),
//                               const SizedBox(height: 8),
//                               GestureDetector(
//                                 onTap: _checkLocationPermission,
//                                 child: const Text(
//                                   'Tap to enable / सक्षम करण्यासाठी टॅप करा',
//                                   style: TextStyle(
//                                     color: AppTheme.primaryBlue,
//                                     fontWeight: FontWeight.w600,
//                                     fontSize: 13,
//                                     decoration: TextDecoration.underline,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                 ],

//                 // ── Show DO/DON'T guide OR captured photo preview ────────
//                 // Before capture → show guide with Click Photo button inside
//                 // After capture  → show photo preview with Retake button
//                 _photo == null ? _buildDoDontGuide() : _buildPhotoPreview(),

//                 const SizedBox(height: 28),

//                 // ── Submit button ────────────────────────────────────────
//                 GreenButton(
//                   onPressed: (_photo != null && !_uploading && _locationGranted)
//                       ? _showSubmitConfirmationDialog
//                       : null,
//                   isLoading: _uploading,
//                   child: const Column(
//                     children: [
//                       Text(
//                         'Submit Photo',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w700,
//                         ),
//                       ),
//                       SizedBox(height: 2),
//                       Text(
//                         'फोटो सबमिट करा',
//                         style: TextStyle(
//                           fontSize: 12,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:flutter_image_compress/flutter_image_compress.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:provider/provider.dart';

// import '../config/app_theme.dart';
// import '../config/routes.dart';
// import '../providers/kyc_provider.dart';
// import '../widgets/green_button.dart';
// import '../widgets/kyc_header.dart';

// class PhotoCaptureScreen extends StatefulWidget {
//   const PhotoCaptureScreen({super.key});

//   @override
//   State<PhotoCaptureScreen> createState() => _PhotoCaptureScreenState();
// }

// class _PhotoCaptureScreenState extends State<PhotoCaptureScreen> {
//   File? _photo;
//   bool _uploading = false;
//   bool _locationGranted = false;

//   @override
//   void initState() {
//     super.initState();
//     _checkLocationPermission();
//   }

//   // ─────────────────────────────────────────────────────────────────────────
//   // LOCATION PERMISSION
//   // ─────────────────────────────────────────────────────────────────────────

//   Future<void> _checkLocationPermission() async {
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       if (mounted) {
//         _showLocationRequiredDialog(
//           'Location services are disabled. Please enable GPS to proceed.\n\nजीपीएस सक्षम करा.',
//         );
//       }
//       return;
//     }

//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//     }

//     if (permission == LocationPermission.denied ||
//         permission == LocationPermission.deniedForever) {
//       if (mounted) {
//         _showLocationRequiredDialog(
//           'Location permission is required to submit your photo. Please allow location access.\n\nकृपया स्थान परवानगी द्या.',
//         );
//       }
//       return;
//     }

//     setState(() => _locationGranted = true);
//   }

//   void _showLocationRequiredDialog(String message) {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (_) => AlertDialog(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16),
//         ),
//         title: const Text(
//           'Location Required',
//           style: TextStyle(fontWeight: FontWeight.w700),
//         ),
//         content: Text(message),
//         actions: [
//           TextButton(
//             onPressed: () async {
//               Navigator.pop(context);
//               await Geolocator.openLocationSettings();
//               await Future.delayed(const Duration(seconds: 1));
//               if (mounted) _checkLocationPermission();
//             },
//             child: const Text('Open Settings'),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//               _checkLocationPermission();
//             },
//             child: const Text('Retry'),
//           ),
//         ],
//       ),
//     );
//   }

//   // ─────────────────────────────────────────────────────────────────────────
//   // PHOTO CAPTURE & COMPRESS
//   // ─────────────────────────────────────────────────────────────────────────

//   Future<void> _capturePhoto() async {
//     if (!_locationGranted) {
//       _checkLocationPermission();
//       return;
//     }

//     final picker = ImagePicker();
//     final image = await picker.pickImage(
//       source: ImageSource.camera,
//       preferredCameraDevice: CameraDevice.front,
//       imageQuality: 85,
//       maxWidth: 1024,
//     );
//     if (image == null) return;

//     final compressed = await _compressImage(File(image.path));
//     setState(() => _photo = compressed);
//   }

//   Future<File> _compressImage(File file) async {
//     final dir = await getTemporaryDirectory();
//     final targetPath =
//         '${dir.path}/photo_compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';

//     final result = await FlutterImageCompress.compressAndGetFile(
//       file.absolute.path,
//       targetPath,
//       quality: 70,
//       minWidth: 640,
//       minHeight: 640,
//       format: CompressFormat.jpeg,
//     );

//     return result != null ? File(result.path) : file;
//   }

//   // ─────────────────────────────────────────────────────────────────────────
//   // LOCATION FETCH
//   // ─────────────────────────────────────────────────────────────────────────

//   Future<Position> _getLocation() async {
//     return await Geolocator.getCurrentPosition(
//       locationSettings: const LocationSettings(
//         accuracy: LocationAccuracy.high,
//         timeLimit: Duration(seconds: 10),
//       ),
//     );
//   }

//   // ─────────────────────────────────────────────────────────────────────────
//   // CONFIRMATION DIALOG
//   // ─────────────────────────────────────────────────────────────────────────

//   Future<void> _showSubmitConfirmationDialog() async {
//     return showDialog<void>(
//       context: context,
//       barrierDismissible: true,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20.0),
//           ),
//           title: const Row(
//             children: [
//               Icon(Icons.check_circle_outline, color: Colors.green, size: 28),
//               SizedBox(width: 10),
//               Text(
//                 'Confirm Submission',
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//           content: const Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Divider(thickness: 2.5),
//               SizedBox(height: 8),
//               Text(
//                 'Are you sure you want to submit the photo?',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//               SizedBox(height: 6),
//               Text(
//                 'तुम्हाला खात्री आहे की तुम्ही हा फोटो सबमिट करू इच्छिता?',
//                 style: TextStyle(fontSize: 14, color: Colors.black54),
//                 textAlign: TextAlign.center,
//               ),
//               SizedBox(height: 8),
//               Divider(thickness: 2.5),
//             ],
//           ),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: const Text(
//                 'Cancel',
//                 style: TextStyle(
//                   color: Colors.red,
//                   fontWeight: FontWeight.w600,
//                   fontSize: 15,
//                 ),
//               ),
//             ),
//             TextButton(
//               style: TextButton.styleFrom(
//                 backgroundColor: Colors.green,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12.0),
//                 ),
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 20,
//                   vertical: 10,
//                 ),
//               ),
//               onPressed: () {
//                 Navigator.of(context).pop();
//                 _uploadAndContinue();
//               },
//               child: const Text(
//                 'Submit',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.w700,
//                   fontSize: 15,
//                 ),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   // ─────────────────────────────────────────────────────────────────────────
//   // UPLOAD
//   // ─────────────────────────────────────────────────────────────────────────

//   Future<void> _uploadAndContinue() async {
//     if (_photo == null || !_locationGranted) return;

//     setState(() => _uploading = true);
//     final provider = context.read<KycProvider>();

//     try {
//       final position = await _getLocation();
//       provider.latitude = position.latitude;
//       provider.longitude = position.longitude;

//       final resp = await provider.api.uploadFile(
//         file: _photo!,
//         endpoint: 'photo',
//         ppoNo: provider.ppoNo,
//         year: provider.uploadYear,
//       );
//       if (resp.url != null) provider.photoUrl = resp.url;

//       if (mounted) {
//         Navigator.pushReplacementNamed(context, AppRoutes.videoCapture);
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//               'Failed: ${e.toString().contains('Location') ? 'Could not get location. Please enable GPS.' : 'Upload failed. Please try again.'}',
//             ),
//           ),
//         );
//       }
//     } finally {
//       if (mounted) setState(() => _uploading = false);
//     }
//   }

//   // ─────────────────────────────────────────────────────────────────────────
//   // DO / DON'T GUIDE  — single combined image
//   // Put your image at:  assets/images/photo_do_dont.png
//   // ─────────────────────────────────────────────────────────────────────────

//   Widget _buildDoDontGuide() {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: const Color(0xFF92B7F7), width: 1.5),
//         boxShadow: const [
//           BoxShadow(
//             color: Color(0x1A000000),
//             blurRadius: 8,
//             offset: Offset(0, 2),
//           ),
//         ],
//       ),
//       padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
//       child: Column(
//         children: [
//           // ── Combined DO / DON'T image ──────────────────────────
//           ClipRRect(
//             borderRadius: BorderRadius.circular(10),
//             child: Image.asset(
//               'assets/images/capture_image.jpeg',
//               width: double.infinity,
//               fit: BoxFit.contain,
//               errorBuilder: (_, __, ___) => Container(
//                 height: 180,
//                 decoration: BoxDecoration(
//                   color: Colors.grey.shade100,
//                   borderRadius: BorderRadius.circular(10),
//                   border: Border.all(color: Colors.grey.shade300),
//                 ),
//                 child: const Center(
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Icon(Icons.image_not_supported,
//                           size: 40, color: Colors.grey),
//                       SizedBox(height: 8),
//                       Text(
//                         'Add your image to:\nassets/images/photo_do_dont.png',
//                         textAlign: TextAlign.center,
//                         style: TextStyle(color: Colors.grey, fontSize: 12),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),

//           const SizedBox(height: 14),

//           // ── Click Photo button inside the card ─────────────────
//           SizedBox(
//             width: double.infinity,
//             child: ElevatedButton(
//               onPressed:
//                   _locationGranted ? _capturePhoto : _checkLocationPermission,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF92B7F7),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(30),
//                 ),
//                 padding: const EdgeInsets.symmetric(vertical: 14),
//                 elevation: 2,
//               ),
//               child: const Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     'Click Photo',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w700,
//                       color: Colors.black,
//                     ),
//                   ),
//                   SizedBox(height: 2),
//                   Text(
//                     'फोटो काढा',
//                     style: TextStyle(
//                       fontSize: 13,
//                       fontWeight: FontWeight.w500,
//                       color: Colors.black87,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ─────────────────────────────────────────────────────────────────────────
//   // CAPTURED PHOTO PREVIEW
//   // ─────────────────────────────────────────────────────────────────────────

//   Widget _buildPhotoPreview() {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: const Color(0xFF92B7F7), width: 1.5),
//         boxShadow: const [
//           BoxShadow(
//             color: Color(0x1A000000),
//             blurRadius: 8,
//             offset: Offset(0, 2),
//           ),
//         ],
//       ),
//       padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
//       child: Column(
//         children: [
//           // ── Preview image ──────────────────────────────────────
//           ClipRRect(
//             borderRadius: BorderRadius.circular(10),
//             child: Image.file(
//               _photo!,
//               width: double.infinity,
//               height: 280,
//               fit: BoxFit.cover,
//             ),
//           ),

//           const SizedBox(height: 14),

//           // ── Retake button ──────────────────────────────────────
//           SizedBox(
//             width: double.infinity,
//             child: OutlinedButton.icon(
//               onPressed: _capturePhoto,
//               icon: const Icon(Icons.camera_alt,
//                   color: Color(0xFF92B7F7), size: 20),
//               label: const Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     'Retake Photo',
//                     style: TextStyle(
//                       fontSize: 15,
//                       fontWeight: FontWeight.w700,
//                       color: Color(0xFF92B7F7),
//                     ),
//                   ),
//                   Text(
//                     'पुन्हा फोटो काढा',
//                     style: TextStyle(
//                       fontSize: 12,
//                       fontWeight: FontWeight.w500,
//                       color: Color(0xFF92B7F7),
//                     ),
//                   ),
//                 ],
//               ),
//               style: OutlinedButton.styleFrom(
//                 side: const BorderSide(color: Color(0xFF92B7F7), width: 1.5),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(30),
//                 ),
//                 padding: const EdgeInsets.symmetric(vertical: 12),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ─────────────────────────────────────────────────────────────────────────
//   // BUILD
//   // ─────────────────────────────────────────────────────────────────────────

//   @override
//   Widget build(BuildContext context) {
//     final provider = context.watch<KycProvider>();
//     final isNew = !provider.isKycCompleted && !provider.isReturningPensioner;
//     final stepNum = isNew ? 'Step-4' : 'Step-3';

//     return Scaffold(
//       appBar: KycHeader(title: 'Upload Photo [$stepNum]'),
//       backgroundColor: AppTheme.pageBg,
//       body: Center(
//         child: ConstrainedBox(
//           constraints: const BoxConstraints(maxWidth: AppTheme.maxBodyWidth),
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.fromLTRB(16, 20, 16, 80),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 // ── Page title ───────────────────────────────────────────
//                 const Text(
//                   'Click Pensioner Photo',
//                   style: TextStyle(
//                     fontSize: 22,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black87,
//                     letterSpacing: 0.5,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 4),
//                 const Text(
//                   'पेन्शनर व्यक्तीचा फोटो काढा',
//                   style: TextStyle(
//                     fontSize: 15,
//                     color: Colors.black54,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 16),

//                 // ── Location warning banner ──────────────────────────────
//                 if (!_locationGranted) ...[
//                   Container(
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       color: const Color(0xFFFFF3CD),
//                       borderRadius: BorderRadius.circular(12),
//                       border: Border.all(color: const Color(0xFFFFE69C)),
//                     ),
//                     child: Row(
//                       children: [
//                         const Icon(
//                           Icons.location_off,
//                           color: AppTheme.pendingOrange,
//                           size: 22,
//                         ),
//                         const SizedBox(width: 10),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               const Text(
//                                 'Location permission is required',
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.w700,
//                                   fontSize: 14,
//                                 ),
//                               ),
//                               const SizedBox(height: 2),
//                               const Text(
//                                 'स्थान परवानगी आवश्यक आहे',
//                                 style: TextStyle(
//                                   fontSize: 12,
//                                   color: AppTheme.textSecondary,
//                                 ),
//                               ),
//                               const SizedBox(height: 8),
//                               GestureDetector(
//                                 onTap: _checkLocationPermission,
//                                 child: const Text(
//                                   'Tap to enable / सक्षम करण्यासाठी टॅप करा',
//                                   style: TextStyle(
//                                     color: AppTheme.primaryBlue,
//                                     fontWeight: FontWeight.w600,
//                                     fontSize: 13,
//                                     decoration: TextDecoration.underline,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                 ],

//                 // ── Show DO/DON'T guide OR captured photo preview ────────
//                 // Before capture → show guide with Click Photo button inside
//                 // After capture  → show photo preview with Retake button
//                 _photo == null ? _buildDoDontGuide() : _buildPhotoPreview(),

//                 const SizedBox(height: 28),

//                 // ── Submit button ────────────────────────────────────────
//                 GreenButton(
//                   onPressed: (_photo != null && !_uploading && _locationGranted)
//                       ? _showSubmitConfirmationDialog
//                       : null,
//                   isLoading: _uploading,
//                   child: const Column(
//                     children: [
//                       Text(
//                         'Submit Photo',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w700,
//                         ),
//                       ),
//                       SizedBox(height: 2),
//                       Text(
//                         'फोटो सबमिट करा',
//                         style: TextStyle(
//                           fontSize: 12,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
