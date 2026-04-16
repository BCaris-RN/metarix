import '../../shared/domain/core_models.dart';

enum SocialGoalType {
  awareness,
  engagement,
  conversions,
  consumerSentiment,
}

extension SocialGoalTypeX on SocialGoalType {
  String get label => switch (this) {
        SocialGoalType.awareness => 'Awareness',
        SocialGoalType.engagement => 'Engagement',
        SocialGoalType.conversions => 'Conversions',
        SocialGoalType.consumerSentiment => 'Consumer sentiment',
      };

  static SocialGoalType fromName(String value) =>
      SocialGoalType.values.firstWhere((goalType) => goalType.name == value);
}

enum SwotCategory {
  strength,
  weakness,
  opportunity,
  threat,
}

extension SwotCategoryX on SwotCategory {
  String get label => switch (this) {
        SwotCategory.strength => 'Strength',
        SwotCategory.weakness => 'Weakness',
        SwotCategory.opportunity => 'Opportunity',
        SwotCategory.threat => 'Threat',
      };

  static SwotCategory fromName(String value) =>
      SwotCategory.values.firstWhere((category) => category.name == value);
}

class MetricTarget {
  const MetricTarget({
    required this.metricName,
    required this.targetValue,
    required this.unit,
  });

  final String metricName;
  final double targetValue;
  final String unit;

  Map<String, dynamic> toJson() => {
        'metricName': metricName,
        'targetValue': targetValue,
        'unit': unit,
      };

  factory MetricTarget.fromJson(Map<String, dynamic> json) => MetricTarget(
        metricName: json['metricName'] as String,
        targetValue: (json['targetValue'] as num).toDouble(),
        unit: json['unit'] as String,
      );
}

class BusinessGoal {
  const BusinessGoal({
    required this.id,
    required this.brandId,
    required this.title,
    required this.summary,
    required this.socialGoalIds,
  });

  final String id;
  final String brandId;
  final String title;
  final String summary;
  final List<String> socialGoalIds;

  BusinessGoal copyWith({
    String? id,
    String? brandId,
    String? title,
    String? summary,
    List<String>? socialGoalIds,
  }) {
    return BusinessGoal(
      id: id ?? this.id,
      brandId: brandId ?? this.brandId,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      socialGoalIds: socialGoalIds ?? this.socialGoalIds,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'brandId': brandId,
        'title': title,
        'summary': summary,
        'socialGoalIds': socialGoalIds,
      };

  factory BusinessGoal.fromJson(Map<String, dynamic> json) => BusinessGoal(
        id: json['id'] as String,
        brandId: json['brandId'] as String,
        title: json['title'] as String,
        summary: json['summary'] as String,
        socialGoalIds: (json['socialGoalIds'] as List<dynamic>)
            .cast<String>()
            .toList(),
      );
}

class SocialGoal {
  const SocialGoal({
    required this.id,
    required this.businessGoalId,
    required this.type,
    required this.summary,
    required this.metricTargets,
  });

  final String id;
  final String businessGoalId;
  final SocialGoalType type;
  final String summary;
  final List<MetricTarget> metricTargets;

  SocialGoal copyWith({
    String? id,
    String? businessGoalId,
    SocialGoalType? type,
    String? summary,
    List<MetricTarget>? metricTargets,
  }) {
    return SocialGoal(
      id: id ?? this.id,
      businessGoalId: businessGoalId ?? this.businessGoalId,
      type: type ?? this.type,
      summary: summary ?? this.summary,
      metricTargets: metricTargets ?? this.metricTargets,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'businessGoalId': businessGoalId,
        'type': type.name,
        'summary': summary,
        'metricTargets': metricTargets.map((target) => target.toJson()).toList(),
      };

  factory SocialGoal.fromJson(Map<String, dynamic> json) => SocialGoal(
        id: json['id'] as String,
        businessGoalId: json['businessGoalId'] as String,
        type: SocialGoalTypeX.fromName(json['type'] as String),
        summary: json['summary'] as String,
        metricTargets: (json['metricTargets'] as List<dynamic>)
            .cast<Map<String, dynamic>>()
            .map(MetricTarget.fromJson)
            .toList(),
      );
}

class AudiencePersona {
  const AudiencePersona({
    required this.id,
    required this.brandId,
    required this.name,
    required this.role,
    required this.summary,
    required this.preferredNetworks,
    required this.goals,
    required this.painPoints,
  });

  final String id;
  final String brandId;
  final String name;
  final String role;
  final String summary;
  final List<SocialChannel> preferredNetworks;
  final List<String> goals;
  final List<String> painPoints;

