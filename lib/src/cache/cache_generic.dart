import 'package:flutter/widgets.dart' show Color;
import 'package:meta/meta.dart' show internal;

@internal
Future<void> saveCache(Map<String, Color> githubColour) async {
  throw UnsupportedError("No implementation in this platform");
}

@internal
Future<Map<String, Color>> getCache() async {
  throw UnsupportedError("No implementation in this platform");
}
