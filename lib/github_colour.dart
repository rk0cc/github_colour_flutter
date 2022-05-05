/// Receive latest commit of
/// [ozh's github-colors](https://github.com/ozh/github-colors) to Flutter's
/// [Color].
library github_colour;

import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart'
    show Color, ColorSwatch, WidgetsFlutterBinding;
import 'package:http/http.dart' as http show get;
import 'package:meta/meta.dart' show sealed;

import 'src/cache/cache.dart';

const String _src =
    "https://raw.githubusercontent.com/ozh/github-colors/master/colors.json";

/// A handler when no language data found in [GitHubColour.find].
typedef LanguageUndefinedHandler = Color Function();

/// An [Error] that can not fetch [GitHubColour] data.
abstract class GitHubColourLoadFailedError extends Error {
  final String _message;

  GitHubColourLoadFailedError._(
      [this._message =
          "There are some unexpected error when loading resources."]);

  @override
  String toString() => _message;
}

/// An [Error] thrown when response unsuccessfully and no cache can be used.
class GitHubColourHTTPLoadFailedError extends GitHubColourLoadFailedError {
  /// HTTP response code when fetching colour data.
  final int responseCode;

  GitHubColourHTTPLoadFailedError._(this.responseCode)
      : assert(responseCode != 200),
        super._();

  @override
  String toString() =>
      "GitHubColourLoadFailedError: Can not receive GitHub language colour from server with HTTP code $responseCode.";
}

/// An [Error] thrown when no resources available to initalize [GitHubColour].
class GitHubColourNoAvailableResourceError extends GitHubColourLoadFailedError {
  GitHubColourNoAvailableResourceError._() : super._();

  @override
  String toString() =>
      "GitHubColourNoAvailableResourceError: Unable to read GitHub colour data with all available sources.";
}

/// An [Error] when no colour data of the language.
class UndefinedLanguageColourError extends ArgumentError {
  /// Undefined language name.
  final String undefinedLanguage;

  UndefinedLanguageColourError._(this.undefinedLanguage)
      : super("Unknown language '$undefinedLanguage'",
            "UndefinedLanguageColourError");
}

Map<String, Color> _colourReader(String json) =>
    (jsonDecode(json) as Map<String, dynamic>)
        .map<String, Color>((language, node) {
      String hex = node["color"] ?? GitHubColour.defaultColourHex;
      hex = "FF${hex.substring(1).toUpperCase()}";

      return MapEntry(language, Color(int.parse(hex, radix: 16)));
    });

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
  ///
  /// If [offlineLastResort] enabled, it loads package's `colors.json` for
  /// getting colour data offline. And it must be called after
  /// [WidgetsFlutterBinding.ensureInitialized] invoked in `main()` method to
  /// allow get offline colour data from [rootBundle].
  ///
  /// When all resources failed, it throws
  /// [GitHubColourNoAvailableResourceError]. If [offlineLastResort] disabled,
  /// either [GitHubColourHTTPLoadFailedError] (if network available) or
  /// [SocketException] (without network access) throws.
  ///
  /// [offlineLastResort] only works when [getInstance] invoked first time
  /// in entire runtime. This parameter will be ignored once the instance
  /// constructed.
  static Future<GitHubColour> getInstance(
      {bool offlineLastResort = true}) async {
    if (_instance == null) {
      final Uri ghc = Uri.parse(_src);
      Map<String, Color> ghjson;

      bool cacheSource = false;

      try {
        var resp = await http.get(ghc);
        if (resp.statusCode != 200) {
          throw GitHubColourHTTPLoadFailedError._(resp.statusCode);
        }
        ghjson = _colourReader(resp.body);
      } catch (neterr) {
        try {
          ghjson = await getCache();
          cacheSource = true;
        } catch (cerr) {
          if (!offlineLastResort) {
            // When offline last resort disabled.
            throw neterr;
          }

          try {
            // Use provided JSON file as last resort.
            ghjson = _colourReader(await rootBundle.loadString(
                "packages/github_colour/colors.json",
                cache: false));
          } catch (bundleerr) {
            throw GitHubColourNoAvailableResourceError._();
          }
        }
      }

      if (!cacheSource) {
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

  /// Find [Color] for the [language] (case sensitive).
  ///
  /// If [language] is undefined or defined with `null`, it calls [onUndefined]
  /// for getting fallback [Color]. By default, it throws
  /// [UndefinedLanguageColourError].
  Color find(String language, {LanguageUndefinedHandler? onUndefined}) =>
      _githubLangColour[language] ??
      (onUndefined ??
          () {
            throw UndefinedLanguageColourError._(language);
          })();

  /// Check does the [language] existed.
  bool contains(String language) => _githubLangColour.containsKey(language);

  /// Export all recorded of [GitHubColour] data to [ColorSwatch] with [String]
  /// as index.
  ///
  /// By default, [includeDefault] set as `false`. If `true`, the [ColorSwatch]
  /// will appended `__default__` index for repersenting [defaultColour] which
  /// also is [ColorSwatch]'s default colour.
  ///
  /// If [overridePrimaryColour] applied and [find] existed [Color], it applied
  /// as [ColorSwatch]'s primary colour instead of [defaultColour].
  ColorSwatch<String> toSwatch(
      {bool includeDefault = false, String? overridePrimaryColour}) {
    Map<String, Color> modGLC = Map.from(_githubLangColour);

    if (includeDefault) {
      modGLC["__default__"] = defaultColour;
    }

    return ColorSwatch(
        find(overridePrimaryColour ?? "_", onUndefined: () => defaultColour)
            .value,
        modGLC);
  }

  /// Get a [Set] of [String] that contains all recorded langauages name.
  Set<String> get listedLanguage => Set.unmodifiable(_githubLangColour.keys);
}

/// Alias type for repersenting "colour" in American English which does exactly
/// same with [GitHubColour].
typedef GitHubColor = GitHubColour;
