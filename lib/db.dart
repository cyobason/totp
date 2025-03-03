import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

Future getDb() async {
  var databasesPath = await getDatabasesPath();
  String path = join(databasesPath, 'totp.db');
  return await openDatabase(path, version: 1,
    onCreate: (Database db, int version) async {
      await db.execute(
          'CREATE TABLE MyAuth (id INTEGER PRIMARY KEY, account TEXT, secretKey TEXT, issuer TEXT)');
    });
}
