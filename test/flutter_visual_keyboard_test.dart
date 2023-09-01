import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_visual_keyboard/flutter_visual_keyboard.dart';
import 'package:flutter_visual_keyboard/flutter_visual_keyboard_platform_interface.dart';
import 'package:flutter_visual_keyboard/flutter_visual_keyboard_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterVisualKeyboardPlatform
    with MockPlatformInterfaceMixin
    implements FlutterVisualKeyboardPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FlutterVisualKeyboardPlatform initialPlatform = FlutterVisualKeyboardPlatform.instance;

  test('$MethodChannelFlutterVisualKeyboard is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterVisualKeyboard>());
  });

  test('getPlatformVersion', () async {
    FlutterVisualKeyboard flutterVisualKeyboardPlugin = FlutterVisualKeyboard();
    MockFlutterVisualKeyboardPlatform fakePlatform = MockFlutterVisualKeyboardPlatform();
    FlutterVisualKeyboardPlatform.instance = fakePlatform;

    expect(await flutterVisualKeyboardPlugin.getPlatformVersion(), '42');
  });
}
