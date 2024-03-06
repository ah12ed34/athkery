import 'package:athkery/databases/db.dart';
import 'package:athkery/models/category.dart';
import 'package:athkery/models/thaker.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  List<Thaker> _thaker = [];
  List<Category> _categories = [];
  List<int> selects = [];
  int? selectZ;
  Future<void> _getdate() async {
    _thaker = [];
    _categories = [];
    selects = [];
    final db = DatabaseHelper.instance;
    _categories = await db.getCategotries(null);
    _thaker = await db.getAthaker(null);

    if (_thaker.isNotEmpty) {
      selectZ ??= 0;
    } else {
      selectZ = null;
    }
    update();
  }

  HomeController() {
    _getdate();
  }
  void setSelect(int i) {
    if (selects.any((element) => element == i)) {
      selects.remove(i);
    } else {
      selects.add(i);
    }
    update();
  }

  bool isSelected(int i) {
    return selects.contains(i);
  }

  void get getDataNew => _getdate();
  List<Thaker> get athker => _thaker;
  List<Category> get categories => _categories;
}
