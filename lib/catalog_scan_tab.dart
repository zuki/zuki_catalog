import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'book_row_item.dart';
import 'styles.dart';
import 'model/book.dart';
import 'model/catalog_database.dart';

class CatalogScanTab extends StatefulWidget {
  @override
  _CatalogScanState createState() {
    return _CatalogScanState();
  }
}

class _CatalogScanState extends State<CatalogScanTab> {
  ScanResult scanResult;
 
  Widget _buildScanButton() {
    return Center(
      child: CupertinoButton(
        child: Text('スキャン'),
        onPressed: () {
          barcodeScanning();
        }
      ),
    );
  }

  Future barcodeScanning() async {
    try {
      final options = ScanOptions(
        restrictFormat: [BarcodeFormat.ean13],
      );

      final result = await BarcodeScanner.scan(options: options);
      
      setState(() => scanResult = result);
    } on PlatformException catch (e) {
      var result = ScanResult(
        type: ResultType.Error,
        format: BarcodeFormat.unknown,
      );

      if (e.code == BarcodeScanner.cameraAccessDenied) {
        setState(() {
          result.rawContent = 'The user did not grant the camera permission!';
        });
      } else {
        result.rawContent = 'Unknown error: $e';
      }
      setState(() {
        scanResult = result;
      });
    }
  }

  Widget _buildResults() {
    final model = CatalogDatabase();

    if (scanResult == null) {
      return Text('');
    } else if (scanResult.type == ResultType.Error) {
      return Text(scanResult.rawContent);
    } else if (scanResult.type == ResultType.Barcode) {
      return Expanded(
        child: SizedBox(
          height: 200.0,
          child: FutureBuilder(
            future: model.search(scanResult.rawContent),
            builder:
                (BuildContext context, AsyncSnapshot<List<Book>> snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return CupertinoActivityIndicator();
              }
              if (snapshot.hasError) {
                return Text('エラーが発生しました。');
              }
              if (snapshot.hasData) {
                return ListView.builder(
                  itemBuilder: (context, index) => BookRowItem(
                    index: index,
                    book: snapshot.data[index],
                    lastItem: index == snapshot.data.length - 1,
                  ),
                  itemCount: snapshot.data.length,
                );
              } else {
                return Text('該当図書はありません。');
              }
            },
          ),
        ),
      );
    } else {
      return Text('');
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: Styles.scaffoldBackground,
      navigationBar: CupertinoNavigationBar(
        middle: const Text('鈴木家蔵書目録'),
      ),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: Styles.scaffoldBackground,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildResults(),
              _buildScanButton(),
            ],
          ),
        ),
      ),
    );
  }
}
