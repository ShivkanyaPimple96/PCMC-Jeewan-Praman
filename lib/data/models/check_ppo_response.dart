class CheckPpoResponse {
  final bool found;
  final int pensionerId;
  final bool isKycCompleted;
  final bool hasSubmittedThisYear;
  final bool hasAnyCertificates;
  final String? currentYearCertStatus;
  final int? currentYearCertId;
  final bool isPensionTypeSynced;
  final bool isNomineeKyc;
  final String? name;
  final String? mobileNumber;
  final String? maskedMobile;
  final String? pensionType;
  final String? gender;
  final String? aadhaarNumber;
  final String? nomineeName;
  final String? currentYearPhotoUrl;
  final String? currentYearVideoUrl;
  final bool? hasReemployed;
  final String? reemployedOrganisation;
  final String? reemployedDate;
  final bool? hasRemarried;
  final String? marriageDate;
  final String? marriageLocation;
  final String? approvedAt;

  CheckPpoResponse({
    required this.found,
    this.pensionerId = 0,
    this.isKycCompleted = false,
    this.hasSubmittedThisYear = false,
    this.hasAnyCertificates = false,
    this.currentYearCertStatus,
    this.currentYearCertId,
    this.isPensionTypeSynced = true,
    this.isNomineeKyc = false,
    this.name,
    this.mobileNumber,
    this.maskedMobile,
    this.pensionType,
    this.gender,
    this.aadhaarNumber,
    this.nomineeName,
    this.currentYearPhotoUrl,
    this.currentYearVideoUrl,
    this.hasReemployed,
    this.reemployedOrganisation,
    this.reemployedDate,
    this.hasRemarried,
    this.marriageDate,
    this.marriageLocation,
    this.approvedAt,
  });

  factory CheckPpoResponse.fromJson(Map<String, dynamic> json) {
    return CheckPpoResponse(
      found: json['found'] ?? false,
      pensionerId: json['pensionerId'] ?? 0,
      isKycCompleted: json['isKycCompleted'] ?? false,
      hasSubmittedThisYear: json['hasSubmittedThisYear'] ?? false,
      hasAnyCertificates: json['hasAnyCertificates'] ?? false,
      currentYearCertStatus: json['currentYearCertStatus'],
      currentYearCertId: json['currentYearCertId'],
      isPensionTypeSynced: json['isPensionTypeSynced'] ?? true,
      isNomineeKyc: json['isNomineeKyc'] ?? false,
      name: json['name'],
      mobileNumber: json['mobileNumber'],
      maskedMobile: json['maskedMobile'],
      pensionType: json['pensionType'],
      gender: json['gender'],
      aadhaarNumber: json['aadhaarNumber'],
      nomineeName: json['nomineeName'],
      currentYearPhotoUrl: json['currentYearPhotoUrl'],
      currentYearVideoUrl: json['currentYearVideoUrl'],
      hasReemployed: json['hasReemployed'],
      reemployedOrganisation: json['reemployedOrganisation'],
      reemployedDate: json['reemployedDate'],
      hasRemarried: json['hasRemarried'],
      marriageDate: json['marriageDate'],
      marriageLocation: json['marriageLocation'],
      approvedAt: json['approvedAt'],
    );
  }
}
