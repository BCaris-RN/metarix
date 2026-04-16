import 'package:flutter/widgets.dart';

import '../core/app_services.dart';

class MetarixScope extends InheritedWidget {
  const MetarixScope({
    required this.services,
    required super.child,
    super.key,
  });

  final AppServices services;

  static AppServices of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<MetarixScope>();
    assert(scope != null, 'MetarixScope not found in widget tree.');
    return scope!.services;
  }

  @override
  bool updateShouldNotify(MetarixScope oldWidget) => services != oldWidget.services;
}
