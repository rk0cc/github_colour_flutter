import 'package:fetch_client/fetch_client.dart';
import 'package:http/http.dart' show Client;
import 'package:meta/meta.dart';

@internal
Client initalizeClient() => FetchClient(mode: RequestMode.cors);
