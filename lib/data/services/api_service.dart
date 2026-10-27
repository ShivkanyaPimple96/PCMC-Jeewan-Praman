import 'dart:io';
import 'package:dio/dio.dart';
import '../models/check_ppo_response.dart';
import '../models/otp_response.dart';
import '../models/submit_response.dart';
import '../../config/api_config.dart';

class ApiService {
  late final Dio _dio;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
  }

  // ── Settings ──────────────────────────────────────────

  Future<String> getFinancialYear() async {
    final resp = await _dio.get(ApiConfig.financialYear);
    return resp.data['financialYear'] ?? '2025-2026';
  }

  Future<String> getApiBaseUrl() async {
    final resp = await _dio.get(ApiConfig.apiBaseUrl);
    return resp.data['apiBaseUrl'] ?? ApiConfig.baseUrl;
  }

  // ── KYC Flow ──────────────────────────────────────────

  Future<CheckPpoResponse> checkPpo(String ppoNo) async {
    final resp = await _dio.post(
      ApiConfig.checkPpo,
      data: {'ppoNo': ppoNo},
    );
    return CheckPpoResponse.fromJson(resp.data);
  }

  Future<void> sendOtp(String ppoNo, String? mobileNumber) async {
    await _dio.post(
      ApiConfig.sendOtp,
      data: {'ppoNo': ppoNo, 'mobileNumber': mobileNumber},
    );
  }

  Future<VerifyOtpResponse> verifyOtp(String ppoNo, String otp) async {
    final resp = await _dio.post(
      ApiConfig.verifyOtp,
      data: {'ppoNo': ppoNo, 'otp': otp},
    );
    return VerifyOtpResponse.fromJson(resp.data);
  }

  Future<void> updateMobile(String ppoNo, String mobileNumber) async {
    await _dio.put(
      ApiConfig.updateMobile,
      data: {'ppoNo': ppoNo, 'mobileNumber': mobileNumber},
    );
  }

  Future<void> savePensionerDetails({
    required String ppoNo,
    String? aadhaarNumber,
    String? address,
    String? gender,
    String? mobileNumber,
    String? aadhaarFullName,
    String? aadhaarDob,
    String? aadhaarFullAddress,
    String? aadhaarGender,
    String? aadhaarPhotoUrl,
  }) async {
    await _dio.post(
      ApiConfig.savePensionerDetails,
      data: {
        'ppoNo': ppoNo,
        'aadhaarNumber': aadhaarNumber,
        'address': address,
        'gender': gender,
        'mobileNumber': mobileNumber,
        'aadhaarFullName': aadhaarFullName,
        'aadhaarDob': aadhaarDob,
        'aadhaarFullAddress': aadhaarFullAddress,
        'aadhaarGender': aadhaarGender,
        'aadhaarPhotoUrl': aadhaarPhotoUrl,
      },
    );
  }

  // ── Aadhaar Verification ──────────────────────────────

  Future<Map<String, dynamic>> generateAadhaarOtp(
      String ppoNo, String aadhaarNumber) async {
    final resp = await _dio.post(
      ApiConfig.generateAadhaarOtp,
      data: {'ppoNo': ppoNo, 'aadhaarNumber': aadhaarNumber},
    );
    return resp.data;
  }

  Future<AadhaarVerifyResponse> verifyAadhaarOtp({
    required String ppoNo,
    required String aadhaarNumber,
    required String otp,
    required String referenceId,
  }) async {
    final resp = await _dio.post(
      ApiConfig.verifyAadhaarOtp,
      data: {
        'ppoNo': ppoNo,
        'aadhaarNumber': aadhaarNumber,
        'otp': otp,
        'referenceId': referenceId,
      },
    );
    return AadhaarVerifyResponse.fromJson(resp.data);
  }

  // ── File Upload ───────────────────────────────────────

  Future<UploadResponse> uploadFile({
    required File file,
    required String endpoint,
    required String ppoNo,
    required int year,
  }) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path,
          filename: file.path.split('/').last),
      'ppoNo': ppoNo,
      'year': year,
    });

    final resp = await _dio.post(
      '/api/Upload/$endpoint',
      data: formData,
      options: Options(
        headers: {'Content-Type': 'multipart/form-data'},
        receiveTimeout: const Duration(seconds: 120),
      ),
    );
    return UploadResponse.fromJson(resp.data);
  }

  Future<UploadResponse> uploadBytes({
    required List<int> bytes,
    required String fileName,
    required String endpoint,
    required String ppoNo,
    required int year,
  }) async {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(bytes, filename: fileName),
      'ppoNo': ppoNo,
      'year': year,
    });

    final resp = await _dio.post(
      '/api/Upload/$endpoint',
      data: formData,
      options: Options(
        headers: {'Content-Type': 'multipart/form-data'},
        receiveTimeout: const Duration(seconds: 120),
      ),
    );
    return UploadResponse.fromJson(resp.data);
  }

  // ── Submit Certificate ────────────────────────────────

  Future<SubmitResponse> submitFull({
    required int pensionerId,
    required String certificateYear,
    String? photoUrl,
    String? videoUrl,
    String? aadhaarFrontImageUrl,
    String? aadhaarBackImageUrl,
    String? aadhaarNumber,
    String? address,
    String? gender,
    String? aadhaarFullName,
    String? aadhaarDob,
    String? aadhaarFullAddress,
    String? aadhaarGender,
    String? aadhaarPhotoUrl,
    double? latitude,
    double? longitude,
    Map<String, dynamic>? declaration,
  }) async {
    final resp = await _dio.post(
      ApiConfig.submitFull,
      data: {
        'pensionerId': pensionerId,
        'certificateYear': certificateYear,
        'photoUrl': photoUrl,
        'videoUrl': videoUrl,
        'aadhaarFrontImageUrl': aadhaarFrontImageUrl,
        'aadhaarBackImageUrl': aadhaarBackImageUrl,
        'aadhaarNumber': aadhaarNumber,
        'address': address,
        'gender': gender,
        'aadhaarFullName': aadhaarFullName,
        'aadhaarDob': aadhaarDob,
        'aadhaarFullAddress': aadhaarFullAddress,
        'aadhaarGender': aadhaarGender,
        'aadhaarPhotoUrl': aadhaarPhotoUrl,
        'latitude': latitude,
        'longitude': longitude,
        'declaration': declaration,
      },
    );
    return SubmitResponse.fromJson(resp.data);
  }
}
