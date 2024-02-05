import 'dart:typed_data';

import 'package:flutter/widgets.dart' show Color;
import 'package:meta/meta.dart' show internal;
import 'package:sembast/sembast.dart';
import 'package:sembast/blob.dart';
import 'package:sembast_web/sembast_web.dart';

import '../checksum.dart';
import "../compression.dart";
import '../conversion.dart';
import 'exception.dart';

const String _dbName = "github_colour_cache";
const String _ctxKey = "cache_content";
const String _checkKey = "cache_checksum";

Future<Database> _openDB() {
  DatabaseFactory dbf = databaseFactoryWeb;

  return dbf.openDatabase(_dbName);
}

StoreRef<String, Object> _getStoreRef() => StoreRef("${_dbName}_store");

@internal
Future<void> saveCache(Map<String, Color> githubColour) async {
  final Uint8List rghc = encodedColour(githubColour);
  final Database db = await _openDB();

  try {
    final store = _getStoreRef();

    var currentCache = await store.record(_ctxKey).get(db);
    var currentChecksum = await store.record(_checkKey).get(db);

    if (currentCache is Blob && currentChecksum is String) {
      if (isValidChecksum(currentChecksum, currentCache.bytes)) {
        return;
      }
    }

    var writeCache =
        store.record(_ctxKey).put(db, Blob(compressGHC(rghc)), merge: false);
    var writeChecksum =
        store.record(_checkKey).put(db, generateChecksum(rghc), merge: false);

    await writeCache;
    await writeChecksum;
  } finally {
    await db.close();
  }
}

@internal
Future<Map<String, Color>> getCache() async {
  final Database db = await _openDB();

  try {
    final store = _getStoreRef();

    var currentCache = await store.record(_ctxKey).get(db);
    var currentChecksum = await store.record(_checkKey).get(db);

    if (currentCache is Blob && currentChecksum is String) {
      Uint8List ctx = currentCache.bytes;

      if (isValidChecksum(currentChecksum, ctx)) {
        return decodeColour(decompressGHC(ctx));
      }
    }

    throw GitHubColourCacheChecksumMismatchedError();
  } finally {
    await db.close();
  }
}
