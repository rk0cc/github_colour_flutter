import 'dart:collection';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart'
    show Color, ColorSwatch, WidgetsFlutterBinding;
import 'package:http/http.dart' as http show get;

import 'cache/cache.dart';
import 'cache/exception.dart';
import 'exception.dart';

const String _src =
    "https://raw.githubusercontent.com/ozh/github-colors/master/colors.json";

/// An [Error] thrown when response unsuccessfully and no cache can be used.
final class GitHubColourHTTPLoadFailedError
    extends GitHubColourLoadFailedError {
  /// HTTP response code when fetching colour data.
  final int responseCode;

  GitHubColourHTTPLoadFailedError._(this.responseCode)
      : assert(responseCode != 200);

  @override
  String toString() =>
      "GitHubColourLoadFailedError: Can not receive GitHub language colour from server with HTTP code $responseCode.";
}

/// An [Error] thrown when no resources available to initalize [GitHubColour].
final class GitHubColourNoAvailableResourceError
    extends GitHubColourLoadFailedError {
  GitHubColourNoAvailableResourceError._();

  @override
  String toString() =>
      "GitHubColourNoAvailableResourceError: Unable to read GitHub colour data with all available sources.";
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
///
/// Since 2.0.0, [GitHubColour] implemented [ColorSwatch] that getting colour
/// can be more convenience. And serval old API will be [Deprecated].
final class GitHubColour extends UnmodifiableMapBase<String, Color>
    implements ColorSwatch<String> {
  static GitHubColour? _instance;
  final Map<String, Color> _githubLangColour;

  /// A [String] of hex value when the language is undefined or null.
  static const String _defaultColourHex = "#f0f0f0";

  /// [Color] object of [defaultColourHex].
  static Color get _defaultColour => _hex2C(_defaultColourHex);

  GitHubColour._(Map<String, Color> githubLangColour)
      : _githubLangColour = Map.unmodifiable(githubLangColour);

  /// Construct an instance of [GitHubColour].
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
  /// [offlineLastResort] only works when [initialize] invoked first time
  /// in entire runtime. This parameter will be ignored once the instance
  /// constructed.
  ///
  /// Since `1.2.0`, it added chechsum validation on the cache. When the cache's
  /// checksum does not matched, it throws
  /// [GitHubColourCacheChecksumMismatchedError].
  static Future<void> initialize({bool offlineLastResort = true}) async {
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
  }

  /// Perform [initialize] and return [GitHubColour].
  ///
  /// If no instance created, it will construct and will be reused when
  /// [getInstance] or [getExistedInstance] called again.
  ///
  /// This method is deprecated since it may not required to uses [GitHubColour]
  /// once the instance created.
  @Deprecated("Please call void function `initialize()`")
  static Future<GitHubColour> getInstance(
      {bool offlineLastResort = true}) async {
    await initialize(offlineLastResort: offlineLastResort);

    return _instance!;
  }

  /// Get constructed instance which called [initialize] early.
  ///
  /// It throws [UnimplementedError] if called with no existed instance.
  static GitHubColour getExistedInstance() {
    if (_instance == null) {
      throw UnimplementedError("No existed instance found in GitHubColour");
    }

    return _instance!;
  }

  /// Resolve [key] as language and find repersented [Color] from providers.
  ///
  /// If [key] is undefined, it returns default colour instead.
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
