import 'package:flutter/material.dart';
import '../data/models/check_ppo_response.dart';
import '../data/models/declaration_dto.dart';
import '../data/services/api_service.dart';

/// Holds all session state for the KYC flow (mirrors WebApp's KycSessionData)
class KycProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  ApiService get api => _api;

  // ── Session state ─────────────────────────────────────
  String ppoNo = '';
  int pensionerId = 0;
  bool isKycCompleted = false;
  bool isReturningPensioner = false;
  bool isPensionTypeSynced = true;
  bool isNomineeKyc = false;

  String? name;
  String? mobileNumber;
  String? maskedMobile;
  String? aadhaarNumber;
  String? pensionType;
  String? address;
  String? gender;
  String? nomineeName;

  // Aadhaar eKYC
  String? aadhaarFullName;
  String? aadhaarDob;
  String? aadhaarFullAddress;
  String? aadhaarGender;
  String? aadhaarPhotoUrl;
  String? referenceId;
  bool aadhaarOtpFailed = false;

  // File URLs
  String? photoUrl;
  String? videoUrl;
  String? aadhaarFrontUrl;
  String? aadhaarBackUrl;

  // GPS
  double? latitude;
  double? longitude;

  // Certificate
  String? verificationStatus;
  int? certificateId;
  String? financialYear;
  DateTime? approvedAt;
  DeclarationDto? declaration;

  // Certificate display data (from check-ppo for approved certs)
  String? currentYearPhotoUrl;
  String? currentYearVideoUrl;

  // ── Loading / Error ───────────────────────────────────
  bool isLoading = false;
  String? error;

  void setLoading(bool val) {
    isLoading = val;
    error = null;
    notifyListeners();
  }

  void setError(String msg) {
    error = msg;
    isLoading = false;
    notifyListeners();
  }

  void clearError() {
    error = null;
    notifyListeners();
  }

  // ── Reset (like TempData.Remove in WebApp) ────────────
  void resetSession() {
    ppoNo = '';
    pensionerId = 0;
    isKycCompleted = false;
    isReturningPensioner = false;
    isPensionTypeSynced = true;
    isNomineeKyc = false;
    name = null;
    mobileNumber = null;
    maskedMobile = null;
    aadhaarNumber = null;
    pensionType = null;
    address = null;
    gender = null;
    nomineeName = null;
    aadhaarFullName = null;
    aadhaarDob = null;
    aadhaarFullAddress = null;
    aadhaarGender = null;
    aadhaarPhotoUrl = null;
    referenceId = null;
    aadhaarOtpFailed = false;
    photoUrl = null;
    videoUrl = null;
    aadhaarFrontUrl = null;
    aadhaarBackUrl = null;
    latitude = null;
    longitude = null;
    verificationStatus = null;
    certificateId = null;
    financialYear = null;
    approvedAt = null;
    declaration = null;
    currentYearPhotoUrl = null;
    currentYearVideoUrl = null;
    isLoading = false;
    error = null;
    notifyListeners();
  }

  // ── Step 0: Fetch Financial Year ──────────────────────
  Future<String> fetchFinancialYear() async {
    try {
      financialYear = await _api.getFinancialYear();
    } catch (_) {
      financialYear = '2025-2026';
    }
    notifyListeners();
    return financialYear!;
  }

  // ── Step 1: Check PPO ─────────────────────────────────
  /// Returns the CheckPpoResponse for the caller to decide navigation.
  Future<CheckPpoResponse> checkPpo(String ppo) async {
    setLoading(true);
    try {
      final result = await _api.checkPpo(ppo);

      if (!result.found) {
        setError('PPO Number not found in our records. Please contact the office.');
        return result;
      }

      // Populate session
      ppoNo = ppo;
      pensionerId = result.pensionerId;
      isKycCompleted = result.isKycCompleted;
      isReturningPensioner = result.hasSubmittedThisYear;
      isPensionTypeSynced = result.isPensionTypeSynced;
      isNomineeKyc = result.isNomineeKyc;
      name = result.name;
      mobileNumber = result.mobileNumber;
      maskedMobile = result.maskedMobile;
      pensionType = result.pensionType;
      gender = result.gender;
      aadhaarNumber = result.aadhaarNumber;
      nomineeName = result.nomineeName;

      // B-condition: pension type changed → force full KYC
      if (!result.isPensionTypeSynced) {
        isKycCompleted = false;
        isReturningPensioner = false;
      }

      isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      setError('Unable to reach server. Please try again.');
      return CheckPpoResponse(found: false);
    }
  }

  // ── Step 1a: Send OTP ─────────────────────────────────
  Future<bool> sendOtp({String? mobile}) async {
    setLoading(true);
    try {
      if (mobile != null && mobile.isNotEmpty) {
        mobileNumber = mobile.trim();
      }
      await _api.sendOtp(ppoNo, mobileNumber);
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      setError('Failed to send OTP. Please try again.');
      return false;
    }
  }

  // ── Step 1b: Verify OTP ───────────────────────────────
  Future<bool> verifyOtp(String otp) async {
    setLoading(true);
    try {
      final data = await _api.verifyOtp(ppoNo, otp);

      // Update session with returned data
      name = data.name ?? name;
      mobileNumber = data.mobileNumber;
      aadhaarNumber = data.aadhaarNumber;
      pensionType = data.pensionType;
      address = data.address;
      gender = data.gender;
      verificationStatus = data.verificationStatus;
      certificateId = data.certificateId;
      isNomineeKyc = data.isNomineeKyc;
      nomineeName = data.nomineeName;
      aadhaarFullName = data.aadhaarFullName;
      aadhaarDob = data.aadhaarDob;
      aadhaarFullAddress = data.aadhaarFullAddress;
      aadhaarGender = data.aadhaarGender;
      aadhaarPhotoUrl = data.aadhaarPhotoUrl;

      // Fetch financial year
      await fetchFinancialYear();

      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      setError('Invalid OTP. Please try again.');
      return false;
    }
  }

  // ── Step 2: Save Pensioner Details ────────────────────
  Future<bool> savePensionerDetails({
    String? newAadhaar,
    String? newAddress,
    String? newGender,
  }) async {
    setLoading(true);
    try {
      // Update session with form values (for new pensioners)
      if (newAadhaar != null) aadhaarNumber = newAadhaar;
      if (newAddress != null) address = newAddress;
      if (newGender != null) gender = newGender;

      await _api.savePensionerDetails(
        ppoNo: ppoNo,
        aadhaarNumber: aadhaarNumber,
        address: address,
        gender: gender,
        mobileNumber: mobileNumber,
        aadhaarFullName: aadhaarFullName,
        aadhaarDob: aadhaarDob,
        aadhaarFullAddress: aadhaarFullAddress,
        aadhaarGender: aadhaarGender,
        aadhaarPhotoUrl: aadhaarPhotoUrl,
      );

      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      setError('Failed to save details. Please try again.');
      return false;
    }
  }

  // ── Step 3: Aadhaar OTP ───────────────────────────────
  Future<bool> generateAadhaarOtp() async {
    setLoading(true);
    try {
      final data = await _api.generateAadhaarOtp(ppoNo, aadhaarNumber ?? '');
      referenceId = data['referenceId'];
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      setError('Failed to send Aadhaar OTP. Please try manual upload.');
      return false;
    }
  }

  Future<bool> verifyAadhaarOtp(String otp) async {
    setLoading(true);
    try {
      final result = await _api.verifyAadhaarOtp(
        ppoNo: ppoNo,
        aadhaarNumber: aadhaarNumber ?? '',
        otp: otp,
        referenceId: referenceId ?? '',
      );

      isKycCompleted = true;
      aadhaarOtpFailed = false;
      aadhaarFullName = result.aadhaarFullName;
      aadhaarDob = result.aadhaarDob;
      aadhaarFullAddress = result.aadhaarFullAddress;
      aadhaarGender = result.aadhaarGender;
      aadhaarPhotoUrl = result.aadhaarPhotoUrl;

      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      aadhaarOtpFailed = true;
      setError('OTP Verification Incorrect');
      return false;
    }
  }

  // ── Step 4/5: Upload helpers ──────────────────────────
  int get uploadYear {
    if (financialYear != null && financialYear!.contains('-')) {
      return int.tryParse(financialYear!.split('-')[0]) ?? DateTime.now().year;
    }
    return DateTime.now().year;
  }

  // ── Step 6: Submit Certificate ────────────────────────
  Future<bool> submitCertificate(DeclarationDto decl) async {
    setLoading(true);
    try {
      declaration = decl;
      final certYear = financialYear ?? '${DateTime.now().year}-${DateTime.now().year + 1}';

      final result = await _api.submitFull(
        pensionerId: pensionerId,
        certificateYear: certYear,
        photoUrl: photoUrl,
        videoUrl: videoUrl,
        aadhaarFrontImageUrl: aadhaarFrontUrl,
        aadhaarBackImageUrl: aadhaarBackUrl,
        aadhaarNumber: aadhaarNumber,
        address: address,
        gender: gender,
        aadhaarFullName: aadhaarFullName,
        aadhaarDob: aadhaarDob,
        aadhaarFullAddress: aadhaarFullAddress,
        aadhaarGender: aadhaarGender,
        aadhaarPhotoUrl: aadhaarPhotoUrl,
        latitude: latitude,
        longitude: longitude,
        declaration: decl.toJson(),
      );

      certificateId = result.certificateId > 0 ? result.certificateId : certificateId;
      verificationStatus = 'Pending';

      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      setError('Submission failed. Please try again.');
      return false;
    }
  }

  /// Whether to skip Aadhaar verification (same logic as WebApp line 259)
  bool get shouldSkipAadhaarVerification =>
      isKycCompleted && !isNomineeKyc;
}
