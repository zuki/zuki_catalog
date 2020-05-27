import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'catalog_search_page.dart';

class CupertinoCatalogApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]
    );

    return CupertinoApp(
      home: CatalogSearchPage(),
    );
  }
}
