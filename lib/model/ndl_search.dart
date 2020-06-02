import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:zuki_catalog/utils.dart';

class NdlSearch {
  static Future<Map<String, String>> getRecord(String isbn) async {
    if (!Utils.isIsbn(isbn)) {
      return null;
    }

    final client = http.Client();
    final ndl_uri = 'https://iss.ndl.go.jp/api/sru?operation=searchRetrieve&query=isbn=$isbn&recordSchema=dcndl_simple&recordPacking=string&dpid=iss-ndl-opac';

    try {
      final xml = await client.read(ndl_uri).timeout(
          const Duration(seconds: 15),
          onTimeout: () => throw TimeoutException('$isbn: タイムアウト'));

      final exp = RegExp(
          r'<dc:identifier xsi:type="dcterms:URI">(.*?)</dc:identifier>');
      List<String> matches = [];

      for (String line in xml.split('\n')) {
        final match = exp.firstMatch(line)?.group(1);
        if (match != null) {
          matches.add(match);
        }
      }

      var rec;
      for (String url in matches) {
        var res = await client.read('${url}.json').timeout(
            const Duration(seconds: 15),
            onTimeout: () => throw TimeoutException('${url}.json: タイムアウト'));
        rec = jsonDecode(res);
        if (rec['identifier']['JPNO'] != null) break;
      }

      Map<String, String> result = null;
      if (rec != null) {
        final title = rec['title'][0]['value'] ?? '';
        final auth = rec['dc_creator'][0]['name'] ?? '';
        final tr = (auth.length > 0) ? '$title / $auth' : title;
        final pub = rec['publisher'][0]['name'] ?? '';
        final year = rec['date'][0] ?? '';
        final pubyr =
            pub + ((pub.length > 0 && year.length > 0) ? ', $year' : year);
        final marcno = (rec['identifier']['JPNO'] != null)
          ? 'JP${rec['identifier']['JPNO'][0]}' : '';

        result = {
          'marcno': marcno,
          'title': tr,
          'pub': pubyr,
          'isbn': rec['identifier']['ISBN'][0].replaceAll('-', '') ?? '',
        };
      }
      return result;
    } finally {
      client.close();
    }
  }
}
