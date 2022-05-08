import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/widgets.dart' show Color;
import 'package:shared_preferences/shared_preferences.dart';

import '../checksum.dart';
import "../compression.dart";
import '../conversion.dart';
import 'exception.dart';

const String _spKey = "github_colour_cache";
const String _spcKey = "github_colour_cache_checksum";

Future<void> saveCache(Map<String, Color> githubColour) async {
  SharedPreferences sp = await SharedPreferences.getInstance();

  Uint8List rghc = encodedColour(githubColour);

  if (!isValidChecksum(sp.getString(_spcKey) ?? "", rghc)) {
    // There are no ways to store bytes directly
    await sp.setString(_spKey, base64Encode(compressGHC(rghc)));
    await sp.setString(_spcKey, generateChecksum(rghc));
  }
}

Future<Map<String, Color>> getCache() async {
  SharedPreferences sp = await SharedPreferences.getInstance();

  Uint8List rghc = decompressGHC(base64Decode(sp.getString(_spKey)!));

  if (!isValidChecksum(sp.getString(_spcKey)!, rghc)) {
    throw GitHubColourCacheChecksumMismatchedError();
  }

  return decodeColour(rghc);
}
