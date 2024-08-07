import 'package:flutter/material.dart';
import 'package:github_colour/github_colour.dart';

void main() async {
  // Required if want to uses offline JSON data as last resort.
  WidgetsFlutterBinding.ensureInitialized();
  // Construct an instance for future uses.
  await GitHubColour.initialize();

  // It does not required binding if disabled offline last resort
  /*
    await GitHubColour.initialize(offlineLastResort: false);
   */

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
      title: 'GitHub Language colour',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: false),
      home: const GitHubColourDemo());
}

class GitHubColourDemo extends StatefulWidget {
  const GitHubColourDemo({super.key});

  @override
  State<GitHubColourDemo> createState() => _GitHubColourDemoState();
}

class _GitHubColourDemoState extends State<GitHubColourDemo> {
  late TextEditingController _ctrl;
  late String _lang;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: "Dart");
    _lang = _ctrl.text;
  }

  void _changeColour() {
    setState(() {
      _lang = _ctrl.text;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
          // Change app bar background colour when enter the language.
          backgroundColor: GitHubColour.getExistedInstance()[_lang],
          title: const Text("GitHub colour")),
      body: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
            Container(
                margin: const EdgeInsets.all(12),
                constraints: const BoxConstraints(maxWidth: 350),
                child: TextField(
                    // Enter the language here
                    textInputAction: TextInputAction.go,
                    onSubmitted: (_) {
                      _changeColour();
                    },
                    controller: _ctrl,
                    decoration: const InputDecoration(
                        labelText: "Enter language name here:"),
                    autocorrect: false)),
            const Divider(height: 8, indent: 1.5, thickness: 0.25),
            SizedBox(
                // Submit button
                width: 80,
                height: 35,
                child: ElevatedButton(
                    onPressed: _changeColour, child: const Text("Apply")))
          ])));
}
