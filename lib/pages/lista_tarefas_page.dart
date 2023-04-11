import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gerenciador_tarefas_md/pages/filtro_page.dart';

import '../dao/tarefa_dao.dart';
import '../model/tarefa.dart';
import '../widgets/conteudo_form_dialog.dart';
import 'detalhes_tarefa_page.dart';

class ListaTarefasPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ListaTarefasPageState();
}

class _ListaTarefasPageState extends State<ListaTarefasPage> {
  static const acaoEditar = 'editar';
  static const acaoExcluir = 'excluir';
  static const acaoVisualizar = 'visualizar';

  final _tarefas = <Tarefa>[
    Tarefa(id: 1,
    descricao: 'Fazer atividades da aula',
    prazo: DateTime.now().add(Duration(days: 5)),
     )
  ];
  final _dao = TarefaDao();

 // @override
 // void initState() {
 //   super.initState();
 //   _atualizarLista();
 // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _criarAppBar(),
      body: _criarBody(),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Nova Tarefa',
        child: Icon(Icons.add),
        onPressed: _abrirForm,
      ),
    );
  }

  AppBar _criarAppBar() {
    return AppBar(
      title: Text('Tarefas'),
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
    if (_tarefas.isEmpty) {
      return Center(
        child: Text(
          'Nenhuma tarefa cadastrada',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
      );
    }
    return ListView.separated(
      itemCount: _tarefas.length,
      itemBuilder: (BuildContext context, int index) {
        final tarefa = _tarefas[index];
        return PopupMenuButton<String>(
          child: ListTile(
            title: Text(
              '${tarefa.id} - ${tarefa.descricao}'),
            subtitle: Text(tarefa.prazoFormatado)
          ),
          itemBuilder: (_) => _criarItensMenuPopup(),
          onSelected: (String valorSelecionado) {
            if (valorSelecionado == acaoEditar) {
              _abrirForm(tarefa: tarefa);
            } else if (valorSelecionado == acaoExcluir) {
              _excluir(tarefa);
            } else {
              _abrirPaginaDetalhesTarefa(tarefa);
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
  ];

  void _abrirForm({Tarefa? tarefa}) {
    final key = GlobalKey<ConteudoFormDialogState>();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          tarefa == null ? 'Nova Tarefa' : 'Alterar Tarefa ${tarefa.id}',
        ),
        content: ConteudoFormDialog(
          key: key,
          tarefaAtual: tarefa,
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
              final novaTarefa = key.currentState!.novaTarefa;
              _dao.salvar(novaTarefa).then((success) {
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

  void _excluir(Tarefa tarefa) {
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
              if (tarefa.id == null) {
                return;
              }
              _dao.remover(tarefa.id!).then((success) {
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

  void _abrirPaginaDetalhesTarefa(Tarefa tarefa) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DetalhePage(
            tarefa: tarefa,
          ),
        ));
  }

  void _atualizarLista() async {

    final tarefas = await _dao.listar();
    setState(() {
      _tarefas.clear();
      if (tarefas.isNotEmpty) {
        _tarefas.addAll(tarefas);
      }
    });
  }
}
