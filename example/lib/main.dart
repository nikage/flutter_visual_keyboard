import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_visual_keyboard/flutter_visual_keyboard.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      // platformVersion =
      //     await _flutterVisualKeyboardPlugin.getPlatformVersion() ?? 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      // _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Focus(
            autofocus: true,
            onKey: (node, event) {
              if(event is RawKeyDownEvent) {
                defaultFVKController
                    .highlightByLabel(event.logicalKey.keyLabel);
              }
              if(event is RawKeyUpEvent) {
                defaultFVKController
                    .highlightReset(event.logicalKey.keyLabel);
              }
              // NOTE: this is just for testing purposes
              // all key events should be handled properly
              return KeyEventResult.handled;
            },
            child: Center(
                child: FlutterVisualKeyboard(controller: defaultFVKController)
            )
        ),
      ),
    );
  }
}
