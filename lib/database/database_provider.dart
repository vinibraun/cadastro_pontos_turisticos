import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';

import '../model/ponto.dart';

class DatabaseProvider {
  static const _dbName = 'cadastro_pontos.db';
  static const _dbVersion = 1;

  DatabaseProvider._init();
  static final DatabaseProvider instance = DatabaseProvider._init();

  Database? _database;

  Future<Database> get database async => _database ??= await _initDatabase();

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final dbPath = '$databasesPath/$_dbName';
    return await openDatabase(
      dbPath,
      version: _dbVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(''' 
      CREATE TABLE ${Ponto.nomeTabela} (
        ${Ponto.campoId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${Ponto.campoDescricao} TEXT NOT NULL,
        ${Ponto.campoDiferenciais} TEXT NOT NULL,
        ${Ponto.campoData} TEXT
      );
    ''');
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
    }
  }
}
