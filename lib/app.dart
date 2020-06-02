import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'model/catalog.dart';
import 'search_page.dart';
import 'admin_page.dart';

class CupertinoCatalogApp extends StatelessWidget {
  CupertinoCatalogApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]
    );

    return CupertinoApp(
      home: SearchPage(model: CatalogModel()),
      routes: <String, WidgetBuilder> {
        '/home': (BuildContext context) => SearchPage(model: CatalogModel()),
        '/admin': (BuildContext context) => AdminPage(),
      },
    );
  }
}
