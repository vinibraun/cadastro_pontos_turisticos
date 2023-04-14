import 'package:flutter/material.dart';
import 'package:gerenciador_tarefas_md/pages/filtro_page.dart';
import 'package:gerenciador_tarefas_md/pages/lista_pontos_page.dart';

void main() {
  runApp(const AppGerenciadorTarefas());
}

class AppGerenciadorTarefas extends StatelessWidget {
  const AppGerenciadorTarefas({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App - Pontos Turísticos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.black,
        primarySwatch: Colors.yellow,
      ),
      home: ListaPontosPage(),
      routes: {
        FiltroPage.routeName: (BuildContext context) => FiltroPage(),
      },
    );
  }
}