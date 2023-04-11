import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/tarefa.dart';

class FiltroPage extends StatefulWidget{
  static const routeName = '/filtro';
  static const chaveCampoOrdenacao = 'campoOrdenacao';
  static const chaveUsarOrdemDecrescente = 'usarOrdemDecrescente';
  static const chaveCampoDescricao = 'campoDescricao';

  @override
  _FiltroPageState createState() => _FiltroPageState();

}
class _FiltroPageState extends State<FiltroPage> {

  final _camposParaOrdenacao = {
    Tarefa.campoId: 'Código',
    Tarefa.campoDescricao: 'Descrição',
    Tarefa.campoPrazo: 'Prazo'
  };

  late final SharedPreferences _prefes;
  final _descricaoController = TextEditingController();
  String _campoOrdenacao = Tarefa.campoId;
  bool _usarOrdemDecrescente = false;
  bool _alterouValores = false;

  @override
  void initState(){
    super.initState();
    _carregaDadosSharedPreferences();
  }

  void _carregaDadosSharedPreferences() async {
    _prefes = await SharedPreferences.getInstance();
    setState(() {
      _campoOrdenacao = _prefes.getString(FiltroPage.chaveCampoOrdenacao) ?? Tarefa.campoId;
      _usarOrdemDecrescente = _prefes.getBool(FiltroPage.chaveUsarOrdemDecrescente) == true;
      _descricaoController.text = _prefes.getString(FiltroPage.chaveCampoDescricao) ?? '' ;
    });
  }

  @override
  Widget build(BuildContext context){
    return WillPopScope(
        child: Scaffold(
          appBar: AppBar(title: Text('Filtro e Ordenação'),
          ),
          body: _criarBody(),
        ),
        onWillPop: _onVoltarClick,
    );
  }

  Widget _criarBody() {
    return ListView(
      children: [
        Padding(
            padding: EdgeInsets.only(left: 10, top: 10),
          child: Text('Campos para Ordenação'),
        ),
        for (final campo in _camposParaOrdenacao.keys)
          Row(
            children: [
              Radio(
                  value: campo,
                  groupValue: _campoOrdenacao,
                  onChanged: _onCampoParaOrdenacaoChanged,
              ),
              Text(_camposParaOrdenacao[campo]!),
            ],
          ),
        Divider(),
        Row(
          children: [
            Checkbox(
                value: _usarOrdemDecrescente,
                onChanged: _onUsarOrdemDecrescenteChanged,
            ),
            Text('Usar ordem decrescente'),
          ],
        ),
        Divider(),
        Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
          child: TextField(
            decoration: InputDecoration(
              labelText: 'Descrição começa com:',
            ),
            controller: _descricaoController ,
            onChanged: _onFiltroDescricaoChanged,
          ),
        )
      ],
    );
  }

  void _onCampoParaOrdenacaoChanged(String? valor){
    _prefes.setString(FiltroPage.chaveCampoOrdenacao, valor!);
    _alterouValores = true;
    setState(() {
      _campoOrdenacao = valor;
    });
  }

  void _onUsarOrdemDecrescenteChanged(bool? valor){
    _prefes.setBool(FiltroPage.chaveUsarOrdemDecrescente, valor!);
    _alterouValores = true;
    setState(() {
      _usarOrdemDecrescente = valor;
    });
  }

  void _onFiltroDescricaoChanged(String? valor){
    _prefes.setString(FiltroPage.chaveCampoDescricao, valor!);
    _alterouValores = true;
  }

  Future<bool> _onVoltarClick() async {
    Navigator.of(context).pop(_alterouValores);
    return true;
  }
}

