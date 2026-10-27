import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';

import '../config/app_theme.dart';
import '../config/routes.dart';
import '../providers/kyc_provider.dart';
import '../widgets/green_button.dart';
import '../widgets/kyc_header.dart';

class VideoCaptureScreen extends StatefulWidget {
  const VideoCaptureScreen({super.key});

  @override
  State<VideoCaptureScreen> createState() => _VideoCaptureScreenState();
}

class _VideoCaptureScreenState extends State<VideoCaptureScreen> {
  // ── Camera ────────────────────────────────────────────────────────────────
  List<CameraDescription> _cameras = [];
  CameraController? _cameraController;
  bool _cameraReady = false;
  bool _showPreview = false;
  bool _isFrontCamera = true; // ── track active lens

  // ── Recording ─────────────────────────────────────────────────────────────
  bool _isRecording = false;
  bool _isBlinking = false;
  Timer? _blinkTimer;
  Timer? _countdownTimer;
  int _elapsedTime = 0;
  static const int _recordingDuration = 6;

  // ── Post-record ───────────────────────────────────────────────────────────
  File? _video;
  bool _compressing = false;
  bool _uploading = false;
  VideoPlayerController? _playerController;

  // ─────────────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _initCameras();
  }

  Future<void> _initCameras() async {
    _cameras = await availableCameras();
  }

  // ── Open camera with given lens direction ─────────────────────────────────
  Future<void> _openCamera({bool front = true}) async {
    if (_cameras.isEmpty) return;

    // Dispose any existing controller first
    if (_cameraController != null) {
      await _cameraController!.dispose();
      _cameraController = null;
    }

    final direction =
        front ? CameraLensDirection.front : CameraLensDirection.back;

    final desc = _cameras.firstWhere(
      (c) => c.lensDirection == direction,
      orElse: () => _cameras.first,
    );

    _cameraController = CameraController(
      desc,
      ResolutionPreset.low,
      enableAudio: false,
    );

    await _cameraController!.initialize();

    if (mounted) {
      setState(() {
        _isFrontCamera = front;
        _cameraReady = true;
        _showPreview = true;
      });
    }
  }

  // ── Switch between front / back while NOT recording ───────────────────────
  Future<void> _switchCamera() async {
    if (_isRecording) return; // safety guard
    setState(() => _cameraReady = false);
    await _openCamera(front: !_isFrontCamera);
  }

  // ── Close / cancel camera ─────────────────────────────────────────────────
  Future<void> _closeCamera() async {
    _stopBlinking();
    _stopCountdown();
    await _cameraController?.dispose();
    _cameraController = null;
    if (mounted) {
      setState(() {
        _cameraReady = false;
        _showPreview = false;
        _isRecording = false;
        _elapsedTime = 0;
      });
    }
  }

  // ── Start recording ───────────────────────────────────────────────────────
  Future<void> _startRecording() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized)
      return;
    try {
      await _cameraController!.startVideoRecording();
      setState(() {
        _isRecording = true;
        _elapsedTime = 0;
      });
      _startBlinking();
      _startCountdown();

      await Future.delayed(const Duration(seconds: _recordingDuration));
      if (_isRecording) await _stopRecording();
    } catch (e) {
      debugPrint('Start recording error: $e');
    }
  }

  // ── Stop recording ────────────────────────────────────────────────────────
  Future<void> _stopRecording() async {
    if (_cameraController == null || !_cameraController!.value.isRecordingVideo)
      return;

    _stopBlinking();
    _stopCountdown();

    try {
      final XFile file = await _cameraController!.stopVideoRecording();

      setState(() {
        _isRecording = false;
        _showPreview = false;
        _cameraReady = false;
        _compressing = true;
      });

      await _cameraController!.dispose();
      _cameraController = null;

      final compressed = await _compressVideo(File(file.path));

      setState(() {
        _video = compressed;
        _compressing = false;
      });

      await _initPlayer(compressed);
    } catch (e) {
      debugPrint('Stop recording error: $e');
      if (mounted) setState(() => _isRecording = false);
    }
  }

  // ── Blink helpers ─────────────────────────────────────────────────────────
  void _startBlinking() {
    _blinkTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (mounted) setState(() => _isBlinking = !_isBlinking);
    });
  }

  void _stopBlinking() {
    _blinkTimer?.cancel();
    if (mounted) setState(() => _isBlinking = false);
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() => _elapsedTime++);
      if (_elapsedTime >= _recordingDuration) timer.cancel();
    });
  }

  void _stopCountdown() {
    _countdownTimer?.cancel();
  }

  // ── Video helpers ─────────────────────────────────────────────────────────
  Future<File> _compressVideo(File file) async {
    try {
      final info = await VideoCompress.compressVideo(
        file.path,
        quality: VideoQuality.MediumQuality,
        deleteOrigin: false,
        includeAudio: false,
      );
      if (info?.file != null) return info!.file!;
    } catch (_) {}
    return file;
  }

  Future<void> _initPlayer(File file) async {
    _playerController = VideoPlayerController.file(file);
    await _playerController!.initialize();
    _playerController!.setLooping(true);
    if (mounted) setState(() {});
  }

  Future<void> _disposePlayer() async {
    await _playerController?.dispose();
    _playerController = null;
  }

  void _togglePlay() {
    if (_playerController == null) return;
    _playerController!.value.isPlaying
        ? _playerController!.pause()
        : _playerController!.play();
    setState(() {});
  }

  Future<void> _reRecord() async {
    await _disposePlayer();
    setState(() => _video = null);
    await _openCamera(front: _isFrontCamera);
  }

  // ── Confirmation dialog (unchanged) ──────────────────────────────────────
  void _showConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        bool dialogLoading = false;
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              contentPadding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.video_call_rounded,
                        color: AppTheme.primaryBlue, size: 26),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Submit Video',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.black87)),
                      Text('व्हिडिओ सबमिट करा',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.black45)),
                    ],
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Divider(thickness: 1.5),
                  SizedBox(height: 10),
                  Text(
                    'Are you sure you want to submit this video?',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 6),
                  Text(
                    'तुम्हाला खात्री आहे की तुम्ही हा व्हिडिओ सबमिट करू इच्छिता?',
                    style: TextStyle(fontSize: 13, color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  Divider(thickness: 1.5),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: dialogLoading
                      ? null
                      : () => Navigator.of(dialogContext).pop(),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Cancel',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w700)),
                      Text('रद्द करा',
                          style: TextStyle(fontSize: 11, color: Colors.red)),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: dialogLoading
                      ? null
                      : () async {
                          setDialogState(() => dialogLoading = true);
                          Navigator.of(dialogContext).pop();
                          await _uploadAndContinue();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: dialogLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Submit',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w700)),
                            Text('सबमिट करा', style: TextStyle(fontSize: 11)),
                          ],
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ── Upload ────────────────────────────────────────────────────────────────
  Future<void> _uploadAndContinue() async {
    if (_video == null) return;
    setState(() => _uploading = true);
    final provider = context.read<KycProvider>();
    try {
      await _playerController?.pause();
      final resp = await provider.api.uploadFile(
        file: _video!,
        endpoint: 'video',
        ppoNo: provider.ppoNo,
        year: provider.uploadYear,
      );
      if (resp.url != null) provider.videoUrl = resp.url;
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.declaration);
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
  void dispose() {
    _blinkTimer?.cancel();
    _countdownTimer?.cancel();
    _cameraController?.dispose();
    _playerController?.dispose();
    VideoCompress.cancelCompression();
    super.dispose();
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  BUILD
  // ══════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<KycProvider>();
    final isNew = !provider.isKycCompleted && !provider.isReturningPensioner;
    final stepNum = isNew ? 'Step-5' : 'Step-4';

    return Scaffold(
      appBar: KycHeader(title: 'Record Video [$stepNum]'),
      backgroundColor: AppTheme.pageBg,
      body: _showPreview ? _buildCameraPage() : _buildMainPage(),
    );
  }

  // ── PAGE 1 : Camera preview ───────────────────────────────────────────────
  Widget _buildCameraPage() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // ── Camera preview ──────────────────────────────────────────────────
        if (_cameraReady && _cameraController != null)
          CameraPreview(_cameraController!)
        else
          const Center(child: CircularProgressIndicator()),

        // ── Top bar: active camera label + switch button ─────────────────────
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.65),
                  Colors.transparent,
                ],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Active camera label
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isFrontCamera
                            ? Icons.face_retouching_natural
                            : Icons.camera_rear,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _isFrontCamera ? 'Front Camera' : 'Back Camera',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                // Switch camera button — disabled while recording
                GestureDetector(
                  onTap: _isRecording ? null : _switchCamera,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _isRecording
                          ? Colors.white.withValues(alpha: 0.15)
                          : Colors.white.withValues(alpha: 0.25),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _isRecording ? Colors.white30 : Colors.white60,
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      Icons.flip_camera_ios_rounded,
                      color: _isRecording ? Colors.white38 : Colors.white,
                      size: 26,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Idle instructions ───────────────────────────────────────────────
        if (!_isRecording && _cameraReady)
          Positioned(
            top: 90,
            left: 24,
            right: 24,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.50),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Make sure your face is clearly visible\nLook left or right side\nPlease look front of the camera',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
            ),
          ),

        // ── REC dot + elapsed (top-right, shown while recording) ────────────
        if (_isRecording)
          Positioned(
            top: 70,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Icon(
                  Icons.radio_button_checked,
                  color: _isBlinking ? Colors.red : Colors.transparent,
                  size: 36,
                ),
                const SizedBox(height: 4),
                Text(
                  'REC  $_elapsedTime s',
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                          blurRadius: 4,
                          color: Colors.black,
                          offset: Offset(1, 1))
                    ],
                  ),
                ),
              ],
            ),
          ),

        // ── Centre countdown circle ─────────────────────────────────────────
        if (_isRecording)
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedOpacity(
                  opacity: _isBlinking ? 1.0 : 0.35,
                  duration: const Duration(milliseconds: 400),
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withValues(alpha: 0.45),
                      border: Border.all(
                        color: _isBlinking ? Colors.red : Colors.white54,
                        width: 3,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '${_recordingDuration - _elapsedTime}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'रेकॉर्डिंग सुरू आहे...',
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: 200,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: _elapsedTime / _recordingDuration,
                      minHeight: 8,
                      backgroundColor: Colors.white24,
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // ── Bottom action bar ───────────────────────────────────────────────
        Positioned(
          bottom: 36,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!_isRecording) ...[
                // Cancel
                ElevatedButton.icon(
                  onPressed: _closeCamera,
                  icon: const Icon(Icons.close, size: 20),
                  label: const Text('Cancel',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black54,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                ),
                const SizedBox(width: 16),
                // Start recording
                ElevatedButton.icon(
                  onPressed: _cameraReady ? _startRecording : null,
                  icon: const Icon(Icons.videocam, size: 22),
                  label: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Start Recording',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w700)),
                      Text('व्हिडिओ रेकॉर्ड करा',
                          style: TextStyle(fontSize: 11)),
                    ],
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                ),
              ] else
                // Recording in progress pill
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.60),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    '$_elapsedTime / $_recordingDuration sec',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // ── PAGE 2 : Main screen ──────────────────────────────────────────────────
  Widget _buildMainPage() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppTheme.maxBodyWidth),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Capture Pensioner Video',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                  letterSpacing: 0.3,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              const Text(
                'पेन्शनर व्यक्तीचा व्हिडिओ काढा',
                style: TextStyle(fontSize: 15, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Video area
              GestureDetector(
                onTap: (_compressing || _uploading)
                    ? null
                    : (_video != null && _playerController != null)
                        ? _togglePlay
                        : () => _openCamera(front: _isFrontCamera),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                    border: Border.all(color: AppTheme.cardBorder, width: 1.5),
                  ),
                  child: _compressing
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 40,
                                height: 40,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  color: AppTheme.primaryBlue,
                                ),
                              ),
                              SizedBox(height: 12),
                              Text('Uploading Video...',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.primaryBlue)),
                              SizedBox(height: 4),
                              Text('व्हिडिओ अपलोड होत आहे...',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.textSecondary)),
                            ],
                          ),
                        )
                      : (_video != null &&
                              _playerController != null &&
                              _playerController!.value.isInitialized)
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(
                                  AppTheme.cardRadius - 1),
                              child: SizedBox(
                                height: 350,
                                width: double.infinity,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    SizedBox.expand(
                                      child: FittedBox(
                                        fit: BoxFit.cover,
                                        child: SizedBox(
                                          width: _playerController!
                                              .value.size.width,
                                          height: _playerController!
                                              .value.size.height,
                                          child:
                                              VideoPlayer(_playerController!),
                                        ),
                                      ),
                                    ),
                                    if (!_playerController!.value.isPlaying)
                                      Container(
                                        width: 56,
                                        height: 56,
                                        decoration: BoxDecoration(
                                          color: Colors.black
                                              .withValues(alpha: 0.5),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.play_arrow,
                                            size: 36, color: Colors.white),
                                      ),
                                    Positioned(
                                      bottom: 8,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.black
                                              .withValues(alpha: 0.5),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          _playerController!.value.isPlaying
                                              ? 'Tap to pause'
                                              : 'Tap to preview / पूर्वावलोकन',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : _video != null
                              ? Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 40),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 60,
                                        height: 60,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFD4EDDA),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.videocam,
                                            size: 30, color: AppTheme.green),
                                      ),
                                      const SizedBox(height: 12),
                                      const Text('Video Recorded',
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                              color: AppTheme.green)),
                                    ],
                                  ),
                                )
                              : Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 40),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 60,
                                        height: 60,
                                        decoration: const BoxDecoration(
                                          color: AppTheme.cardBorder,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.videocam,
                                            size: 28,
                                            color: AppTheme.primaryBlue),
                                      ),
                                      const SizedBox(height: 12),
                                      const Text(
                                          'पेन्शनर व्यक्तीचा व्हिडिओ काढा',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 14,
                                              color: AppTheme.primaryBlue)),
                                      const SizedBox(height: 4),
                                      const Text(
                                          'Capture Pensioner Video (6 sec)',
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: AppTheme.textHint)),
                                    ],
                                  ),
                                ),
                ),
              ),

              const SizedBox(height: 16),

              if (_video == null && !_compressing)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _openCamera(front: _isFrontCamera),
                    icon: const Icon(Icons.videocam, size: 20),
                    label: const Column(
                      children: [
                        Text('Start Recording',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w700)),
                        SizedBox(height: 2),
                        Text('व्हिडिओ रेकॉर्ड करा',
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w500)),
                      ],
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                  ),
                )
              else if (_video != null && !_compressing) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _uploading ? null : _reRecord,
                    icon: const Icon(Icons.refresh, size: 20),
                    label: const Column(
                      children: [
                        Text('Re-record Video',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w700)),
                        SizedBox(height: 2),
                        Text('व्हिडिओ परत रेकॉर्ड करा',
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w500)),
                      ],
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.orangeHover,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                GreenButton(
                  onPressed: _uploading ? null : _showConfirmationDialog,
                  isLoading: _uploading,
                  child: const Column(
                    children: [
                      Text('Submit Video',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700)),
                      SizedBox(height: 2),
                      Text('व्हिडिओ सबमिट करा',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
