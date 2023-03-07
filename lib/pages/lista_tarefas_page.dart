
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ListaTarefaPage extends StatefulWidget{

  @override
  _ListaTarefasPageState createState() => _ListaTarefasPageState();

}

class _ListaTarefasPageState extends State<ListaTarefaPage>{


  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: _criarAppBar(),
      body: null,
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Nova tarefa',
        child: Icon(Icons.add),
      ),


    );
  }

 AppBar _criarAppBar(){
    return AppBar(
      title: const Text('Gerenciador de Tarefas'),
      actions: [
        IconButton(
            onPressed: () {},
            icon: const Icon(Icons.filter_list)),
      ],
    );
 }
}