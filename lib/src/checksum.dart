import 'dart:typed_data';

import 'package:hashlib/hashlib.dart';

String generateChecksum(Uint8List rghc) {
  final hash = sha3_256.convert(rghc);

  return hash.hex();
}

bool isValidChecksum(String providedHex, Uint8List rghc) =>
    providedHex == generateChecksum(rghc);
