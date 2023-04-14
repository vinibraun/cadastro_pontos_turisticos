

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../model/ponto.dart';

class DetalhePage extends StatefulWidget{
  final Ponto ponto;

  const DetalhePage({Key? key, required this.ponto}) : super(key: key);

  @override
  _DetalhePageState createState() => _DetalhePageState();

}
class _DetalhePageState extends State<DetalhePage>{

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
      title: Text('Detalhes do Ponto ${widget.ponto.id}'),
    ),
      body: _criarBody(),
    );
  }

  Widget _criarBody(){
    return Padding(
        padding: EdgeInsets.all(10),
      child: ListView(
        children: [
          Row(
            children: [
              Campo(descricao: 'Código: '),
              Valor(valor: '${widget.ponto.id}'),
            ],
          ),
          Row(
            children: [
              Campo(descricao: 'Descrição: '),
              Valor(valor: '${widget.ponto.descricao}'),
            ],
          ),
          Row(
            children: [
              Campo(descricao: 'Diferenciais: '),
              Valor(valor: '${widget.ponto.diferenciais}'),
            ],
          ),
          Row(
            children: [
              Campo(descricao: 'Data: '),
              Valor(valor: widget.ponto.data == null ? 'Ponto sem data definida' : '${widget.ponto.dataFormatado}'),
            ],
          ),
        ],
      ),
    );
  }
}

class Campo extends StatelessWidget{
  final String descricao;

  const Campo({Key? key, required this.descricao}) : super(key: key);

  @override
  Widget build(BuildContext context){
    return Expanded(
      flex: 1,
        child: Text(
          descricao,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        )
    );
  }
}

class Valor extends StatelessWidget{
  final String valor;

  const Valor({Key? key, required this.valor}) : super(key: key);

  @override
  Widget build(BuildContext context){
    return Expanded(
        flex: 4,
        child: Text(valor),
    );
  }
}




