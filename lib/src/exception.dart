/// An [Error] that can not fetch [GitHubColour] data.
abstract class GitHubColourLoadFailedError extends Error {
  final message;

  GitHubColourLoadFailedError(
      [this.message =
          "There are some unexpected error when loading resources."]);

  @override
  String toString() => message;
}
