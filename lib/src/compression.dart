import 'dart:typed_data';

import 'package:lzma/lzma.dart';

Uint8List compressGHC(Uint8List rghc) => Uint8List.fromList(lzma.encode(rghc));

Uint8List decompressGHC(Uint8List compressed) {
  List<int> decompressed = lzma.decode(compressed);

  return decompressed is Uint8List
      ? decompressed
      : Uint8List.fromList(decompressed);
}
