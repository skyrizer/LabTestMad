import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SQLiteDB {
  static const String _dbName = "bitp3453_bmi";

  Database? _db;

  SQLiteDB._();

  static final SQLiteDB _instance = SQLiteDB._();

  factory SQLiteDB(){
    return _instance;
  }

  Future<Database> get database async {
    if (_db != null) {
      return _db!;
    }
    String path = join(await getDatabasesPath(), _dbName,);
    _db = await openDatabase(path, version: 1, onCreate: (createDb, version) async {
      for (String tableSql in SQLiteDB.tableSQLStrings) {
        await createDb.execute(tableSql);
      }
    },);
    return _db!;
  }

  static List<String> tableSQLStrings =
  [
    '''
          CREATE TABLE IF NOT EXISTS bmi (id INTEGER PRIMARY KEY AUTOINCREMENT,
          username TEXT,
          weight DOUBLE,
          height DOUBLE,
          gender TEXT,
          bmi_status TEXT)
          ''',
  ];

  Future<int> insert(String tableName, Map<String, dynamic> row) async {
    Database db = await _instance.database;
    return await db.insert(tableName, row);
  }

  Future<List<Map<String, dynamic>>> queryAll(String tableName) async {
    Database db = await _instance.database;
    return await db.query(tableName);
  }

  Future<Map<String, dynamic>?> fetchLastRow(String tableName) async {
    Database db = await _instance.database;

    List<Map<String, dynamic>> result = await db.query(
      tableName,
      orderBy: 'id DESC',
      limit: 1,
    );

    return result.isNotEmpty ? result.first : null;
  }

}
