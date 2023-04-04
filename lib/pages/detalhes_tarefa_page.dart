

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../model/tarefa.dart';

class DetalhePage extends StatefulWidget{
  final Tarefa tarefa;

  const DetalhePage({Key? key, required this.tarefa}) : super(key: key);

  @override
  _DetalhePageState createState() => _DetalhePageState();

}
class _DetalhePageState extends State<DetalhePage>{

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
      title: Text('Detalhes da Tarefa ${widget.tarefa.id}'),
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
              Valor(valor: '${widget.tarefa.id}'),
            ],
          ),
          Row(
            children: [
              Campo(descricao: 'Descrição: '),
              Valor(valor: '${widget.tarefa.descricao}'),
            ],
          ),
          Row(
            children: [
              Campo(descricao: 'Prazo: '),
              Valor(valor: '${widget.tarefa.prazoFormatado}'),
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




