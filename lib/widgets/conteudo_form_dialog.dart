
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../model/ponto.dart';

class ConteudoFormDialog extends StatefulWidget{
  final Ponto? pontoAtual;

  ConteudoFormDialog({Key? key, this.pontoAtual}) : super (key: key);

  @override
  ConteudoFormDialogState createState() => ConteudoFormDialogState();

}
class ConteudoFormDialogState extends State<ConteudoFormDialog> {

  GoogleMapController? _mapController;

  Position? _localizacaoAtual;

  String get _textoLocalizacao => _localizacaoAtual == null ? '' :
  'Latitude:  ${_localizacaoAtual!.latitude}  |  Logetude:  ${_localizacaoAtual!.longitude}';

  final formKey = GlobalKey<FormState>();
  final descricaoController = TextEditingController();
  final diferenciaisController = TextEditingController();
  final dataController = TextEditingController();
  final _dateFormat = DateFormat('dd/MM/yyyy');
  final latitudeController = TextEditingController();
  final longitudeController = TextEditingController();

  @override
  void initState(){
    super.initState();
    if (widget.pontoAtual != null){
      descricaoController.text = widget.pontoAtual!.descricao;
      diferenciaisController.text = widget.pontoAtual!.diferenciais;
      dataController.text = widget.pontoAtual!.dataFormatado;
      latitudeController.text = widget.pontoAtual!.latitude.toString();
      longitudeController.text = widget.pontoAtual!.longitude.toString();
      _localizacaoAtual = Position(
        latitude: widget.pontoAtual!.latitude,
        longitude: widget.pontoAtual!.longitude,
        altitude: 0.0,
        accuracy: 0.0,
        heading: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
        timestamp: DateTime.now(),
      );

    }
  }


  Widget build(BuildContext context){
    return SingleChildScrollView(
      child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: ElevatedButton(
                  child: Text('Obter a localização atual do dispositivo'),
                  onPressed: _obterLocalizacaoAtual,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    Expanded(
                        child: Text(_textoLocalizacao)
                    ),
                  ],
                ),
              ),
              if (_localizacaoAtual != null)
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        child: Text('Abrir no Mapa do App'),
                        onPressed: _abrirNoMapaDoApp,
                      ),
                    ),
                  ],
                ),
              ElevatedButton(
                onPressed: _abrirMapaExterno,
                child: Icon(Icons.map),
              ),
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
                controller: diferenciaisController,
                decoration: InputDecoration(labelText: 'Diferenciais'),
                validator: (String? valor){
                  if (valor == null || valor.isEmpty){
                    return 'Informe os diferenciais';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: dataController,
                decoration: InputDecoration(labelText: 'Data',
                prefixIcon: IconButton(
                  onPressed: _mostrarCalendario,
                  icon: Icon(Icons.calendar_today),
                ),
                suffixIcon: IconButton(
                  onPressed: () => dataController.clear(),
                  icon: Icon(Icons.close),
                ),
                ),
                readOnly: true,
              ),
              Container(
                height: 200,
                child: GoogleMap(
                  mapType: MapType.normal,
                  initialCameraPosition: CameraPosition(
                    target: _localizacaoAtual != null
                        ? LatLng(_localizacaoAtual!.latitude, _localizacaoAtual!.longitude)
                        : LatLng(0, 0),
                    zoom: 15,
                  ),
                  onMapCreated: (GoogleMapController controller) {
                    _mapController = controller;
                  },
                  markers: Set<Marker>.of(_localizacaoAtual != null
                      ? [
                    Marker(
                      markerId: MarkerId('currentLocation'),
                      position: LatLng(_localizacaoAtual!.latitude, _localizacaoAtual!.longitude),
                    ),
                  ]
                      : []),
                ),
              ),

            ],
          )
      )
    );
  }

  void _abrirMapaExterno(){
    if(_localizacaoAtual == null){
      return;
    }
    MapsLauncher.launchCoordinates(_localizacaoAtual!.latitude, _localizacaoAtual!.longitude);
  }

  void _mostrarCalendario(){
    final data = DateTime.now();
    setState(() {
      dataController.text = _dateFormat.format(data);
    });
  }

  bool dadosValidados() => formKey.currentState?.validate() == true;

  Ponto get novoPonto => Ponto(
      id: widget.pontoAtual?.id ?? null,
      descricao: descricaoController.text,
      diferenciais: diferenciaisController.text,
      data: dataController.text.isEmpty ? null : _dateFormat.parse(dataController.text),
      latitude: _localizacaoAtual!.latitude,
      longitude: _localizacaoAtual!.longitude
  );

  Future<bool> _servicoHabilitado() async {
    bool servicoHabilitado = await Geolocator.isLocationServiceEnabled();
    if (!servicoHabilitado){
      await _mostrarDialogMensagem('Para utilizar esse recurso, você deverá habilitar o serviço'
          ' de localização');
      Geolocator.openLocationSettings();
      return false;
    }
    return true;
  }

  Future<bool> _permissoesPermitidas() async {
    LocationPermission permissao = await Geolocator.checkPermission();
    if(permissao == LocationPermission.denied){
      permissao = await Geolocator.requestPermission();
      if(permissao == LocationPermission.denied){
        _mostrarMensagem('Não será possível utilizar o recurso '
            'por falta de permissão');
      }
    }
    if(permissao == LocationPermission.deniedForever){
      await _mostrarDialogMensagem('Para utilizar esse recurso, você deverá acessar '
          'as configurações do app para permitir a utilização do serviço de localização');
      Geolocator.openAppSettings();
      return false;
    }
    return true;
  }

  void _obterLocalizacaoAtual() async {
    if (widget.pontoAtual != null && widget.pontoAtual!.latitude != null && widget.pontoAtual!.longitude != null) {
      // Coordenadas já estão definidas no objeto pontoAtual
      _localizacaoAtual = await Geolocator.getCurrentPosition();
      setState(() {});
      return;
    }

    bool servicoHabilitado = await _servicoHabilitado();
    if (!servicoHabilitado) {
      return;
    }
    bool permissoesPermitidas = await _permissoesPermitidas();
    if (!permissoesPermitidas) {
      return;
    }
    _localizacaoAtual = await Geolocator.getCurrentPosition();
    setState(() {});
  }


  void _mostrarMensagem(String mensagem){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensagem)));
  }

  Future<void> _mostrarDialogMensagem(String mensagem) async {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Atenção'),
        content: Text(mensagem),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK')
          )
        ],
      ),
    );
  }

  void _abrirNoMapaDoApp() {
    if (_localizacaoAtual != null) {
      _mapController?.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(_localizacaoAtual!.latitude, _localizacaoAtual!.longitude),
          zoom: 15,
        ),
      ));
    }
  }

}