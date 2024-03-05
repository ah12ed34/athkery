import 'package:athkery/databases/db.dart';
import 'package:athkery/models/category.dart';

class Thaker {
  int? id;
  final String thaker;
  int count;
  final int size;
  List<Category> category;

  incrmet() {
    count++;
  }

  rest() {
    count = 0;
  }

  Map<String, dynamic> toMap() {
    return {
      DatabaseHelper.columnZakr: thaker,
      DatabaseHelper.columnCounter: size,
    };
  }

  Thaker(
      {this.id,
      required this.thaker,
      required this.size,
      this.count = 0,
      required this.category});
}

// final List<Thaker> datas = [
//   Thaker(
//       thaker:
//           "لا إله إلا الله وحده لا شريك له، لهُ الملك ولهُ الحمد يحيي ويميت وهو على كل شيء قدير",
//       size: 100),
//   Thaker(thaker: "سبحان الله", size: 33),
//   Thaker(thaker: "الحمد لله", size: 33),
//   Thaker(thaker: "الله و اكبر", size: 44),
// ];
