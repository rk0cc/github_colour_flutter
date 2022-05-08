import "dart:io";
import 'dart:typed_data';

import 'package:flutter/widgets.dart' show Color;
import "package:path/path.dart" as path;
import "package:path_provider/path_provider.dart" as path_provider;

import '../checksum.dart';
import "../compression.dart";
import '../conversion.dart';
import 'exception.dart';

Future<Directory> get _cacheDir async {
  Directory tmp = await path_provider.getTemporaryDirectory();

  Directory cacheDir =
      Directory(path.join(tmp.path, "github_colour_flutter_cache"));

  if (!await cacheDir.exists()) {
    cacheDir = await cacheDir.create(recursive: true);
  }

  return cacheDir;
}

Future<File> get _cacheFile async {
  File tmpfile = File(path.join(
      await _cacheDir.then((value) => value.path), "github_colour_cache.tmp"));

  if (!await tmpfile.exists()) {
    tmpfile = await tmpfile.create();
  }

  return tmpfile;
}

Future<File> get _cacheChecksum async {
  File checksum = File(path.join(await _cacheDir.then((value) => value.path),
      "github_colour_cache.checksum"));

  if (!await checksum.exists()) {
    checksum = await checksum.create();
  }

  return checksum;
}

Future<void> saveCache(Map<String, Color> githubColour) async {
  File tf = await _cacheFile;
  File cf = await _cacheChecksum;

  Uint8List rghc = encodedColour(githubColour);
  cf = await cf.writeAsString(generateChecksum(rghc), flush: true);
  tf = await tf.writeAsBytes(compressGHC(rghc), flush: true);
}

Future<Map<String, Color>> getCache() async {
  File tf = await _cacheFile;

  Uint8List rghc = decompressGHC(await tf.readAsBytes());

  File cf = await _cacheChecksum;

  if (!isValidChecksum(await cf.readAsString(), rghc)) {
    throw GitHubColourCacheChecksumMismatchedError();
  }

  return decodeColour(rghc);
}
