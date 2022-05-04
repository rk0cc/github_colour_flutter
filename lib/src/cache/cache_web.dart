import 'dart:convert';

import 'package:flutter/widgets.dart' show Color;
import 'package:shared_preferences/shared_preferences.dart';

import "../compression.dart";

const String _spKey = "github_colour_cache";

Future<void> saveCache(Map<String, Color> githubColour) async {
  SharedPreferences sp = await SharedPreferences.getInstance();

  // There are no ways to store bytes directly
  await sp.setString(_spKey, base64Encode(compressGHC(githubColour)));
}

Future<Map<String, Color>> getCache() async {
  SharedPreferences sp = await SharedPreferences.getInstance();

  return decompressGHC(base64Decode(sp.getString(_spKey)!));
}
