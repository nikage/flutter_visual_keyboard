import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_visual_keyboard/config.dart';
import 'injector.dart';


class FlutterVisualKeyboard extends StatefulWidget {
  const FlutterVisualKeyboard({super.key});

  @override
  State<FlutterVisualKeyboard> createState() => _FlutterVisualKeyboardState();
}

typedef RowEntries = Iterable<MapEntry<int, List<String>>>;

class _FlutterVisualKeyboardState extends State<FlutterVisualKeyboard> {

  final KeyService _keyService = DI.get<KeyService>();
  final FVKController _keyboardController = DI.get<FVKController>();

  late List<List<String>> keyStrings;

  late RowEntries _rowEntries;

  @override
  void initState() {
    super.initState();
     keyStrings = _keyService.getKeySubStrings();
     // if shift is pressed, then the keyStrings should be the superSymbols
     // else the keyStrings should be the subSymbols
    
    _keyboardController.events$.listen((HighlightFVKEvent event) {
      if (event.highlightKeys != null) {
        setState(() {
          event.highlightKeys!.forEach((key, color) {
            key.isHighlighted = true;
            key.highlightColor = color;
          });
        });
      }
    });
    
     _rowEntries = keyStrings.asMap().entries;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: make querty visual keyboard
    return IntrinsicWidth(
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Colors.grey[300],
            border: Border.all( width: 1),
            borderRadius: BorderRadius.circular(5)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var rowEntry in _rowEntries)
              if (rowEntry.key == 0)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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

  _KeyboardKeyWidget _buildKeyboardKey(String key) => _KeyboardKeyWidget(
        fvkKey: FVKKey(subText: key, uniqueName: key),
      );

  @override
  void dispose() {
    _keyboardController.dispose();
    super.dispose();
  }
}

typedef HighightedKeys = Map<FVKKey, Color>;

abstract class FVKEvent {}

class HighlightFVKEvent implements FVKEvent {
  final HighightedKeys? highlightKeys;

  HighlightFVKEvent({HighightedKeys? this.highlightKeys});
}

typedef FVKKeys = Iterable<FVKKey>;

class KeyHighlighter {
  // FIXME: get color from theme
  static Color _defaultColor = Colors.red;

  final FVKController _keyboardController;

  KeyHighlighter(FVKController keyboardController): _keyboardController = keyboardController;

  FVKKeys get highlightedKeys => [];

  set defaultColor(Color color) {
    _defaultColor = color;
  }

  Color get defaultColor => _defaultColor;

  byKeyLabel(String keyLabel, {Color? color}) {
    color ??= _defaultColor;

    _keyboardController._fvkEventStreamController.add(HighlightFVKEvent(
      highlightKeys: {
        FVKKey(subText: keyLabel, uniqueName: ''): color,
      },
    ));
  }
}

abstract class FVKController {
  final _fvkEventStreamController = StreamController<HighlightFVKEvent>();
  
  Stream<HighlightFVKEvent> get events$ => _fvkEventStreamController.stream;
  Stream get _FVKKeys$ => events$.map((event) => event.highlightKeys!.keys);

  KeyHighlighter get keyHiglighter => KeyHighlighter(this);

  dispose() {
    _fvkEventStreamController.close();
  }
}


class DefaultFVKController extends FVKController {
  DefaultFVKController();
}

final defaultFVKController = DefaultFVKController();


typedef Strings = List<String>;

class FVKLayout {
  final List<Strings> _layout;

  FVKLayout(this._layout);

  factory FVKLayout.fromSymbolRows(List<Strings> symbolRows) {
    return FVKLayout(wrapWithSpecialKeys(
      subSymbols: symbolRows[0],
      superSymbols: symbolRows[1],
    ));
  }

  get superSymbols => _layout[0];
  get subSymbols => _layout[1];

  static final Map<String, FVKLayout> layouts = {
    'english': FVKLayout.fromSymbolRows([
          ["QWERTYUIOP{}|", "ASDFGHJKL:\"", "ZXCVBNM<>?"],
          ["qwertyuiop[]\\", "asdfghjkl;'", "zxcvbnm,./"],
        ])
  };

