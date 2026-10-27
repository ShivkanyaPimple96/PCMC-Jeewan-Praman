class DeclarationDto {
  final bool hasReemployed;
  final String? reemployedOrganisation;
  final String? reemployedDate;
  final bool hasRemarried;
  final String? marriageDate;
  final String? marriageLocation;

  DeclarationDto({
    this.hasReemployed = false,
    this.reemployedOrganisation,
    this.reemployedDate,
    this.hasRemarried = false,
    this.marriageDate,
    this.marriageLocation,
  });

  Map<String, dynamic> toJson() => {
        'hasReemployed': hasReemployed,
        'reemployedOrganisation': reemployedOrganisation,
        'reemployedDate': reemployedDate,
        'hasRemarried': hasRemarried,
        'marriageDate': marriageDate,
        'marriageLocation': marriageLocation,
      };

  factory DeclarationDto.fromJson(Map<String, dynamic> json) {
    return DeclarationDto(
      hasReemployed: json['hasReemployed'] ?? false,
      reemployedOrganisation: json['reemployedOrganisation'],
      reemployedDate: json['reemployedDate'],
      hasRemarried: json['hasRemarried'] ?? false,
      marriageDate: json['marriageDate'],
      marriageLocation: json['marriageLocation'],
    );
  }
}
