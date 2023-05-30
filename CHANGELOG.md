## 3.0.0

* Dart 3 supported
* Uses `hashlib` to replace `sha3` and `hex`
  * **If encounter hashing mismatch error, please clean cache and launch again.**
* All deprecated API removed
* Update `color.json`
* `getInstance` becomes deprecated and uses `initialize` instead.

## 2.0.0+1

* Fix document

## 2.0.0

* `GitHubColour` implemented with `ColorSwatch` and `UnmodifiableMapBase` now.
  * Serval old API deprecated.
* Required Dart `2.17.0` with Flutter `3.0.0`
* (GitHub) Upload entire example project source code.
* Update last resort `color.json` to [`e358b0a`](https://github.com/ozh/github-colors/commit/e358b0ac8ff6453d8d60b2fbe7b4ec7552dbafce).

## 1.2.6

* Remove implement `Error` in `GitHubColourThrowable`.

## 1.2.5

* Remove `external` in `GitHubColourThrowable`.

## 1.2.4

* Change `GitHubColour`'s default colour from `#8f8f8f` to `#f0f0f0`.

## 1.2.3

* Add generic throwable type `GitHubColourThrowable`
* Exceptions arrangment.

## 1.2.2

* Exceptions arrangment.

## 1.2.1+1

* Remove unused package.

## 1.2.1

* Limit writing cache when the context is difference.

## 1.2.0

* Added SHA 3 checksum validation for cache file.
  * (VM) New directory created with cache file and checksum.
    * The origin cache file no longer be used.
  * (Web) Store checksum in new local storage field.

## 1.1.0+1

* Fix droppped web platform supported issue.
* Better documentation.

## 1.1.0

* Included `colors.json` for last resort if enabled offline as a last resort when 
  create new instance of `GitHubColour`. 
* Allows get all data in `GitHubColour` to `ColorSwatch`.
* Provides `Set` with all availabled languages name.

## 1.0.0

* Change `GitHubColours.find`'s fallback method.
* Add `GitHubColours.contains` for checking does this language is in the list.

## 0.1.0+1

* Expand description length, no additional function implemented in this version.

## 0.1.0

* Added caching support for backup option if making request failed.

## 0.0.1

* Initial release
