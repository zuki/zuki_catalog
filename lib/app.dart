import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
      localizationsDelegates: [
        DefaultMaterialLocalizations.delegate,
        DefaultCupertinoLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
      ],
      home: SearchPage(model: CatalogModel()),
      locale: const Locale('ja', 'JP'),
      routes: <String, WidgetBuilder> {
        '/home': (BuildContext context) => SearchPage(model: CatalogModel()),
        '/admin': (BuildContext context) => AdminPage(),
      },
    );
  }
}
