# Apply GitHub's languages colours into Flutter's `Color` object.

![Pub Version](https://img.shields.io/pub/v/github_colour?style=flat-square)
[![GitHub Sponsors](https://img.shields.io/github/sponsors/rk0cc?style=flat-square)](https://github.com/sponsors/rk0cc)

Receiving [ozh's github-colors](https://github.com/ozh/github-colors) repository with latest commit of [`colors.json`](https://github.com/ozh/github-colors/blob/master/colors.json) to Flutter's `Color` object.

It also provide [web demo](https://osp.rk0cc.xyz/github_colour_flutter/) for the demo.

## Usage

You can either initalized `GitHubColour` before `runApp(Widget)` (Call it after `WidgetsFlutterBinding.ensureInitialized()` if want to get data from offline):

```dart
// With offline last resort
void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    await GitHubColour.initialize();
    runApp(const YourApp());
}

// Without offline last resort
void main() async {
    await GitHubColour.initialize(offlineLastResort: false);
    runApp(const YourApp());
}
```

then uses `getExistedInstance()` inside the `Widget`:

```dart
class YourAppWidget extends StatelessWidget {
    @override
    Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
            backgroundColor: GitHubColour.getExistedInstance()["Go"]
        )
    );
}
```

## Cache for connection failed

This package supported caching system as a backup when making request failed. It uses LZMA compress data and store as a file under temporary directory (for VM) or store under `sembast_web` (based on IndexedDB, `3.1.0` or before was using `shared_preference`).

If no cache available, when executing `GitHubColour.initialize()`, it will uses [local's `colors.json`](lib/colors.json) as last resort. However, this package will not synchronized when newer commit of `color.json` pushed since it minified that ensure the package can be downloaded as fast as possible.

## Note for American English developers

It's provide alias class `GitHubColor` for who uses "color" mostly.

## Screenshots

![C++](https://i.imgur.com/6qOSnXq.png)
![Dart](https://i.imgur.com/uSiOYUF.png)

![Go](https://i.imgur.com/Ksf3x3o.png)
![Java](https://i.imgur.com/6Ho6RyT.png)

![Python](https://i.imgur.com/yaTEp1i.png)

## License

BSD-3
