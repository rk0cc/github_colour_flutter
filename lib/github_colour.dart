/// Receive latest commit of
/// [ozh's github-colors](https://github.com/ozh/github-colors) to Flutter's
/// [Color].
library github_colour;

import 'dart:convert';

import 'package:flutter/widgets.dart' show Color;
import 'package:http/http.dart' as http show get;
import 'package:meta/meta.dart' show sealed;

import 'src/cache/cache.dart';

/// An [Error] thrown when response unsuccessfully and no cache can be used.
class GitHubColourLoadFailedError extends Error {
  /// HTTP response code when fetching colour data.
  final int responseCode;

  GitHubColourLoadFailedError._(this.responseCode)
      : assert(responseCode != 200);

  @override
  String toString() =>
      "GitHubColourLoadFailedError: Can not receive GitHub language colour from server with HTTP code $responseCode.";
}

/// A class for getting GitHub language colour.
@sealed
class GitHubColour {
  static GitHubColour? _instance;
  final Map<String, Color> _githubLangColour;

  /// A [String] of hex value when the language is undefined or null.
  static const String defaultColourHex = "#8f8f8f";

  /// [Color] object of [defaultColourHex].
  static const Color defaultColour = Color(0xff8f8f8f);

  GitHubColour._(Map<String, Color> githubLangColour)
      : this._githubLangColour = Map.unmodifiable(githubLangColour);

  /// Construct an instance of [GitHubColour].
  ///
  /// If no instance created, it will construct and will be reused when
  /// [getInstance] or [getExistedInstance] called again.
  static Future<GitHubColour> getInstance() async {
    if (_instance == null) {
      final Uri ghc = Uri.parse(
          "https://raw.githubusercontent.com/ozh/github-colors/master/colors.json");

      var resp = await http.get(ghc);

      Map<String, Color> ghjson;

      if (resp.statusCode != 200) {
        try {
          ghjson = await getCache();
        } catch (e) {
          throw GitHubColourLoadFailedError._(resp.statusCode);
        }
      } else {
        ghjson = (jsonDecode(resp.body) as Map<String, dynamic>)
            .map<String, Color>((key, value) {
          String hex = value["color"] ?? defaultColourHex;
          hex = "FF${hex.substring(1).toUpperCase()}";

          return MapEntry(key, Color(int.parse(hex, radix: 16)));
        });
        await saveCache(ghjson);
      }

      _instance = GitHubColour._(ghjson);
    }

    return _instance!;
  }

  /// Get constructed instance which called [getInstance] early.
  ///
  /// It throws [UnimplementedError] if called with no existed instance.
  static GitHubColour getExistedInstance() {
    if (_instance == null) {
      throw UnimplementedError("No existed instance found in GitHubColour");
    }

    return _instance!;
  }

  /// Find [Color] for the [language].
  ///
  /// If [language] is undefined or defined with `null`, it uses [fallback]
  /// insteaded.
  Color find(String language, {Color fallback = defaultColour}) =>
      _githubLangColour[language] ?? fallback;
}

/// Alias type for repersenting "colour" in American English which does exactly
/// same with [GitHubColour].
typedef GitHubColor = GitHubColour;
