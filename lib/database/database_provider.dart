

import 'package:gerenciador_tarefas_md/model/tarefa.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseProvider{
  static const _dbName = 'cadastro_de_tarefas_md.db';
  static const _dbVersion = 1;

  DatabaseProvider._init();

  static final DatabaseProvider instance = DatabaseProvider._init();

  Database? _database;

  Future<Database> get database async {
    if(_database == null){
      _database = await _initDatabase();
    }
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String dataBasePath = await getDatabasesPath();
    String dbPath = '${dataBasePath}/$_dbName';
    return await openDatabase(
      dbPath,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version )async {
    await db.execute('''
    CREATE TABLE ${Tarefa.NAME_TABLE} (
    ${Tarefa.CAMPO_ID} INTEGER PRIMARY KEY AUTOINCREMENT,
    ${Tarefa.CAMPO_DESCRICAO} TEXT NOT NULL,
    ${Tarefa.CAMPO_PRAZO} TEXT )    
    '''
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async{

  }



}