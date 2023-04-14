
import '../database/database_provider.dart';
import '../model/ponto.dart';

class PontoDao {
  final databaseProvider = DatabaseProvider.instance;

  Future<bool> salvar(Ponto ponto) async {
    final database = await databaseProvider.database;
    final valores = ponto.toMap();
    if (ponto.id == null || ponto.id == 0) {
      try {
        ponto.id = await database.insert(Ponto.nomeTabela, valores);
      } catch (e) {
        print(e);
      }

      return true;
    } else {
      final registrosAtualizados = await database.update(
        Ponto.nomeTabela,
        valores,
        where: '${Ponto.campoId} = ?',
        whereArgs: [ponto.id],
      );
      return registrosAtualizados > 0;
    }
  }

  Future<bool> remover(int id) async {
    final database = await databaseProvider.database;
    final registrosAtualizados = await database.delete(
      Ponto.nomeTabela,
      where: '${Ponto.campoId} = ?',
      whereArgs: [id],
    );
    return registrosAtualizados > 0;
  }

  Future<List<Ponto>> listar(
      {String filtrocontent = '',
        String campoOrdenacao = Ponto.campoId,
        bool usarOrdemDecrescente = false}) async {
    String? where;
    if (filtrocontent.isNotEmpty && filtrocontent != "") {
      where =
      "UPPER(${Ponto.campoDescricao}) LIKE '${filtrocontent.toUpperCase()}%'";
    }

    var orderBy = campoOrdenacao;

    if (usarOrdemDecrescente) {
      orderBy += ' DESC';
    }
    final database = await databaseProvider.database;
    final resultado = await database.query(
      'ponto',
      columns: [
        Ponto.campoId,
        Ponto.campoDescricao,
        Ponto.campoDiferenciais,
        Ponto.campoData
      ],
      where: where,
      orderBy: orderBy,
    );
    return resultado.map((m) => Ponto.fromMap(m)).toList();
  }
}
