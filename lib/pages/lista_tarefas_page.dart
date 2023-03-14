
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gerenciador_tarefas_md/model/tarefa.dart';

import '../widgets/conteudo_form_dialog.dart';

class ListaTarefaPage extends StatefulWidget{

  @override
  _ListaTarefasPageState createState() => _ListaTarefasPageState();

}
class _ListaTarefasPageState extends State<ListaTarefaPage>{

  final tarefas = <Tarefa>
   [
     Tarefa(id: 1,
         descricao: 'Fazer atividades da aula',
          prazo: DateTime.now().add(Duration(days: 5)),
     )
  ];

 var _ultimoId = 1;

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: _criarAppBar(),
      body: _criarBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirForm,
        tooltip: 'Nova tarefa',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _abrirForm({Tarefa? tarefaAtual, int? index}){
    final key = GlobalKey<ConteudoFormDialogState>();
    showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            title: Text(tarefaAtual == null ? 'Nova Tarefa' : 'Alterar a tarefa ${tarefaAtual.id}'),
            content: ConteudoFormDialog(key: key, tarefaAtual: tarefaAtual),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  if (key.currentState != null && key.currentState!.dadosValidados()){
                    setState(() {
                      final novaTarefa = key.currentState!.novaTarefa;
                      if(index == null){
                        novaTarefa.id = ++_ultimoId;
                      }else{
                        tarefas[index] = novaTarefa;
                      }
                    });
                    Navigator.of(context).pop();
                  }
                },
                child: Text('Salvar'),
              ),
            ],
          );
        }
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
  Widget _criarBody(){
    if( tarefas.isEmpty){
      return const Center(
        child: Text('Nenhuma tarefa cadastrada',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      );
    }
    return ListView.separated(
        itemCount: tarefas.length,
        itemBuilder: (BuildContext context, int index){
          final tarefa = tarefas[index];
          return ListTile(
            title: Text('${tarefa.id} - ${tarefa.descricao}'),
            subtitle: Text('Prazo - ${tarefa.prazo}'),
          );
        },
        separatorBuilder: (BuildContext context, int index) => Divider(),
        );
  }
}