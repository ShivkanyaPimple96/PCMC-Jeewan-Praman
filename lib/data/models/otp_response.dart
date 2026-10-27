class VerifyOtpResponse {
  final String message;
  final int pensionerId;
  final bool isKycCompleted;
  final String? ppoNo;
  final String? name;
  final String? mobileNumber;
  final String? aadhaarNumber;
  final String? address;
  final String? gender;
  final String? pensionType;
  final bool isNomineeKyc;
  final String? nomineeName;
  final String? verificationStatus;
  final int? certificateId;
  final String? aadhaarFullName;
  final String? aadhaarDob;
  final String? aadhaarFullAddress;
  final String? aadhaarGender;
  final String? aadhaarPhotoUrl;

  VerifyOtpResponse({
    required this.message,
    this.pensionerId = 0,
    this.isKycCompleted = false,
    this.ppoNo,
    this.name,
    this.mobileNumber,
    this.aadhaarNumber,
    this.address,
    this.gender,
    this.pensionType,
    this.isNomineeKyc = false,
    this.nomineeName,
    this.verificationStatus,
    this.certificateId,
    this.aadhaarFullName,
    this.aadhaarDob,
    this.aadhaarFullAddress,
    this.aadhaarGender,
    this.aadhaarPhotoUrl,
  });

  factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) {
    return VerifyOtpResponse(
      message: json['message'] ?? '',
      pensionerId: json['pensionerId'] ?? 0,
      isKycCompleted: json['isKycCompleted'] ?? false,
      ppoNo: json['ppoNo'],
      name: json['name'],
      mobileNumber: json['mobileNumber'],
      aadhaarNumber: json['aadhaarNumber'],
      address: json['address'],
      gender: json['gender'],
      pensionType: json['pensionType'],
      isNomineeKyc: json['isNomineeKyc'] ?? false,
      nomineeName: json['nomineeName'],
      verificationStatus: json['verificationStatus'],
      certificateId: json['certificateId'],
      aadhaarFullName: json['aadhaarFullName'],
      aadhaarDob: json['aadhaarDob'],
      aadhaarFullAddress: json['aadhaarFullAddress'],
      aadhaarGender: json['aadhaarGender'],
      aadhaarPhotoUrl: json['aadhaarPhotoUrl'],
    );
  }
}

class AadhaarVerifyResponse {
  final bool success;
  final String? message;
  final String? referenceId;
  final String? aadhaarFullName;
  final String? aadhaarDob;
  final String? aadhaarFullAddress;
  final String? aadhaarGender;
  final String? aadhaarPhotoUrl;

  AadhaarVerifyResponse({
    required this.success,
    this.message,
    this.referenceId,
    this.aadhaarFullName,
    this.aadhaarDob,
    this.aadhaarFullAddress,
    this.aadhaarGender,
    this.aadhaarPhotoUrl,
  });

  factory AadhaarVerifyResponse.fromJson(Map<String, dynamic> json) {
    return AadhaarVerifyResponse(
      success: json['success'] ?? false,
      message: json['message'],
      referenceId: json['referenceId'],
      aadhaarFullName: json['aadhaarFullName'],
      aadhaarDob: json['aadhaarDob'],
      aadhaarFullAddress: json['aadhaarFullAddress'],
      aadhaarGender: json['aadhaarGender'],
      aadhaarPhotoUrl: json['aadhaarPhotoUrl'],
    );
  }
}
