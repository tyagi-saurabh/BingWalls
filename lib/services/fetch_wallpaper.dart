import 'dart:convert';
import 'package:devicelocale/devicelocale.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';

class WallPaper {
  String url;
  String title;
  String copyright;

  Future<void> getWallData() async {
    String currentLocale;
    currentLocale = await Devicelocale.currentLocale;
    final completeAddress = partAddress + currentLocale.toString();

    http.Response response = await http.get(Uri.encodeFull(completeAddress),
        headers: {"Accept": "application/json"});
    url =
        'http://www.bing.com' + json.decode(response.body)['images'][0]['url'];
    title = json.decode(response.body)['images'][0]['title'];
    copyright = json.decode(response.body)['images'][0]['copyright'];
  }
}
