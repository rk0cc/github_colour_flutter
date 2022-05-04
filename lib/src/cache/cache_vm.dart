import "dart:io";

import 'package:flutter/widgets.dart' show Color;
import "package:path/path.dart" as path;
import "package:path_provider/path_provider.dart" as path_provider;

import "../compression.dart";

Future<File> get _cacheFile async {
  Directory tmp = await path_provider.getTemporaryDirectory();

  File tmpfile = File(path.join(tmp.path, "github_colour_cache.tmp"));

  if (!await tmpfile.exists()) {
    tmpfile = await tmpfile.create(recursive: true);
  }

  return tmpfile;
}

Future<void> saveCache(Map<String, Color> githubColour) async {
  File tf = await _cacheFile;

  tf = await tf.writeAsBytes(compressGHC(githubColour), flush: true);
}

Future<Map<String, Color>> getCache() async {
  File tf = await _cacheFile;

  return decompressGHC(await tf.readAsBytes());
}