  /// [subSymbols] represent the symbols on the bottom of the key.
  /// [superSymbols] represent the symbols on the top of the key.
  /// This method wraps the [subSymbols] and [superSymbols] in a keyboard layout
  /// with special keys like `esc`, `Tab`, `Caps Lock`, etc.
  static wrapWithSpecialKeys({
    required Strings subSymbols,
    required Strings superSymbols,
  }) {
    assert(subSymbols.length == 3);
    assert(superSymbols.length == 3);

    Strings Function(String row) listSplitter = (row) => row.split("");

    List<Strings> subRows = subSymbols.map(listSplitter).toList();
    List<Strings> superRows = superSymbols.map(listSplitter).toList();


    const fKeysRow = ['esc', 'f1', 'f2', 'f3', 'f4', 'f5', 'f6', 'f7', 'f8', 'f9', 'f10', 'f11', 'f12'];
    const bottomRow = ["control", "option", "command", "Space", "command", "option", "control"];
    return [
      [
        fKeysRow,
        [...'~!@#\$%^&*()_+'.split(""), "Backspace"],
        ["Tab", ...superRows[0]],
        ["Caps Lock", ...superRows[1], "Enter"],
        ["Shift", ...superRows[2], "Shift"],
        bottomRow
      ],
      [
        fKeysRow,
        [...'`1234567890-='.split(""), "Backspace"],
        ["Tab", ...subRows[0]],
        ["Caps Lock", ...subRows[1], "Enter"],
        ["Shift", ...subRows[2], "Shift"],
        bottomRow
      ],
    ];
  }
}

class KeyService {
  List<List<String>> getKeySubStrings() {
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

class _KeyboardKeyWidget extends StatefulWidget {
  final FVKKey fvkKey;

  const _KeyboardKeyWidget({required this.fvkKey});

  @override
  State<_KeyboardKeyWidget> createState() => _KeyboardKeyWidgetState();
}

class _KeyboardKeyWidgetState extends State<_KeyboardKeyWidget> {
  @override
  Widget build(BuildContext context) {
    double squareSize = 54;
    var keyText = widget.fvkKey.subText;
    double widthMultiplier = 1;

    if (widget.fvkKey.subText == 'esc') {
      widthMultiplier = 1.3;
    }
    if (widget.fvkKey.subText == 'Backspace') {
      widthMultiplier = 1.4;
    }
    if (widget.fvkKey.subText == 'Tab') {
      widthMultiplier = 1.4;
    }
    if (widget.fvkKey.subText == 'Caps Lock') {
      widthMultiplier = 1.8;
    }
    if (widget.fvkKey.subText == 'Enter') {
      widthMultiplier = 1.64;
    }
    if (widget.fvkKey.subText == 'control') {
      widthMultiplier = 1.3;
    }
    if (widget.fvkKey.subText == 'Shift') {
      widthMultiplier = 2.23;
    }
    if (widget.fvkKey.subText == 'option') {
      widthMultiplier = 1.3;
    }
    if (widget.fvkKey.subText == 'command') {
      widthMultiplier = 1.6;
    }
    if (widget.fvkKey.subText == 'Space') {
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

class FVKKey {
  String? supText;
  /// The text that is displayed on the key.
  /// Some keyboards have multiple characters on a key.
  /// By default, the [subText] character is displayed on center of [FVKKeyType.letter]
  String subText;
  FVKKeyType keyType;


  /// Used to differentiate keys with the same [subText].
  /// For example, the left and right shift keys
  /// have the same [subText] but different [uniqueName].
  @Deprecated('FIXME: implement this')
  String uniqueName = '';
  Color highlightColor;
  bool isHighlighted = false;

  FVKKey({
    this.supText,
    required this.subText,
    this.keyType = FVKKeyType.letter,
    @Deprecated('FIXME: implement this')
    required this.uniqueName,
    this.highlightColor = Config.defaultHighlightColor,
  });

  factory FVKKey.fromString(String keyLabel) {
    // FIXME: add validation
    return FVKKey(subText: keyLabel, uniqueName: keyLabel);
  }
}

enum FVKKeyType {
  letter,
  number,
  functional,
  special,
}
