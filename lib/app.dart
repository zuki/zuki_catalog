import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'catalog_search_page.dart';
import 'styles.dart';

class CupertinoCatalogApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]
    );

    return CupertinoApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: Styles.scaffoldBackground,
      navigationBar: CupertinoNavigationBar(
        middle: const Text('鈴木家蔵書目録'),
      ),
      child: CatalogSearchPage(),
    );
  }
}
