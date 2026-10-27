/// Mask Aadhaar number: "123456789012" → "XXXX XXXX 9012"
String maskAadhaar(String? aadhaar) {
  if (aadhaar == null || aadhaar.length < 4) return '';
  return 'XXXX XXXX ${aadhaar.substring(aadhaar.length - 4)}';
}

/// Mask mobile number: "9876543210" → "XXXXXX3210"
String maskMobile(String? mobile) {
  if (mobile == null || mobile.length < 4) return '';
  return 'XXXXXX${mobile.substring(mobile.length - 4)}';
}

/// Make a relative URL absolute by prepending base URL
String makeAbsoluteUrl(String? url, String apiBase) {
  if (url == null || url.isEmpty) return '';
  if (url.startsWith('http')) return url;
  final base = apiBase.endsWith('/') ? apiBase.substring(0, apiBase.length - 1) : apiBase;
  final path = url.startsWith('/') ? url : '/$url';
  return '$base$path';
}

/// Generate certificate number from ID
String certificateNumber(int? certId) {
  if (certId == null || certId == 0) return '';
  return 'PCMCPH-$certId';
}

/// Generate certificate URL for QR code
String certificateUrl(String? year, int? certId) {
  if (year == null || certId == null) return '';
  return 'https://lc.pcmcpensioner.in/?lc=${year}_$certId';
}
