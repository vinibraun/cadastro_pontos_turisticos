import 'package:intl/intl.dart';

class Ponto {
  static const nomeTabela = 'ponto';
  static const campoId = '_id';
  static const campoDescricao = 'descricao';
  static const campoDiferenciais = 'diferenciais';
  static const campoData = 'data';

  int? id;
  String descricao;
  String diferenciais;
  DateTime? data;

  Ponto({
    this.id,
    required this.descricao,
    required this.diferenciais,
    this.data,
  });

  String get dataFormatado {
    if (data == null) {
      return '';
    }
    return DateFormat('dd/MM/yyyy').format(data!);
  }

  Map<String, dynamic> toMap() => {
    campoId: id,
    campoDescricao: descricao,
    campoDiferenciais: diferenciais,
    campoData:
    data == null ? null : DateFormat("yyyy-MM-dd").format(data!),
  };

  factory Ponto.fromMap(Map<String, dynamic> map) => Ponto(
    id: map[campoId] is int ? map[campoId] : null,
    descricao: map[campoDescricao] is String ? map[campoDescricao] : '',
    diferenciais: map[campoDiferenciais] is String ? map[campoDiferenciais] : '',
    data: map[campoData] is String
        ? DateFormat("yyyy-MM-dd").parse(map[campoData])
        : null,
  );
}
