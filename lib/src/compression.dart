import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/widgets.dart' show Color;
import 'package:lzma/lzma.dart';

import 'conversion.dart';

Uint8List compressGHC(Map<String, Color> ghc) => Uint8List.fromList(
    lzma.encode(utf8.encode(jsonEncode(convertColourToInt(ghc)))));

Map<String, Color> decompressGHC(Uint8List compressed) =>
    convertIntToColour(jsonDecode(utf8.decode(lzma.decode(compressed))));
