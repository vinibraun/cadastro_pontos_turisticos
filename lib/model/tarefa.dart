import 'package:intl/intl.dart';

class Tarefa{

  static const CAMPO_ID = 'id';
  static const CAMPO_DESCRICAO = 'descricao';
  static const CAMPO_PRAZO = 'prazo';
  static const NAME_TABLE = 'gerenciador';

  int id;
  String descricao;
  DateTime? prazo;

  Tarefa({required this.id, required this.descricao, this.prazo});

  String get prazoFormatado{
    if (prazo == null){
      return ' ';
    }
    return DateFormat('dd/MM/yyy').format(prazo!);
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
    CAMPO_ID: id,
    CAMPO_DESCRICAO: descricao,
    CAMPO_PRAZO: prazo == null ? null : DateFormat("yyyy-MM-dd").format(prazo!),
  };

  factory Tarefa.fromMap(Map<String, dynamic> map) => Tarefa(
    id: map[CAMPO_ID] is int ? map[CAMPO_ID] : null,
    descricao: map[CAMPO_DESCRICAO] is String ? map[CAMPO_DESCRICAO] : '',
    prazo: map[CAMPO_PRAZO] == null ? null : DateFormat("yyyy-MM-dd").parse(map[CAMPO_PRAZO]),
  );

}