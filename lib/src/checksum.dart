import 'dart:typed_data';

import "package:sha3/sha3.dart";
import "package:hex/hex.dart";

String generateChecksum(Uint8List rghc) {
  SHA3 k = SHA3(256, SHA3_PADDING, 256);
  k.update(rghc);
  var hash = k.digest();
  return HEX.encode(hash);
}

bool isValidChecksum(String providedHex, Uint8List rghc) =>
    providedHex == generateChecksum(rghc);
