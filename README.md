# zuki_catalog

Flutterで作成したオフライン目録検索。バーコードスキャンによるISBN検索とタイトルの中間一致検索が可能。

## 実装

1. データベース検索には`sqflite`を使用。
2. バーコードスキャンには`barcode_scan`を使用。
3. v1.0は逐次検索、v1.1は検索キー入力で検索, v1.2で1画面にして再度逐次検索。

## 参考サイト

- [Building a Cupertino app with Flutter](https://codelabs.developers.google.com/codelabs/flutter-cupertino/index.html)

    iOS UI(Cupertino Library)アプリを作成するためのコードを借用。

- [Open an asset database](https://github.com/tekartik/sqflite/blob/master/sqflite/doc/opening_asset_db.md)

    既存のSQLite3データベースを使用するためのコードを借用。

- [Using Sqflite in Flutter Application](https://medium.com/pharos-production/using-sqflite-in-flutter-application-bc21bf446154)

    データベースをシングルトンで使用するためのコードを借用。

## iOSアプリのサイズ

このソースを普通に`flutter run --release`で作成したアプリは200MB超えのバカでかいサイズとなった。これは[バグではない](https://github.com/flutter/flutter/issues/47101#issuecomment-567522077)そうで、[次のようにする](https://github.com/flutter/flutter/issues/49855)と半分以下(108.4MB)になった。もっとも、それでもまだまだ大きい。同等機能のネイティブアプリのサイズは28.8MBで3倍強である。まだ方法はありそう。

```bash
$ flutter build ios --profile
$ flutter install
```

以下の難読化とシンボルの書き出しを行ったが、サイズは102.8MBとあまり小さくならなかった。

```bash
$ flutter build ios --profile --obfuscate --split-debug-info=./info
```


