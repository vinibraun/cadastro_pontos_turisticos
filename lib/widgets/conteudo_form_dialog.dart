
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../model/ponto.dart';
import 'package:flutter/material.dart';
import '../model/cep_model.dart';
import '../services/cep_service.dart';
import 'package:geocoding/geocoding.dart';

class ConteudoFormDialog extends StatefulWidget{
  final Ponto? pontoAtual;

  ConteudoFormDialog({Key? key, this.pontoAtual}) : super (key: key);

  @override
  ConteudoFormDialogState createState() => ConteudoFormDialogState();

}

class CepFormWidget extends StatefulWidget {
  @override
  _CepFormWidgetState createState() => _CepFormWidgetState();
}

class _CepFormWidgetState extends State<CepFormWidget> {
  final _service = CepService();
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  double? _latitude;
  double? _longitude;
  final _cepFormater = MaskTextInputFormatter(
    mask: '#####-###',
    filter: {'#': RegExp(r'[0-9]')},
  );
  var _loading = false;
  Cep? _cep;

  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Form(
            key: _formKey,
            child: TextFormField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'CEP',
                suffixIcon: _loading
                    ? Padding(
                  padding: EdgeInsets.all(10),
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : IconButton(
                  onPressed: _findCep,
                  icon: Icon(Icons.search),
                ),
              ),
              inputFormatters: [_cepFormater],
              validator: (String? value) {
                if (value == null || value.isEmpty || !_cepFormater.isFill()) {
                  return 'Informe um cep válido!';
                }
                return null;
              },
            ),
          ),
          Container(height: 10),
          ..._buildWidgets(),
        ],
      ),
    );
  }

  List<Widget> _buildWidgets() {
    final List<Widget> widgets = [];
    if (_cep != null) {
      widgets.addAll([
        Text('CEP: ${_cep!.cep ?? ''}'),
        Text('Logradouro: ${_cep!.logradouro ?? ''}'),
        Text('Complemento: ${_cep!.complemento ?? ''}'),
        Text('Bairro: ${_cep!.bairro ?? ''}'),
        Text('Cidade: ${_cep!.localidade ?? ''}'),
        Text('Estado: ${_cep!.uf ?? ''}'),
        Text('IBGE: ${_cep!.ibge ?? ''}'),
        Text('GIA: ${_cep!.gia ?? ''}'),
        Text('Código de Área: ${_cep!.codigoDeArea ?? ''}'),
        Text('SIAFI: ${_cep!.siafi ?? ''}'),
        ElevatedButton(
          onPressed: _getCoordinates,
          child: Text('Obter coordenadas'),
        ),
        if (_latitude != null) Text('Latitude: $_latitude'),
        if (_longitude != null) Text('Longitude: $_longitude'),
      ]);
    }
    return widgets;
  }

  Future<void> _findCep() async {
    if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _loading = true;
    });
    try {
      _cep = await _service.findCepAsObject(_cepFormater.getUnmaskedText());
    } catch (e) {
      debugPrint(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Ocorreu um erro, tente novamente! \nERRO: ${e.toString()}')));
    }
    setState(() {
      _loading = false;
    });
  }

  Future<void> _getCoordinates() async {
    if (_cep != null) {
      try {
        final address = '${_cep!.logradouro ?? ''}, ${_cep!.localidade ?? ''}, ${_cep!.uf ?? ''}';
        List<Location> locations = await locationFromAddress(address);

        if (locations.isNotEmpty) {
          Location location = locations[0];
          setState(() {
            _latitude = location.latitude;
            _longitude = location.longitude;
          });
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Erro'),
                content: Text('Ocorreu um erro ao obter as coordenadas. Tente novamente.'),
                actions: [
                  TextButton(
                    child: Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        }
      } catch (e) {
        debugPrint(e.toString());
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Erro'),
              content: Text('Ocorreu um erro ao obter as coordenadas. Tente novamente.'),
              actions: [
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    }
  }

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

  final _service = CepService();
  final _formKey = GlobalKey<FormState>();
  var _loading = false;
  Cep? _cep;
  final _cepFormater = MaskTextInputFormatter(
      mask: '#####-###',
      filter: {'#' : RegExp(r'[0-9]')}
  );

  Future<void> _findCep() async {
    if(_formKey.currentState == null || !_formKey.currentState!.validate()){
      return;
    }
    setState(() {
      _loading = true;
    });
    try{
      _cep = await _service.findCepAsObject(_cepFormater.getUnmaskedText());
    }catch(e){
      debugPrint(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Ocorreu um erro, tente noavamente! \n'
              'ERRO: ${e.toString()}')
      ));
    }
    setState(() {
      _loading = false;
    });
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

    // Mostrar o diálogo de confirmação
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmação de Localização'),
          content: Text('A localização obtida é correta?'),
          actions: [
            TextButton(
              child: Text('Sim'),
              onPressed: () {
                Navigator.of(context).pop();
                // A localização é correta, continuar com o processamento e salvar no banco de dados
              },
            ),
            TextButton(
              child: Text('Não'),
              onPressed: () {
                Navigator.of(context).pop();
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Pesquisar por CEP'),
                      content: SingleChildScrollView(
                        child: CepFormWidget(),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        );
      },
    );
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