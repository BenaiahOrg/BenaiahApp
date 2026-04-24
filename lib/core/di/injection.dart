// ignore_for_file: document_ignores

import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:benaiah_app/core/di/injection.config.dart';

// ignore: specify_nonobvious_property_types
final container = GetIt.instance;

@InjectableInit()
void configureDependencies() => container.init();
