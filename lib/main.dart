import 'package:flutter/material.dart';

import 'app/metarix_app.dart';
import 'core/app_services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final services = await AppServices.bootstrap();
  runApp(MetarixApp(services: services));
}
