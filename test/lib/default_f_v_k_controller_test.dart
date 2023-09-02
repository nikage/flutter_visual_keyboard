import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_visual_keyboard/flutter_visual_keyboard.dart';

void main() {
  test('Highlight a key', () {
    var initialHighlightedKeys =  defaultFVKController.keyHiglighter.highlightedKeys;
    expect(initialHighlightedKeys.length, 0);

    defaultFVKController
        .keyHiglighter
        .byKeyLabel('a');
    var highlightedKeys = defaultFVKController.keyHiglighter.highlightedKeys;
    expect(highlightedKeys.length, 1);
  });
}