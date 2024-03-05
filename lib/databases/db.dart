import 'dart:async';

import 'package:athkery/models/thaker.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/category.dart';

class DatabaseHelper {
  final String _databaseName = "athkery";
  final int _databaseVersion = 1;
  static const String tableName = "athkery";
  static const String tableAtkerCategories = "atkerCategories";
  static const String tableCategories = "Categories";
  //--------------------------------------------
  static const String columnId = "Id";
  static const String columnZakr = "Zakr";
  static const String columnCounter = "Counter";
  //--------------------------------------------
  static const String columnCategId = "IdCate";
  static const String columnCategName = "NameCate";
  static List<Category>? categories;
  DatabaseHelper._privateConstructor();
  static final instance = DatabaseHelper._privateConstructor();
  static Database? _database;
  Future<Database> get database async => _database ??= await initDatabase();

  Future<Database> initDatabase() async {
    return await openDatabase(join(await getDatabasesPath(), _databaseName),
        version: _databaseVersion, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
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
    List<Category> categories = [
      Category(title: "يومية"),
      Category(title: "قبل النوم"),
    ];
    for (var element in categories) {
      await insertCategories(element.title);
    }
    List<Category> categoriess = await getCategotries();

    if (categoriess.isNotEmpty && categoriess.length > 0) {
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
        await insertAthakr(element) > 0
            ? print(
                "insert done = ${DatabaseHelper.categories != null ? DatabaseHelper.categories!.length : 0} + ${element.thaker}")
            : print("can't insert");
      }
    }

    // await insertAthakr(element) > 0
    //     ? print("insert done")
    //     : print("can't insert");
  }

  // final List<Thaker> _thakers = [
  //   Thaker(
  //     thaker:
  //         "لا إله إلا الله وحده لا شريك له، لهُ الملك ولهُ الحمد يحيي ويميت وهو على كل شيء قدير",
  //     size: 100,
  //     category: [
  //       Category(title: "يومية"),
  //     ],
  //   ),
  //   Thaker(
  //     thaker: "سبحان الله",
  //     size: 33,
  //     category: [
  //       Category(title: "قبل النوم"),
  //     ],
  //   ),
  //   Thaker(
  //     thaker: "الحمد لله",
  //     size: 33,
  //     category: [
  //       Category(title: "قبل النوم"),
  //     ],
  //   ),
  //   Thaker(
  //     thaker: "الله و اكبر",
  //     size: 34,
  //     category: [
  //       Category(title: "قبل النوم"),
  //     ],
  //   ),
  // ];
  Future<int> insertCategories(String name) async {
    final db = await database;
    // List<Category> map = await getCategotries();
    // if (map.any((element) => element.title == name)) {
    //   return map
    //       .elementAt(map.indexWhere((element) => element.title == name))
    //       .id!;
    // } else {
    DatabaseHelper.categories ??= await getCategotries();
    int id = await db.insert(tableCategories, {columnCategName: name});
    if (DatabaseHelper.categories != null && id > 0) {
      await Future.sync(
          () => DatabaseHelper.categories!.add(Category(title: name, id: id)));
    }
    return id;
    // }
  }

  Future<int> insertAthakr(Thaker thaker) async {
    final db = await database;
    int idThaker = await db.insert(tableName, thaker.toMap());
    for (var category in thaker.category) {
      if (category.id != null) {
        await db.insert(tableAtkerCategories,
            {columnId: idThaker, columnCategId: category.id});
      } else {
        // final id = await insertCategories(category.title);
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
              : await insertCategories(category.title)
        });
      }
    }
    return idThaker;
  }

  Future<List<Category>> getCategotries() async {
    final db = await database;
    final List<Map<String, dynamic>> map = await db.query(tableCategories);
    return List.generate(map.length, (index) {
      return Category(
          id: map[index][columnCategId], title: map[index][columnCategName]);
    });
  }

  Future<List<Category>> getAthakerCategory(int athkerId) async {
    final db = await database;
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

  Future<List<Thaker>> getAthaker() async {
    final db = await database;
    final List<Map> map = await db.query(tableName);

    return Future.wait(List.generate(map.length, (index) async {
      return Thaker(
          id: map[index][columnId],
          thaker: map[index][columnZakr],
          size: map[index][columnCounter],
          category: await getAthakerCategory(map[index][columnId]));
    }));
  }
}
