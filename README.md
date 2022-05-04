# Apply GitHub's languages colours into Flutter's `Color` object.

Receiving [ozh's github-colors](https://github.com/ozh/github-colors) repository with latest commit of [`colors.json`](https://github.com/ozh/github-colors/blob/master/colors.json) to Flutter's `Color` object.

## Usage

You can either initalized `GitHubColour` before `runApp(Widget)`:

```dart
void main() async {
    await GitHubColour.getInstance();
    runApp(const YourApp());
}
```

then uses `getExistedInstance()` inside the `Widget`:

```dart
class YourAppWidget extends StatelessWidget {
    @override
    Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(backgroundColor: GitHubColour.getExistedInstance().find("Go"))
    );
}
```

or wrapped into `FutureBuilder` directly in `State`'s `initState` (not recommended uses `getInstance()` directly in `FutureBuilder`):

```dart
class YourAnotherAppWidget extends State<YourStatefulWidget> {
    late final Future<GitHubColour> _ghc;

    @override
    void initState() {
        super.initState();
        _ghc = GitHubColour.getInstance();
    }

    @override
    Widget build(BuildContext context) => FutureBuilder<GitHubColour>(
        future: _ghc,
        builder: (context, snapshot) {
            // Implement whatever you want
        }
    );
}
```

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
