class SubmitResponse {
  final String message;
  final int certificateId;
  final String? photoUrl;
  final String? videoUrl;

  SubmitResponse({
    required this.message,
    this.certificateId = 0,
    this.photoUrl,
    this.videoUrl,
  });

  factory SubmitResponse.fromJson(Map<String, dynamic> json) {
    return SubmitResponse(
      message: json['message'] ?? '',
      certificateId: json['certificateId'] ?? 0,
      photoUrl: json['photoUrl'],
      videoUrl: json['videoUrl'],
    );
  }
}

class UploadResponse {
  final String? url;
  final String? message;

  UploadResponse({this.url, this.message});

  factory UploadResponse.fromJson(Map<String, dynamic> json) {
    return UploadResponse(
      url: json['url'],
      message: json['message'],
    );
  }
}
