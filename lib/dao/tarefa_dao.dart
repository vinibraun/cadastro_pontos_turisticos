
import 'package:gerenciador_tarefas_md/database/database_provider.dart';
import 'package:gerenciador_tarefas_md/model/tarefa.dart';
import 'package:sqflite/sqflite.dart';

class TarefaDao{

  final dbProvider = DatabaseProvider.instance;

  Future<bool> salvar (Tarefa tarefa) async{
    final db = await dbProvider.database;
    final valores = tarefa.toMap();
    if(tarefa.id == null){
      tarefa.id = await db.insert(Tarefa.NAME_TABLE, valores);
      return true;
    }else{
      final registrosAtualizados = await db.update(Tarefa.NAME_TABLE, valores,
      where: '${Tarefa.CAMPO_ID} = ?', whereArgs: [tarefa.id]);
      return registrosAtualizados > 0;
    }
  }

  Future<bool> remover (int id) async {
    final db = await dbProvider.database;
    final registrosAtualizados = await db.delete(Tarefa.NAME_TABLE,
    where: '${Tarefa.CAMPO_ID} = ?', whereArgs: [id]);
    return registrosAtualizados > 0;
  }

  Future<List<Tarefa>> listar() async{
    final db = await dbProvider.database;
    final resultado = await db.query(Tarefa.NAME_TABLE,
    columns: [Tarefa.CAMPO_ID, Tarefa.CAMPO_DESCRICAO, Tarefa.CAMPO_PRAZO]);
    return resultado.map((m) => Tarefa.fromMap(m)).toList();
  }

}