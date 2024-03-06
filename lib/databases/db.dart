import 'dart:async';
import 'package:athkery/models/thaker.dart';
import 'package:sqflite/sqflite.dart';
import '../models/category.dart';

import 'package:path/path.dart';

class DatabaseHelper {
  static const String _databaseName = "athkery";
  static const int _databaseVersion = 1;
  static const String tableName = "athkery";
  static const String tableAtkerCategories = "atkerCategories";
  static const String tableCategories = "Categories";
  static const String columnId = "Id";
  static const String columnZakr = "Zakr";
  static const String columnCounter = "Counter";
  static const String columnCategId = "IdCate";
  static const String columnCategName = "NameCate";

  DatabaseHelper._privateConstructor();
  static final instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  Future<Database> get database async => _database ??= await initDatabase();

  Future<Database> initDatabase() async {
    _database = await openDatabase(
        join(await getDatabasesPath(), _databaseName),
        version: _databaseVersion, onCreate: (db, version) async {
      await _onCreate(db, version);
    });
    return _database!;
  }

  Future<void> _onCreate(Database db, int version) async {
    bool tablesExist = await _checkIfTablesExist(db);
    if (!tablesExist) {
      print('if not exist create tables');
      try {
        var create = await _createTables(db);
        if (create) {
          print('if not exist insert default data');
          await _insertDefaultData(db);
        }
        print('finish if not exist create tables');
      } catch (e) {
        print('Error creating tables: $e');
      }
    }
  }

  Future<bool> _checkIfTablesExist(Database db) async {
    try {
      List<Map<String, dynamic>> tables = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name IN (?, ?, ?)",
          [tableName, tableCategories, tableAtkerCategories]);
      print('tables.length = ${tables.length}');
      print('tables = $tables');
      return tables.length == 3;
    } catch (e) {
      print('error in checkIfTablesExist $e');
      return false;
    }
  }

  Future<bool> _createTables(Database db) async {
    await db.execute('''
            CREATE TABLE $tableName 
            ($columnId INTEGER PRIMARY KEY,
             $columnZakr TEXT not null
             , $columnCounter INTEGER not null)
            ''');
    await db.execute('''
                      create table $tableCategories(
                        $columnCategId integer primary key,
                        $columnCategName Text not null
                      )
                      ''');
    await db.execute('''
                      CREATE TABLE $tableAtkerCategories (
                       $columnId INTEGER,
                       $columnCategId INTEGER,
                       FOREIGN KEY ($columnId) REFERENCES $tableName ($columnId),
                       FOREIGN KEY ($columnCategId) REFERENCES $tableCategories ($columnCategId)
                       )
                      ''');
    return await _checkIfTablesExist(db);
  }

  Future<void> _insertDefaultData(db) async {
    List<Category> categories = [
      Category(title: "يومية"),
      Category(title: "قبل النوم"),
    ];
    for (var element in categories) {
      print('start insert ${element.title}');
      await insertCategories(element.title, db);
      print(
          "insert done = ${DatabaseHelper.categories != null ? DatabaseHelper.categories!.length : 0} + ${element.title}");
    }
    List<Category> categoriess = await getCategotries(db);

    if (categoriess.isNotEmpty) {
      List<Thaker> athker = [
        Thaker(
          thaker:
              "لا إله إلا الله وحده لا شريك له، لهُ الملك ولهُ الحمد يحيي ويميت وهو على كل شيء قدير",
          size: 100,
          category: [
            categoriess[0],
          ],
        ),
        Thaker(
          thaker: "سبحان الله",
          size: 33,
          category: [
            categoriess[1],
          ],
        ),
        Thaker(
          thaker: "الحمد لله",
          size: 33,
          category: [
            categoriess[1],
          ],
        ),
        Thaker(
          thaker: "الله و اكبر",
          size: 34,
          category: [
            categoriess[1],
          ],
        ),
      ];

      for (var element in athker) {
        await insertAthakr(element, db) > 0
            ? print(
                "insert done = ${DatabaseHelper.categories != null ? DatabaseHelper.categories!.length : 0} + ${element.thaker}")
            : print("insert failed");
      }
    }
  }

  static List<Category>? categories;
  Future<int> insertCategories(String name, Database db) async {
    // final db = await database;
    print('start insertCategories $name');
    DatabaseHelper.categories ??= await getCategotries(db);
    int id = await db.insert(tableCategories, {columnCategName: name});
    if (DatabaseHelper.categories != null && id > 0) {
      await Future.sync(
          () => DatabaseHelper.categories!.add(Category(title: name, id: id)));
    }
    print('insertCategories done $name $id');
    return id;
  }

  Future<int> insertAthakr(Thaker thaker, db) async {
    // final db = await database;
    int idThaker = await db.insert(tableName, thaker.toMap());
    for (var category in thaker.category) {
      if (category.id != null) {
        await db.insert(tableAtkerCategories,
            {columnId: idThaker, columnCategId: category.id});
      } else {
        bool b = false;
        if (DatabaseHelper.categories != null) {
          b = await DatabaseHelper.categories!
              .any((element) => element.title == category.title);
        }
        await db.insert(tableAtkerCategories, {
          columnId: idThaker,
          columnCategId: b
              ? await DatabaseHelper.categories!
                  .firstWhere((element) => element.title == category.title)
                  .id
              : await insertCategories(category.title, db)
        });
      }
    }
    return idThaker;
  }

  Future<List<Category>> getCategotries(Database? dbD) async {
    final db = dbD ?? await database;
    final List<Map<String, dynamic>> map = await db.query(tableCategories);
    List<Category> result = List.generate(map.length, (index) {
      return Category(
        id: map[index][columnCategId],
        title: map[index][columnCategName],
      );
    });
    categories = result; // تحديث القائمة categories
    return result;
  }

  Future<List<Category>> getAthakerCategory(int athkerId, db) async {
    // final db = await database;
    final List<Map> map = await db.rawQuery('''
      select $tableCategories.$columnCategId , $tableCategories.$columnCategName
      from $tableAtkerCategories inner join $tableCategories on 
      $tableAtkerCategories.$columnCategId = $tableCategories.$columnCategId
      where $tableAtkerCategories.$columnId = ? 
      ''', [athkerId]);
    return List.generate(
        map.length,
        (index) => Category(
            id: map[index][columnCategId], title: map[index][columnCategName]));
  }

  Future<List<Thaker>> getAthaker(Database? database) async {
    final db = database ?? await this.database;
    final List<Map> map = await db.query(tableName);

    return Future.wait(List.generate(map.length, (index) async {
      return Thaker(
          id: map[index][columnId],
          thaker: map[index][columnZakr],
          size: map[index][columnCounter],
          category: await getAthakerCategory(map[index][columnId], db));
    }));
  }
}
