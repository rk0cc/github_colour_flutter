import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/widgets.dart' show Color;
import 'package:meta/meta.dart' show internal;

@internal
Map<String, int> convertColourToInt(Map<String, Color> colourMap) =>
    colourMap.map((key, value) => MapEntry(key, value.value));

@internal
Map<String, Color> convertIntToColour(Map<String, int> intMap) =>
    intMap.map((key, value) => MapEntry(key, Color(value)));

@internal
Uint8List encodedColour(Map<String, Color> colourMap) {
  List<int> enc = utf8.encode(jsonEncode(convertColourToInt(colourMap)));

  return enc is Uint8List ? enc : Uint8List.fromList(enc);
}

@internal
Map<String, Color> decodeColour(Uint8List rawContent) =>
    convertIntToColour(jsonDecode(utf8.decode(rawContent)));
