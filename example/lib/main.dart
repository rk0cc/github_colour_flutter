/*
  This source code is used for demo page.

  Please do not publish this example to pub.dev.
*/

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:github_colour/github_colour.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

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
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => MaterialApp(
      title: 'GitHub Language colour',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: false, textTheme: GoogleFonts.robotoTextTheme()),
      home: const GitHubColourDemo());
}

class GitHubColourDemo extends StatefulWidget {
  const GitHubColourDemo({Key? key}) : super(key: key);

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

  Color get _githubColourState => GitHubColour.getExistedInstance()[_lang];

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
          // Change app bar background colour when enter the language.
          backgroundColor: GitHubColour.getExistedInstance()[_lang],
          title: const Text("GitHub colour")),
      drawer: Drawer(
          child: ListView(children: <Widget>[
        DrawerHeader(
            decoration:
                BoxDecoration(color: _githubColourState.withOpacity(0.5)),
            child: SizedBox.expand(
                child: Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back))))),
        ListTile(
            leading: const Icon(Icons.money),
            title: const Text("Sponsor"),
            onTap: () async {
              final Uri ghs = Uri.parse("https://github.com/sponsors/rk0cc");
              if (await canLaunchUrl(ghs)) {
                launchUrl(ghs);
              }
            }),
        ListTile(
            leading: const Icon(FontAwesomeIcons.github),
            title: const Text("View source code in GitHub"),
            onTap: () async {
              final Uri src =
                  Uri.parse("https://github.com/rk0cc/github_colour_flutter");
              if (await canLaunchUrl(src)) {
                launchUrl(src);
              }
            })
      ])),
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
