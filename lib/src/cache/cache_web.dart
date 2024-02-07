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

Future<(String, Uint8List)?> _getStoredChecksumAndCache(
    Database db, StoreRef<String, Object> store) async {
  var cache = await store.record(_ctxKey).get(db);
  var checksum = await store.record(_checkKey).get(db);

  try {
    return (checksum as String, decompressGHC((cache as Blob).bytes));
  } on TypeError {
    return null;
  }
}

@internal
Future<void> saveCache(Map<String, Color> githubColour) async {
  final Uint8List rghc = encodedColour(githubColour);
  final Database db = await _openDB();

  try {
    final store = _getStoreRef();

    var currentRecord = await _getStoredChecksumAndCache(db, store);

    if (currentRecord != null) {
      var (currentChecksum, currentCache) = currentRecord;

      if (isValidChecksum(currentChecksum, currentCache)) return;
    }

    await Future.wait([
      store.record(_ctxKey).put(db, Blob(compressGHC(rghc)), merge: false),
      store.record(_checkKey).put(db, generateChecksum(rghc), merge: false)
    ], eagerError: true);
  } finally {
    await db.close();
  }
}

@internal
Future<Map<String, Color>> getCache() async {
  final Database db = await _openDB();

  try {
    final store = _getStoreRef();

    var currentRecord = await _getStoredChecksumAndCache(db, store);

    if (currentRecord != null) {
      var (currentChecksum, currentCache) = currentRecord;

      if (isValidChecksum(currentChecksum, currentCache)) {
        return decodeColour(currentCache);
      }
    }

    throw GitHubColourCacheChecksumMismatchedError();
  } finally {
    await db.close();
  }
}
