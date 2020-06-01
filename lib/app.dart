import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'model/catalog.dart';
import 'catalog_search_page.dart';
import 'catalog_admin_page.dart';

class CupertinoCatalogApp extends StatelessWidget {
  CupertinoCatalogApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]
    );

    return CupertinoApp(
      home: CatalogSearchPage(model: CatalogModel()),
      routes: <String, WidgetBuilder> {
        '/home': (BuildContext context) => CatalogSearchPage(model: CatalogModel()),
        '/admin': (BuildContext context) => CatalogAdminPage(),
      },
    );
  }
}
