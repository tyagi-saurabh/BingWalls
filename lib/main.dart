import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import './body.dart';
import 'package:wallpaperplugin/wallpaperplugin.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:devicelocale/devicelocale.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'dart:convert';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: Colors.black));
  runApp(
    MaterialApp(
      home: BingWalls(),
      builder: (context, widget) => ResponsiveWrapper.builder(
          BouncingScrollWrapper.builder(context, widget),
          maxWidth: 2340,
          minWidth: 480,
          defaultScale: true,
          breakpoints: [
            ResponsiveBreakpoint.autoScale(480, name: MOBILE),
            ResponsiveBreakpoint.autoScale(800, name: TABLET),
            ResponsiveBreakpoint.autoScale(1000, name: DESKTOP),
          ],
          background: Container(color: Color(0xFFF5F5F5))),
      initialRoute: "/",
    ),
  );
}

class BingWalls extends StatefulWidget {
  @override
  _BingWallsState createState() => _BingWallsState();
}

class _BingWallsState extends State<BingWalls> {
  String _localfile;
  static const String partAddress =
      "https://www.bing.com/HPImageArchive.aspx?format=js&idx=0&n=1&mkt=";
  String completeAddress;
  String url;
  String title;
  String copyright;

  Future<String> getWallData() async {
    String currentLocale;
    currentLocale = await Devicelocale.currentLocale;
    final completeAddress = partAddress + currentLocale.toString();

    http.Response response = await http.get(Uri.encodeFull(completeAddress),
        headers: {"Accept": "application/json"});
    this.setState(() {
      url = 'http://www.bing.com' +
          json.decode(response.body)['images'][0]['url'];
      title = json.decode(response.body)['images'][0]['title'];
      copyright = json.decode(response.body)['images'][0]['copyright'];
    });
    return url;
  }

  static Future<bool> _checkAndGetPermission() async {
    final PermissionStatus permission = await Permission.storage.status;
    if (permission != PermissionStatus.granted) {
      final Map<Permission, PermissionStatus> permissions =
          await [Permission.storage].request();
      if (permissions[Permission.storage] != PermissionStatus.granted) {
        return null;
      }
    }
    return true;
  }

  @override
  void initState() {
    super.initState();
    getWallData();
    SystemChrome.setEnabledSystemUIOverlays([]);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        floatingActionButton: SpeedDial(
          animatedIcon: AnimatedIcons.menu_close,
          animatedIconTheme: IconThemeData(size: 30.0),
          // this is ignored if animatedIcon is non null
          // child: Icon(Icons.add),
          curve: Curves.bounceIn,
          overlayColor: Colors.black,
          overlayOpacity: 0.5,
          tooltip: 'Options',
          heroTag: 'options-hero-tag',
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 8.0,
          shape: CircleBorder(),
          children: [
            SpeedDialChild(
              child: Icon(
                Icons.wallpaper,
                size: 30.0,
              ),
              backgroundColor: Colors.red,
              label: 'Apply Wallpaper',
              onTap: () async {
                if (await _checkAndGetPermission() != null) {
                  Dio dio = Dio();
                  final Directory appdirectory =
                      await getExternalStorageDirectory();
                  final Directory directory =
                      await Directory(appdirectory.path + '/wallpapers')
                          .create(recursive: true);
                  final String dir = directory.path;
                  final String localfile = '$dir/' + '$title.jpeg';
                  try {
                    await dio.download(url, localfile);
                    setState(() {
                      _localfile = localfile;
                    });
                    await Wallpaperplugin.setWallpaperWithCrop(
                        localFile: _localfile);
                  } on PlatformException catch (e) {
                    Text('error: $e');
                  }
                }
              },
            ),
            SpeedDialChild(
              child: Icon(
                Icons.share,
                size: 30.0,
              ),
              backgroundColor: Colors.blue,
              label: 'Share Wallpaper',
              onTap: () async {
                try {
                  var request = await HttpClient().getUrl(Uri.parse(url));
                  var response = await request.close();
                  Uint8List bytes =
                      await consolidateHttpClientResponseBytes(response);
                  await Share.file('Shared Via Bing Walls', '$title.jpg', bytes,
                      'image/jpg');
                } catch (e) {
                  Text('error: $e');
                }
              },
            ),
            SpeedDialChild(
              child: Icon(
                Icons.info_outline,
                size: 30.0,
              ),
              backgroundColor: Colors.cyan,
              label: 'Privacy Policy',
              onTap: () async {
                const privacyUrl =
                    'https://github.com/tyagi-saurabh/BingWalls/blob/master/Privacy%20Policy.md';
                if (await canLaunch(privacyUrl)) {
                  await launch(privacyUrl);
                } else {
                  throw 'Could not launch $url';
                }
              },
            )
          ],
        ),
        backgroundColor: Colors.black,
        body: url == null
            ? Center(child: CircularProgressIndicator())
            : Body(url: url, title: title, copyright: copyright),
      ),
    );
  }
}