  AudiencePersona copyWith({
    String? id,
    String? brandId,
    String? name,
    String? role,
    String? summary,
    List<SocialChannel>? preferredNetworks,
    List<String>? goals,
    List<String>? painPoints,
  }) {
    return AudiencePersona(
      id: id ?? this.id,
      brandId: brandId ?? this.brandId,
      name: name ?? this.name,
      role: role ?? this.role,
      summary: summary ?? this.summary,
      preferredNetworks: preferredNetworks ?? this.preferredNetworks,
      goals: goals ?? this.goals,
      painPoints: painPoints ?? this.painPoints,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'brandId': brandId,
        'name': name,
        'role': role,
        'summary': summary,
        'preferredNetworks':
            preferredNetworks.map((network) => network.name).toList(),
        'goals': goals,
        'painPoints': painPoints,
      };

  factory AudiencePersona.fromJson(Map<String, dynamic> json) => AudiencePersona(
        id: json['id'] as String,
        brandId: json['brandId'] as String,
        name: json['name'] as String,
        role: json['role'] as String,
        summary: json['summary'] as String,
        preferredNetworks: (json['preferredNetworks'] as List<dynamic>)
            .cast<String>()
            .map(SocialChannelX.fromName)
            .toList(),
        goals: (json['goals'] as List<dynamic>).cast<String>().toList(),
        painPoints:
            (json['painPoints'] as List<dynamic>).cast<String>().toList(),
      );
}

class Competitor {
  const Competitor({
    required this.id,
    required this.brandId,
    required this.name,
    required this.primaryChannels,
    required this.notes,
  });

  final String id;
  final String brandId;
  final String name;
  final List<SocialChannel> primaryChannels;
  final String notes;

  Competitor copyWith({
    String? id,
    String? brandId,
    String? name,
    List<SocialChannel>? primaryChannels,
    String? notes,
  }) {
    return Competitor(
      id: id ?? this.id,
      brandId: brandId ?? this.brandId,
      name: name ?? this.name,
      primaryChannels: primaryChannels ?? this.primaryChannels,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'brandId': brandId,
        'name': name,
        'primaryChannels': primaryChannels.map((channel) => channel.name).toList(),
        'notes': notes,
      };

  factory Competitor.fromJson(Map<String, dynamic> json) => Competitor(
        id: json['id'] as String,
        brandId: json['brandId'] as String,
        name: json['name'] as String,
        primaryChannels: (json['primaryChannels'] as List<dynamic>)
            .cast<String>()
            .map(SocialChannelX.fromName)
            .toList(),
        notes: json['notes'] as String,
      );
}

class SwotEntry {
  const SwotEntry({
    required this.id,
    required this.brandId,
    required this.category,
    required this.note,
  });

  final String id;
  final String brandId;
  final SwotCategory category;
  final String note;

  Map<String, dynamic> toJson() => {
        'id': id,
        'brandId': brandId,
        'category': category.name,
        'note': note,
      };

  factory SwotEntry.fromJson(Map<String, dynamic> json) => SwotEntry(
        id: json['id'] as String,
        brandId: json['brandId'] as String,
        category: SwotCategoryX.fromName(json['category'] as String),
        note: json['note'] as String,
      );
}

class AuditFinding {
  const AuditFinding({
    required this.id,
    required this.brandId,
    required this.title,
    required this.observation,
    required this.impact,
  });

  final String id;
  final String brandId;
  final String title;
  final String observation;
  final String impact;

  Map<String, dynamic> toJson() => {
        'id': id,
        'brandId': brandId,
        'title': title,
        'observation': observation,
        'impact': impact,
      };

  factory AuditFinding.fromJson(Map<String, dynamic> json) => AuditFinding(
        id: json['id'] as String,
        brandId: json['brandId'] as String,
        title: json['title'] as String,
        observation: json['observation'] as String,
        impact: json['impact'] as String,
      );
}

class ContentPillar {
  const ContentPillar({
    required this.id,
    required this.brandId,
    required this.name,
    required this.description,
    required this.targetMetric,
    required this.tone,
  });

  final String id;
  final String brandId;
  final String name;
  final String description;
  final String targetMetric;
  final String tone;

  ContentPillar copyWith({
    String? id,
    String? brandId,
    String? name,
    String? description,
    String? targetMetric,
    String? tone,
  }) {
    return ContentPillar(
      id: id ?? this.id,
      brandId: brandId ?? this.brandId,
      name: name ?? this.name,
      description: description ?? this.description,
      targetMetric: targetMetric ?? this.targetMetric,
      tone: tone ?? this.tone,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'brandId': brandId,
        'name': name,
        'description': description,
        'targetMetric': targetMetric,
        'tone': tone,
      };

  factory ContentPillar.fromJson(Map<String, dynamic> json) => ContentPillar(
        id: json['id'] as String,
        brandId: json['brandId'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
        targetMetric: json['targetMetric'] as String,
        tone: json['tone'] as String,
      );
}

class StrategyRecord {
  const StrategyRecord({
    required this.workspace,
    required this.brand,
    required this.businessGoals,
    required this.socialGoals,
    required this.personas,
    required this.competitors,
    required this.swotEntries,
    required this.auditFindings,
    required this.contentPillars,
  });

  final Workspace workspace;
  final Brand brand;
  final List<BusinessGoal> businessGoals;
  final List<SocialGoal> socialGoals;
  final List<AudiencePersona> personas;
  final List<Competitor> competitors;
  final List<SwotEntry> swotEntries;
  final List<AuditFinding> auditFindings;
  final List<ContentPillar> contentPillars;
}
