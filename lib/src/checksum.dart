import 'dart:typed_data';

import 'package:hashlib/hashlib.dart';
import 'package:meta/meta.dart' show internal;

@internal
String generateChecksum(Uint8List rghc) {
  final hash = sha3_256.convert(rghc);

  return hash.hex();
}

@internal
bool isValidChecksum(String providedHex, Uint8List rghc) =>
    providedHex == generateChecksum(rghc);
