import 'model_types.dart';

class ReportTemplate {
  const ReportTemplate({
    required this.templateId,
    required this.name,
    required this.cadence,
    required this.includedPlatforms,
    required this.includedSections,
    required this.outputFormats,
  });

  final String templateId;
  final String name;
  final ReportCadence cadence;
  final List<SocialPlatform> includedPlatforms;
  final List<String> includedSections;
  final List<ReportOutputFormat> outputFormats;

  ReportTemplate copyWith({
    String? templateId,
    String? name,
    ReportCadence? cadence,
    List<SocialPlatform>? includedPlatforms,
    List<String>? includedSections,
    List<ReportOutputFormat>? outputFormats,
  }) {
    return ReportTemplate(
      templateId: templateId ?? this.templateId,
      name: name ?? this.name,
      cadence: cadence ?? this.cadence,
      includedPlatforms: includedPlatforms ?? this.includedPlatforms,
      includedSections: includedSections ?? this.includedSections,
      outputFormats: outputFormats ?? this.outputFormats,
    );
  }

  Map<String, dynamic> toJson() => {
    'templateId': templateId,
    'name': name,
    'cadence': cadence.name,
    'includedPlatforms': includedPlatforms
        .map((platform) => platform.name)
        .toList(),
    'includedSections': includedSections,
    'outputFormats': outputFormats.map((format) => format.name).toList(),
  };

  factory ReportTemplate.fromJson(Map<String, dynamic> json) => ReportTemplate(
    templateId: json['templateId'] as String,
    name: json['name'] as String,
    cadence: ReportCadenceX.fromName(json['cadence'] as String),
    includedPlatforms: (json['includedPlatforms'] as List<dynamic>)
        .cast<String>()
        .map(SocialPlatformX.fromName)
        .toList(),
    includedSections: (json['includedSections'] as List<dynamic>)
        .cast<String>()
        .toList(),
    outputFormats: (json['outputFormats'] as List<dynamic>)
        .cast<String>()
        .map(ReportOutputFormatX.fromName)
        .toList(),
  );
}
