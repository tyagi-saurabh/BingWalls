import 'package:flutter/material.dart';

class Body extends StatelessWidget {
  const Body({
    Key key,
    @required this.url,
    @required this.title,
    @required this.copyright,
  }) : super(key: key);

  final String url;
  final String title;
  final String copyright;

  @override
  Widget build(BuildContext context) {
    var titleTextStyle =
        TextStyle(color: Colors.white, fontFamily: 'OpenSans', fontSize: 30.0);
    var copyrightTextStyle =
        TextStyle(color: Colors.white, fontFamily: 'OpenSans', fontSize: 15.0);
    return Stack(
      children: <Widget>[
        Image.network(
          url,
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          fit: BoxFit.cover,
        ),
        Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          color: Colors.transparent,
          child: ExpansionTile(
            trailing: Icon(
              Icons.expand_more,
              color: Colors.white,
              size: 30.0,
            ),
            title: Text(
              title,
              style: titleTextStyle,
            ),
            children: <Widget>[
              Text(
                copyright,
                style: copyrightTextStyle,
              )
            ],
          ),
        ),
      ],
    );
  }
}
