enum ExportArtifactType {
  strategySummary,
  reportPacket,
  evidenceBundle,
  auditPacket,
}

extension ExportArtifactTypeX on ExportArtifactType {
  String get label => switch (this) {
        ExportArtifactType.strategySummary => 'Strategy summary',
        ExportArtifactType.reportPacket => 'Report packet',
        ExportArtifactType.evidenceBundle => 'Evidence bundle',
        ExportArtifactType.auditPacket => 'Audit packet',
      };
}

class ExportArtifact {
  const ExportArtifact({
    required this.id,
    required this.type,
    required this.objectId,
    required this.fileName,
    required this.posture,
    required this.content,
    required this.generatedAt,
  });

  final String id;
  final ExportArtifactType type;
  final String objectId;
  final String fileName;
  final String posture;
  final String content;
  final DateTime generatedAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'objectId': objectId,
        'fileName': fileName,
        'posture': posture,
        'content': content,
        'generatedAt': generatedAt.toIso8601String(),
      };

  factory ExportArtifact.fromJson(Map<String, dynamic> json) => ExportArtifact(
        id: json['id'] as String,
        type: ExportArtifactType.values.firstWhere(
          (type) => type.name == json['type'],
        ),
        objectId: json['objectId'] as String,
        fileName: json['fileName'] as String,
        posture: json['posture'] as String,
        content: json['content'] as String,
        generatedAt: DateTime.parse(json['generatedAt'] as String),
      );
}
