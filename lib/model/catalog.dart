import 'package:scoped_model/scoped_model.dart';

import 'book.dart';
import 'catalog_database.dart';
import 'package:zuki_catalog/utils.dart';

abstract class CatalogStatus {
}

class CatalogStatusInit extends CatalogStatus {
  CatalogStatusInit() : super();
}
class CatalogStatusLoading extends CatalogStatus {
  CatalogStatusLoading() : super();
}

class CatalogStatusSuccess extends CatalogStatus {
  CatalogStatusSuccess(this.results) : super();

  final List<Book> results;
}

class CatalogStatusFailure extends CatalogStatus {
  CatalogStatusFailure(this.error) : super();

  final Object error;
}

class CatalogStatusNoHit extends CatalogStatus {
  CatalogStatusNoHit() : super();
}

class CatalogModel extends Model {
  CatalogStatus _status = CatalogStatusInit();

  CatalogStatus get status => _status;

  Future<void> search(String term) async {
    final CatalogDatabase db = CatalogDatabase();

    if (_status is CatalogStatusLoading) return;

    _status = CatalogStatusLoading();
    notifyListeners();

    try {
      List<Book> _results;
      if (Utils.isIsbn(term)) {
        _results = await db.searchByIsbn(term);
      } else {
        _results = await db.search(term);
      }
      
      if (_results == null) {
        _status = CatalogStatusNoHit();
      } else {
        _status = CatalogStatusSuccess(_results);
      }
    } catch (e) {
      _status = CatalogStatusFailure(e);
    } finally {
      notifyListeners();
    }
  }

  void clear() {
    _status = CatalogStatusInit();
    notifyListeners();
  }

}