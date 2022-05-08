import '../exception.dart';

/// An [Error] when detected the cache file has been modified when getting
/// online resource failed.
class GitHubColourCacheChecksumMismatchedError extends AssertionError
    implements GitHubColourLoadFailedError {
  /// Construct an [Error] for checksum mismatched.
  GitHubColourCacheChecksumMismatchedError()
      : super("The cache file has unexpected modifications.");
}
