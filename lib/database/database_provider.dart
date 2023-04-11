import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';

import '../model/tarefa.dart';

class DatabaseProvider {
  static const _dbName = 'cadastro_tarefas.db';
  static const _dbVersion = 2;

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
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(''' 
      CREATE TABLE ${Tarefa.nomeTabela} (
        ${Tarefa.campoId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${Tarefa.campoDescricao} TEXT NOT NULL,
        ${Tarefa.campoPrazo} TEXT,
      );
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {

  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
    }
  }
}
