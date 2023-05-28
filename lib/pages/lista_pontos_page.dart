import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../dao/ponto_dao.dart';
import '../model/ponto.dart';
import '../widgets/conteudo_form_dialog.dart';
import 'detalhes_ponto_page.dart';
import 'filtro_page.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math';

class ListaPontosPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ListaPontosPageState();
}

class _ListaPontosPageState extends State<ListaPontosPage> {
  static const acaoEditar = 'editar';
  static const acaoExcluir = 'excluir';
  static const acaoVisualizar = 'visualizar';
  static const acaoCalcular = 'calcular';

  final _pontos = <Ponto>[];
  final _dao = PontoDao();
  var _carregando = false;

  //var _ultimoId = 1;

 @override
 void initState() {
  super.initState();
  _atualizarLista();
 }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _criarAppBar(),
      body: _criarBody(),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Nova Ponto',
        child: Icon(Icons.add),
        onPressed: _abrirForm,
      ),
    );
  }

  AppBar _criarAppBar() {
    return AppBar(
      title: Text('Pontos'),
      actions: [
        IconButton(
          icon: Icon(Icons.filter_list),
          tooltip: 'Filtro e Ordenação',
          onPressed: _abrirPaginaFiltro,
        ),
      ],
    );
  }

  Widget _criarBody() {
    if(_carregando){
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Align(
            alignment: AlignmentDirectional.center,
            child: CircularProgressIndicator(),
          ),
          Align(
            alignment: AlignmentDirectional.center,
            child: Padding(
              padding: EdgeInsets.only(top: 10),
              child: Text('Carregando suas pontos',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          )
        ],
      );
    }

    if (_pontos.isEmpty) {
      return Center(
        child: Text(
          'Nenhum ponto cadastrado',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
      );
    }
    return ListView.separated(
      itemCount: _pontos.length,
      itemBuilder: (BuildContext context, int index) {
        final ponto = _pontos[index];
        return PopupMenuButton<String>(
          child: ListTile(
            title: Text(
              '${ponto.id} - ${ponto.descricao}',
            ),subtitle: Text('${ponto.diferenciais}'),
              trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                  Text(ponto.dataFormatado)
            ]),
          ),
          itemBuilder: (_) => _criarItensMenuPopup(),
          onSelected: (String valorSelecionado) {
            if (valorSelecionado == acaoEditar) {
              _abrirForm(ponto: ponto);
            } else if (valorSelecionado == acaoExcluir) {
              _excluir(ponto);
            } else if (valorSelecionado == acaoCalcular) {
              _calcularDistancia(ponto);
            } else {
              _abrirPaginaDetalhesPonto(ponto);
            }
          },
        );
      },
      separatorBuilder: (_, __) => Divider(),
    );
  }

  List<PopupMenuEntry<String>> _criarItensMenuPopup() => [
    PopupMenuItem(
      value: acaoEditar,
      child: Row(
        children: const [
          Icon(Icons.edit, color: Colors.black),
          Padding(
            padding: EdgeInsets.only(left: 10),
            child: Text('Editar'),
          ),
        ],
      ),
    ),
    PopupMenuItem(
      value: acaoExcluir,
      child: Row(
        children: const [
          Icon(Icons.delete, color: Colors.red),
          Padding(
            padding: EdgeInsets.only(left: 10),
            child: Text('Excluir'),
          ),
        ],
      ),
    ),
    PopupMenuItem(
      value: acaoVisualizar,
      child: Row(
        children: const [
          Icon(Icons.info, color: Colors.blue),
          Padding(
            padding: EdgeInsets.only(left: 10),
            child: Text('Visualizar'),
          ),
        ],
      ),
    ),
    PopupMenuItem(
      value: acaoCalcular,
      child: Row(
        children: const [
          Icon(Icons.directions, color: Colors.green),
          Padding(
            padding: EdgeInsets.only(left: 10),
            child: Text('Calcular Distância'),
          ),
        ],
      ),
    ),
  ];

  void _abrirForm({Ponto? ponto}) {
    final key = GlobalKey<ConteudoFormDialogState>();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          ponto == null ? 'Novo Ponto' : 'Alterar Ponto ${ponto.id}',
        ),
        content: ConteudoFormDialog(
          key: key,
          pontoAtual: ponto,
        ),
        actions: [
          TextButton(
            child: Text('Cancelar'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text('Salvar'),
            onPressed: () {
              if (key.currentState?.dadosValidados() != true) {
                return;
              }
              Navigator.of(context).pop();
              final novoPonto = key.currentState!.novoPonto;
              _dao.salvar(novoPonto).then((success) {
                if (success) {
                  _atualizarLista();
                }
              });
              },
          ),
        ],
      ),
    );
  }

  double calcularDistancia(double latitude1, double longitude1, double latitude2, double longitude2) {
    const int raioTerra = 6371; // Raio médio da Terra em quilômetros
    double lat1Radians = degreesToRadians(latitude1);
    double lon1Radians = degreesToRadians(longitude1);
    double lat2Radians = degreesToRadians(latitude2);
    double lon2Radians = degreesToRadians(longitude2);

    double deltaLat = lat2Radians - lat1Radians;
    double deltaLon = lon2Radians - lon1Radians;

    double a = sin(deltaLat / 2) * sin(deltaLat / 2) +
        cos(lat1Radians) * cos(lat2Radians) * sin(deltaLon / 2) * sin(deltaLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    double distancia = raioTerra * c;
    return distancia;
  }

  void _calcularDistancia(Ponto ponto) async {
    // Obtenha a localização atual do dispositivo
    Position position = await Geolocator.getCurrentPosition();

    // Calcule a distância entre a localização atual e o ponto turístico
    double distancia = calcularDistancia(
      position.latitude,
      position.longitude,
      ponto.latitude,
      ponto.longitude,
    );

    // Exiba o resultado em um aviso na tela
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Distância'),
        content: Text('Distância até o ponto turístico: $distancia km'),
        actions: [
          TextButton(
            child: Text('Fechar'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  double degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

  void _excluir(Ponto ponto) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning),
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text('Atenção'),
            ),
          ],
        ),
        content: Text('Esse registro será removido definitivamente.'),
        actions: [
          TextButton(
            child: Text('Cancelar'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.pop(context);
              if (ponto.id == null) {
                return;
              }
              _dao.remover(ponto.id!).then((success) {
                if (success) {
                  _atualizarLista();
                }
              });
            },
          ),
        ],
      ),
    );
  }

  void _abrirPaginaFiltro() async {
    final navigator = Navigator.of(context);
    final alterouValores = await navigator.pushNamed(FiltroPage.routeName);
    if (alterouValores == true) {
      _atualizarLista();
    }
  }

  void _abrirPaginaDetalhesPonto(Ponto ponto) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DetalhePage(
            ponto: ponto,
          ),
        ));
  }

  void _atualizarLista() async {
    setState(() {
      _carregando = true;
    });
    final prefs = await SharedPreferences.getInstance();
    final campoOrdenacao = Ponto.campoId;
    final usarOrdemDecrescente = prefs.getBool(FiltroPage.chaveUsarOrdemDecrescente) == true;
    final filtroDescricao = prefs.getString(FiltroPage.chaveCampoDescricao) ?? '';

    final pontos = await _dao.listar(
      filtrocontent: filtroDescricao,
      campoOrdenacao: campoOrdenacao,
      usarOrdemDecrescente: usarOrdemDecrescente,
    );
    setState(() {
      _pontos.clear();
      if (pontos.isNotEmpty) {
        _pontos.addAll(pontos);
      }
      _carregando = false;
    });
  }
}
