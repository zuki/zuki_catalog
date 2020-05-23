# zuki_catalog

Flutterで作成したオフライン目録検索。バーコードスキャンによるISBN検索とタイトルの中間一致検索が可能。

## 実装

1. データベース検索には`sqflite`を使用。
2. バーコードスキャンには`barcode_scan`を使用。
3. v1.0は逐次検索、v1.1は検索キー入力で検索。

## 参考サイト

- [Building a Cupertino app with Flutter](https://codelabs.developers.google.com/codelabs/flutter-cupertino/index.html)

    iOS UI(Cupertino Library)アプリを作成するためのコードを借用。

- [Open an asset database](https://github.com/tekartik/sqflite/blob/master/sqflite/doc/opening_asset_db.md)

    既存のSQLite3データベースを使用するためのコードを借用。

- [Using Sqflite in Flutter Application](https://medium.com/pharos-production/using-sqflite-in-flutter-application-bc21bf446154)

    データベースをシングルトンで使用するためのコードを借用。


