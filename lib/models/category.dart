import '../databases/db.dart';

class Category {
  final int? id;
  final String title;
  Category({this.id, required this.title});

  Map<String, dynamic> toMap() {
    return {
      DatabaseHelper.columnCategName: title,
    };
  }
}
