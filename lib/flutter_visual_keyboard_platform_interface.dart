import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_visual_keyboard_method_channel.dart';

abstract class FlutterVisualKeyboardPlatform extends PlatformInterface {
  /// Constructs a FlutterVisualKeyboardPlatform.
  FlutterVisualKeyboardPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterVisualKeyboardPlatform _instance = MethodChannelFlutterVisualKeyboard();

  /// The default instance of [FlutterVisualKeyboardPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterVisualKeyboard].
  static FlutterVisualKeyboardPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterVisualKeyboardPlatform] when
  /// they register themselves.
  static set instance(FlutterVisualKeyboardPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
