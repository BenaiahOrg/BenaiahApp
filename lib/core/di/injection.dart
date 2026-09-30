import 'package:benaiah_app/core/di/injection.config.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

final GetIt container = GetIt.instance;

@InjectableInit()
void configureDependencies() => container.init();
