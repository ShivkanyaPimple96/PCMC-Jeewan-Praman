class ApiConfig {
  // Change this to your API base URL
  static const String baseUrl = 'https://lc.pcmcpensioner.in/';

  // static const String baseUrl = 'https://lcapi.shrisoft.co.in/';

  // Logo
  static const String logoUrl = '${baseUrl}css/logo.jpg';

  // Auth
  static const String pensionerLogin = '/api/Auth/pensioner/login';

  // Settings
  static const String financialYear = '/api/Settings/financial-year';
  static const String apiBaseUrl = '/api/Settings/api-base-url';

  // KYC
  static const String checkPpo = '/api/Kyc/check-ppo';
  static const String sendOtp = '/api/Kyc/send-otp';
  static const String verifyOtp = '/api/Kyc/verify-otp';
  static const String updateMobile = '/api/Kyc/update-mobile';
  static const String savePensionerDetails = '/api/Kyc/save-pensioner-details';
  static const String generateAadhaarOtp = '/api/Kyc/generate-aadhaar-otp';
  static const String verifyAadhaarOtp = '/api/Kyc/verify-aadhaar-otp';
  static const String submitFull = '/api/Kyc/submit-full';

  // Upload
  static const String uploadPhoto = '/api/Upload/photo';
  static const String uploadVideo = '/api/Upload/video';
  static const String uploadAadhaarFront = '/api/Upload/aadhaar-front';
  static const String uploadAadhaarBack = '/api/Upload/aadhaar-back';

  // Life Certificate
  static const String submitCertificate = '/api/LifeCertificate/submit';
  static String pensionerCertificates(int pensionerId) =>
      '/api/LifeCertificate/pensioner/$pensionerId';
}
