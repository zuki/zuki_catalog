import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'styles.dart';

class CatalogAdminPage extends StatelessWidget {
  CatalogAdminPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Styles.scaffoldBackground,
      navigationBar: const CupertinoNavigationBar(
        middle: const Text('鈴木家蔵書目録'),
      ),
      child: const DecoratedBox(
        decoration: const BoxDecoration(
          color: Styles.scaffoldBackground,
        ),
        child: const SafeArea(
          child: const Center(
            child: const Text('管理ページ'),
          ),
        ),
      ),
    );
  }
}