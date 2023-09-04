import 'package:flutter_visual_keyboard/flutter_visual_keyboard.dart';
import 'package:get_it/get_it.dart';

/// The simplest dependency injection solution I could come up with.
/// It's not perfect, but it's good enough for this project.
class DI {
  static final GetIt _getIt = GetIt.asNewInstance();
  static bool? _isConfigured;

  static T get<T extends Object>() {
    if(_isConfigured != true) {
      configure();
      _isConfigured = true;
    }
    return _getIt.get<T>();
  }

  static void register<T extends Object>(T instance) =>
      _getIt.registerSingleton<T>(instance);

  static void registerFactory<T extends Object>(T Function() factoryFunc) =>
      _getIt.registerFactory<T>(factoryFunc);

  static void configure({Function? overrideRegistrations}) {
    _getIt.registerLazySingleton<FVKKeysBloc>(()=> (FVKKeysBloc()));
    _getIt.registerLazySingleton<DefaultFVKController>(()=> defaultFVKController);
    _getIt.allReadySync();
  }

  /// Use [DI.register] inside [callback] to override registrations
  static void override(Function callback) => callback();
}
