/// Receive latest commit of
/// [ozh's github-colors](https://github.com/ozh/github-colors) to Flutter's
/// [Color].
library github_colour;

import 'dart:collection';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart'
    show Color, ColorSwatch, WidgetsFlutterBinding;
import 'package:http/http.dart' as http show get;
import 'package:meta/meta.dart' show sealed;

import 'src/cache/cache.dart';
import 'src/cache/exception.dart';
import 'src/exception.dart';

export 'src/cache/exception.dart';
export 'src/exception.dart';

const String _src =
    "https://raw.githubusercontent.com/ozh/github-colors/master/colors.json";

/// A handler when no language data found in [GitHubColour.find].
typedef LanguageUndefinedHandler = Color Function();

/// An [Error] thrown when response unsuccessfully and no cache can be used.
class GitHubColourHTTPLoadFailedError extends GitHubColourLoadFailedError {
  /// HTTP response code when fetching colour data.
  final int responseCode;

  GitHubColourHTTPLoadFailedError._(this.responseCode)
      : assert(responseCode != 200),
        super();

  @override
  String toString() =>
      "GitHubColourLoadFailedError: Can not receive GitHub language colour from server with HTTP code $responseCode.";
}

/// An [Error] thrown when no resources available to initalize [GitHubColour].
class GitHubColourNoAvailableResourceError extends GitHubColourLoadFailedError {
  GitHubColourNoAvailableResourceError._() : super();

  @override
  String toString() =>
      "GitHubColourNoAvailableResourceError: Unable to read GitHub colour data with all available sources.";
}

/// An [Error] when no colour data of the language.
@Deprecated("This exception will be removed with find()")
class UndefinedLanguageColourError extends ArgumentError
    implements GitHubColourThrowable {
  /// Undefined language name.
  final String undefinedLanguage;

  UndefinedLanguageColourError._(this.undefinedLanguage)
      : super("Unknown language '$undefinedLanguage'",
            "UndefinedLanguageColourError");
}

Color _hex2C(String hex, [String alphaHex = "ff"]) {
  assert(RegExp(r"^#[0-9a-f]{6}$", caseSensitive: false).hasMatch(hex));
  assert(RegExp(r"^[0-9a-f]{2}$", caseSensitive: false).hasMatch(alphaHex));

  return Color(
      int.parse("$alphaHex${hex.substring(1)}".toUpperCase(), radix: 16));
}

Map<String, Color> _colourReader(String json) =>
    (jsonDecode(json) as Map<String, dynamic>).map<String, Color>(
        (language, node) => MapEntry(
            language, _hex2C(node["color"] ?? GitHubColour._defaultColourHex)));

/// A class for getting GitHub language colour.
@sealed
class GitHubColour extends UnmodifiableMapBase<String, Color>
    implements ColorSwatch<String> {
  static GitHubColour? _instance;
  final Map<String, Color> _githubLangColour;

  /// A [String] of hex value when the language is undefined or null.
  static const String _defaultColourHex = "#f0f0f0";

  /// [Color] object of [defaultColourHex].
  static Color get _defaultColour => _hex2C(_defaultColourHex);

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
  /// [Exception] that repersenting no network state (e.g
  /// [SocketException](https://api.dart.dev/stable/dart-io/SocketException-class.html)
  /// in `"dart:io"` package).
  ///
  /// [offlineLastResort] only works when [getInstance] invoked first time
  /// in entire runtime. This parameter will be ignored once the instance
  /// constructed.
  ///
  /// Since `1.2.0`, it added chechsum validation on the cache. When the cache's
  /// checksum does not matched, it throws
  /// [GitHubColourCacheChecksumMismatchedError].
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
          // Second source.
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
        // Do nothing if received data is exact same with source.
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
  @Deprecated("You can uses operator [] now.")
  Color find(String language, {LanguageUndefinedHandler? onUndefined}) =>
      _githubLangColour[language] ??
      (onUndefined ??
          () {
            throw UndefinedLanguageColourError._(language);
          })();

  /// Check does the [language] existed.
  @Deprecated("Please uses containsKey")
  bool contains(String language) => containsKey(language);

  /// **This method do absolutely nothing with parsed paramenters and will
  /// be removed later**
  ///
  /// ~~Export all recorded of [GitHubColour] data to [ColorSwatch] with [String]
  /// as index.~~
  ///
  /// ~~By default, [includeDefault] set as `false`. If `true`, the [ColorSwatch]
  /// will appended `__default__` index for repersenting [defaultColour] which
  /// also is [ColorSwatch]'s default colour.~~
  ///
  /// ~~If [overridePrimaryColour] applied and [find] existed [Color], it applied
  /// as [ColorSwatch]'s primary colour instead of [defaultColour].~~
  @Deprecated(
      "This method will be removed as GitHubColour implemented ColorSwatch")
  ColorSwatch<String> toSwatch(
          {bool includeDefault = false, String? overridePrimaryColour}) =>
      this;

  /// Get a [Set] of [String] that contains all recorded langauages name.
  @Deprecated("This getter is replaced by MapBase's keys.")
  Set<String> get listedLanguage => Set.unmodifiable(keys);

  @override
  Color operator [](Object? key) => _githubLangColour[key] ?? _defaultColour;

  @override
  int get alpha => _defaultColour.red;

  @override
  int get blue => _defaultColour.blue;

  @override
  double computeLuminance() => _defaultColour.computeLuminance();

  @override
  int get green => _defaultColour.green;

  @override
  Iterable<String> get keys => Set.unmodifiable(_githubLangColour.keys);

  @override
  double get opacity => _defaultColour.opacity;

  @override
  int get red => _defaultColour.red;

  @override
  int get value => _defaultColour.value;

  @override
  Color withAlpha(int a) => _defaultColour.withAlpha(a);

  @override
  Color withBlue(int b) => _defaultColour.withBlue(b);

  @override
  Color withGreen(int g) => _defaultColour.withGreen(g);

  @override
  Color withOpacity(double opacity) => _defaultColour.withOpacity(opacity);

  @override
  Color withRed(int r) => _defaultColour.withRed(r);
}

/// Alias type for repersenting "colour" in American English which does exactly
/// same with [GitHubColour].
typedef GitHubColor = GitHubColour;
