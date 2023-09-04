import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_visual_keyboard/config.dart';
import 'injector.dart';


/// Used to group [FVKKey]s with index.
typedef Entries<T> = Iterable<MapEntry<int, T>>;
typedef FVKKeyRow = List<FVKKey>;
typedef FVKKeyRows = List<FVKKeyRow>;

class FlutterVisualKeyboard extends StatefulWidget {
  final FVKController controller;

  const FlutterVisualKeyboard({Key? key, required this.controller})
      : super(key: key);

  @override
  State<FlutterVisualKeyboard> createState() => _FlutterVisualKeyboardState();
}

class _FlutterVisualKeyboardState extends State<FlutterVisualKeyboard> {

  late final FVKKeysBloc _fvkKeysBloc;
  late final FVKController _keyboardController;


  @Deprecated('will be removed')
  late List<List<String>> keyStrings;

  late Entries<FVKKeys> _rowEntries;

  late StreamSubscription _keysListener;

  @override
  void initState() {
    super.initState();
    _fvkKeysBloc = DI.get<FVKKeysBloc>();

    _keyboardController = widget.controller;

     // if shift is pressed, then the keyStrings should be the superSymbols
     // else the keyStrings should be the subSymbols

    _rowEntries = _fvkKeysBloc.state.asKeyboardRows().asMap().entries;

    _keysListener = _fvkKeysBloc.stream
        .asyncMap((FVKKeys keys) => keys.asKeyboardRows())
        .listen((FVKKeyRows keyRows) {


      setState(() {
          _rowEntries = keyRows.asMap().entries;
      });
    });
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
                      _KeyboardKeyWidget(
                        fvkKey: keyEntry.value,
                      ),
                  ],
                )
              else
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var keyEntry in rowEntry.value.asMap().entries)
                      _KeyboardKeyWidget(
                        fvkKey: keyEntry.value,
                      ),
                  ],
                ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _keyboardController.dispose();
    _keysListener.cancel();

    super.dispose();
  }
}

typedef HighightedKeys = Map<FVKKey, Color>;

abstract class FVKEvent {}

class HighlightFVKEvent implements FVKEvent {
  final HighightedKeys? highlightKeys;

  HighlightFVKEvent({HighightedKeys? this.highlightKeys});
}

typedef FVKKeys = List<FVKKey>;
typedef FVKKeys$ = Stream<FVKKeys>;

extension EVKKeys on FVKKeys {
  findKeyByLabel(String keyLabel) {
    return firstWhere((key) => key.subText == keyLabel);
  }

  @Deprecated('FIXME: implement keyboard rows map instead of converting list')
  List<List<FVKKey>> asKeyboardRows() {
      // TODO: make map
      // 13
      // 14
      // 14
      // 13
      // 12
      // 7
    return [
      sublist(0, 13),
      sublist(13, 27),
      sublist(27, 41),
      sublist(41, 54),
      sublist(54, 66),
      sublist(66, 73)
    ];
  }
}

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


    // _keyboardController._fvkEventStreamController
    //     .add(HighlightFVKEvent(highlightKeys: {
    //   FVKKey(subText: keyLabel, uniqueName: ''): color,
    // }));


  }
}

/// Holds the state of [FVKKeys]
class FVKKeysBloc extends Cubit<FVKKeys>{

  FVKKeysBloc() : super([]) {
    FVKLayout layout = FVKLayout.layouts['english']!;
    FVKKeys keys = layout.asFVKKeys(layout);
    emit(keys);
  }

  highlightKey(String keyLabel, {Color? color}) {
    var map = state.map((FVKKey key) {
      if (key.subText == keyLabel) {
        key.isHighlighted = true;
        key.highlightColor = color ?? Config.defaultHighlightColor;
      }
      return key;
    }).toList();
    emit(map);
  }
}

abstract class FVKController {
  final _fvkEventStreamController = StreamController<HighlightFVKEvent>();
  final _fvkKeysBloc = DI.get<FVKKeysBloc>();

  // get _keys => _fvkKeysBloc.state;

  Stream<HighlightFVKEvent> get events$ => _fvkEventStreamController.stream;


  dispose() {
    _fvkEventStreamController.close();
  }
}

extension HighlightE on FVKController {
  highlightByLabel(String keyLabel, {Color? color}) {
    color ??= Config.defaultHighlightColor;

    _fvkKeysBloc.highlightKey(keyLabel, color: color);
  }
}

class DefaultFVKController extends FVKController {
  DefaultFVKController();
}

final defaultFVKController = DefaultFVKController();


typedef Strings = List<String>;
typedef LayoutListFormat = List<List<List<String>>>;

class FVKLayout {
  final LayoutListFormat _layout;

  FVKLayout(this._layout);

  factory FVKLayout.fromSymbolRows(List<Strings> symbolRows) {
    return FVKLayout(wrapWithSpecialKeys(
      subSymbols: symbolRows[0],
      superSymbols: symbolRows[1],
    ));
  }

  get superSymbols => [..._layout[0]];
  get subSymbols => [..._layout[1]];

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
  static LayoutListFormat wrapWithSpecialKeys({
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

  /// FIXME: Implement keyboard rows map instead of converting list.
  /// The same as with [FVKKeys.asKeyboardRows] for better performance.
  FVKKeys asFVKKeys(FVKLayout layout) {
    FVKKeys keys = [];

    var superSymbols = layout.superSymbols;
    var subSymbols = layout.subSymbols;

    for (var row = 0; row < superSymbols.length; row++) {
      var superSymbolRow = superSymbols[row];
      var subSymbolRow = subSymbols[row];
      for (var col = 0; col < superSymbolRow.length; col++) {
        var superSymbol = superSymbolRow[col];
        var subSymbol = subSymbolRow[col];

        var key = FVKKey(
          subText: subSymbol,
          supText: superSymbol,
          uniqueName: superSymbol,
        );

        keys = [...keys, key];
      }
    }
    return keys;
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
            color: widget.fvkKey.isHighlighted
                ? widget.fvkKey.highlightColor
                : Colors.white,
            border: Border.all(color: Colors.black, width: 1),
            borderRadius: BorderRadius.circular(5)),
        padding: const EdgeInsets.all(3),
        margin: const EdgeInsets.all(1),
        child: displayTextWidget);
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
