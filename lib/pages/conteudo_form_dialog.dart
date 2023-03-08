
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../model/tarefa.dart';

class ConteudoFormDialog extends StatefulWidget{
  final Tarefa? tarefaAtual;

  ConteudoFormDialog({Key? key, this.tarefaAtual}) : super (key: key);


  @override
  _ConteudoFormDialogState createState() => _ConteudoFormDialogState();

}
class _ConteudoFormDialogState extends State<ConteudoFormDialog> {

  final formKey = GlobalKey<FormState>();
  final descricaoController = TextEditingController();
  final prazoController = TextEditingController();
  final _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState(){
    super.initState();
    if (widget.tarefaAtual != null){

    }
  }


  Widget build(BuildContext context){
    return Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: descricaoController,
              decoration: InputDecoration(labelText: 'Descrição'),
              validator: (String? valor){
                if (valor == null || valor.isEmpty){
                  return 'Informe a descrição';
                }
                return null;
              },
            ),
            TextFormField(
              controller: prazoController,
              decoration: InputDecoration(labelText: 'Prazo',
              prefixIcon: IconButton(
                onPressed: _mostrarCalendario,
                icon: Icon(Icons.calendar_today),
              ),
              suffixIcon: IconButton(
                onPressed: () => prazoController.clear(),
                icon: Icon(Icons.close),
              ),
              ),
              readOnly: true,
            ),
          ],
        )
    );

  }

}