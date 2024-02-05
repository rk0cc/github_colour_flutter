/// As a Java's `Throwable` roles which uses for implementing [Exception] and
/// [Error] in this package.
abstract interface class GitHubColourThrowable {
  /// Message display in [GitHubColourThrowable].
  ///
  /// This getter as `dynamic` type that to make compatable in built-in
  /// [Error] and [Exception] (e.g. [AssertionError]).
  dynamic get message;
}

/// An [Error] that can not fetch [GitHubColour] data.
abstract class GitHubColourLoadFailedError extends Error
    implements GitHubColourThrowable {
  @override
  final dynamic message;

  /// Constructor when some issue happended during loading GitHub colour data.
  GitHubColourLoadFailedError(
      [this.message =
          "There are some unexpected error when loading resources."]);

  @override
  String toString() => "$message";
}
