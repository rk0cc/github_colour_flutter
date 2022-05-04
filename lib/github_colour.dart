library github_colour;

import 'dart:convert';

import 'package:flutter/widgets.dart' show Color;
import 'package:http/http.dart' as http show get;
import 'package:meta/meta.dart' show sealed;

class GitHubColourLoadFailedError extends Error {
  final int responseCode;

  GitHubColourLoadFailedError._(this.responseCode)
      : assert(responseCode != 200);

  @override
  String toString() =>
      "GitHubColourLoadFailedError: Can not receive GitHub language colour from server with HTTP code $responseCode.";
}

@sealed
class GitHubColour {
  static GitHubColour? _instance;
  final Map<String, Color> _githubLangColour;

  static const String defaultColourHex = "#8f8f8f";
  static const Color defaultColor = Color(0xff8f8f8f);

  GitHubColour._(Map<String, Color> githubLangColour)
      : this._githubLangColour = Map.unmodifiable(githubLangColour);

  static Future<GitHubColour> getInstance() async {
    if (_instance == null) {
      final Uri ghc = Uri.parse(
          "https://raw.githubusercontent.com/ozh/github-colors/master/colors.json");

      var resp = await http.get(ghc);

      if (resp.statusCode != 200) {
        throw GitHubColourLoadFailedError._(resp.statusCode);
      }

      _instance = GitHubColour._((jsonDecode(resp.body) as Map<String, dynamic>)
          .map<String, Color>((key, value) {
        String hex = value["color"] ?? defaultColourHex;
        hex = "FF${hex.substring(1).toUpperCase()}";

        return MapEntry(key, Color(int.parse(hex, radix: 16)));
      }));
    }

    return _instance!;
  }

  static GitHubColour getExistedInstance() {
    if (_instance == null) {
      throw UnimplementedError("No existed instance found in GitHubColour");
    }

    return _instance!;
  }

  Color find(String language, {Color fallback = defaultColor}) =>
      _githubLangColour[language] ?? fallback;
}

typedef GitHubColor = GitHubColour;
