import 'package:flutter/material.dart';


class FlutterVisualKeyboard extends StatefulWidget {
  const FlutterVisualKeyboard({super.key});

  @override
  State<FlutterVisualKeyboard> createState() => _FlutterVisualKeyboardState();
}

class _FlutterVisualKeyboardState extends State<FlutterVisualKeyboard> {
  KeyService _keyService = KeyService();

  @override
  Widget build(BuildContext context) {
    // TODO: make querty visual keyboard

    var keyStrings = _keyService.getKeyStrings();
    return IntrinsicWidth(
      child: Container(
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Colors.grey[300],
            border: Border.all( width: 1),
            borderRadius: BorderRadius.circular(5)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var rowEntry in keyStrings.asMap().entries)
              if (rowEntry.key == 0)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  // mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var keyEntry in rowEntry.value.asMap().entries)
                      _buildKeyboardKey(keyEntry.value),
                  ],
                )
              else
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var keyEntry in rowEntry.value.asMap().entries)
                      _buildKeyboardKey(keyEntry.value),
                  ],
                ),
          ],
        ),
      ),
    );
  }

  KeyboardKey _buildKeyboardKey(String key) {
    return KeyboardKey(
                keyValue: KeyboardKeyValue(subText: key),
              );
  }
}

class KeyService {
  List<List<String>> getKeyStrings() {
    return [
      ['esc', 'f1', 'f2', 'f3', 'f4', 'f5', 'f6', 'f7', 'f8', 'f9', 'f10', 'f11', 'f12'],
      [...'`1234567890-='.split(""), "Backspace"],
      ["Tab", ..."qwertyuiop[]\\".split("")],
      ["Caps Lock", ..."asdfghjkl;'".split(""), "Enter"],
      ["Shift", ..."zxcvbnm,./".split(""), "Shift"],
      ["control", "option", "command", "Space", "command", "option", "control"]
    ];
  }
}

class KeyboardKey extends StatefulWidget {
  final KeyboardKeyValue keyValue;

  const KeyboardKey({required this.keyValue, super.key});

  @override
  State<KeyboardKey> createState() => _KeyboardKeyState();
}

class _KeyboardKeyState extends State<KeyboardKey> {
  @override
  Widget build(BuildContext context) {
    double squareSize = 54;
    var keyText = widget.keyValue.subText;
    double widthMultiplier = 1;

    if (widget.keyValue.subText == 'esc') {
      widthMultiplier = 1.3;
    }
    if (widget.keyValue.subText == 'Backspace') {
      widthMultiplier = 1.4;
    }
    if (widget.keyValue.subText == 'Tab') {
      widthMultiplier = 1.4;
    }
    if (widget.keyValue.subText == 'Caps Lock') {
      widthMultiplier = 1.8;
    }
    if (widget.keyValue.subText == 'Enter') {
      widthMultiplier = 1.64;
    }
    if (widget.keyValue.subText == 'control') {
      widthMultiplier = 1.3;
    }
    if (widget.keyValue.subText == 'Shift') {
      widthMultiplier = 2.23;
    }
    if (widget.keyValue.subText == 'option') {
      widthMultiplier = 1.3;
    }
    if (widget.keyValue.subText == 'command') {
      widthMultiplier = 1.6;
    }
    if (widget.keyValue.subText == 'Space') {
      widthMultiplier = 6.25;
    }

    var isLetterKey = keyText.length == 1;
    var keyTextWidget = Text(
      isLetterKey ? keyText.toUpperCase() : keyText,
      softWrap: true,
      style: TextStyle(fontSize: 13),
    );
    var displayTextWidget =
        isLetterKey ? Center(child: keyTextWidget) : keyTextWidget;
    return Container(
        width: squareSize * widthMultiplier,
        height: squareSize,
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black, width: 1),
            borderRadius: BorderRadius.circular(5)),
        padding: EdgeInsets.all(3),
        margin: EdgeInsets.all(1),
        child: displayTextWidget
    );
  }
}

class KeyboardKeyValue {
  String? supText;
  /// The text that is displayed on the key.
  /// Some keyboards have multiple characters on a key.
  /// By default, the [subText] character is displayed on center of [KeyType.letter]
  String subText;
  KeyType keyType;

  KeyboardKeyValue(
      {this.supText, required this.subText, this.keyType = KeyType.letter});
}

enum KeyType {
  letter,
  number,
  functional,
  special,
}


