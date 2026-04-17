import 'app_mode.dart';
import 'metarix_local_config_ref.dart';

class MetarixPublicConfig {
  const MetarixPublicConfig({
    required this.appMode,
    required this.localConfigRef,
  });

  final AppMode appMode;
  final MetarixLocalConfigRef localConfigRef;

  Map<String, dynamic> toJson() => {
    'appMode': appMode.name,
    'localConfigRef': localConfigRef.toJson(),
  };

  factory MetarixPublicConfig.fromJson(Map<String, dynamic> json) =>
      MetarixPublicConfig(
        appMode: AppModeX.fromName(json['appMode'] as String),
        localConfigRef: MetarixLocalConfigRef.fromJson(
          Map<String, dynamic>.from(json['localConfigRef'] as Map),
        ),
      );
}
