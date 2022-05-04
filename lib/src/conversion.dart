import 'package:flutter/widgets.dart' show Color;

Map<String, int> convertColourToInt(Map<String, Color> colourMap) =>
    colourMap.map((key, value) => MapEntry(key, value.value));

Map<String, Color> convertIntToColour(Map<String, int> intMap) =>
    intMap.map((key, value) => MapEntry(key, Color(value)));
