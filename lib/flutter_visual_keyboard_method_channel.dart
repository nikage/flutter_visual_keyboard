import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_visual_keyboard_platform_interface.dart';

/// An implementation of [FlutterVisualKeyboardPlatform] that uses method channels.
class MethodChannelFlutterVisualKeyboard extends FlutterVisualKeyboardPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_visual_keyboard');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
