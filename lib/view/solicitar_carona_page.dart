import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_map_polyline_new/google_map_polyline_new.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:uniride/controller/mapa_controller.dart';
import 'package:uniride/model/aluno.dart';
import 'package:uniride/view/caronas_disponiveis_page.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:uniride/model/passageiro.dart';
import 'package:uuid/uuid.dart';

class SolicitarCaronaPage extends StatefulWidget {
  final Aluno aluno;
  const SolicitarCaronaPage({Key? key, required this.aluno}) : super(key: key);

  @override
  _SolicitarCaronaPageState createState() => _SolicitarCaronaPageState();
}

class _SolicitarCaronaPageState extends State<SolicitarCaronaPage> {
  final partida = TextEditingController();
  final chegada = TextEditingController();
  LatLng? location;
  Set<Polyline> polylines = {};
  bool loadingMap = false;
  bool carregouLatLng = false;
  bool todasInstituicoes = true;
  List<Marker> markers = [];
  

  TimeOfDay _saidaTime = TimeOfDay.now();

  GoogleMapPolyline googleMapPolyline =
      GoogleMapPolyline(apiKey: "APIKEY");

  Future<void> _selectSaidaTime(BuildContext context) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _saidaTime,
    );

    if (pickedTime != null && pickedTime != _saidaTime) {
      setState(() {
        _saidaTime = pickedTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Aluno aluno = widget.aluno;
    chegada.text = aluno.instituicao.descricao;

    final MapaController mapaController = Provider.of<MapaController>(context);

    return Scaffold (
        appBar: AppBar(
          title: const Text('Solicitar carona'),
          centerTitle: true,
          backgroundColor: const Color(0xFF186A11),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width / 1.5,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(height: 30),
                      Column(
                        children: [
                          TapRegion(
                            onTapOutside: (event) =>
                                FocusScope.of(context).unfocus(),
                            child: GooglePlaceAutoCompleteTextField(
                              textEditingController: partida,
                              googleAPIKey:
                                  "APIKEY",
                              inputDecoration: const InputDecoration(
                                labelText: "Local de partida",
                              ),
                              debounceTime: 800,
                              countries: const ["br"],
                              isLatLngRequired: true,
                              getPlaceDetailWithLatLng:
                                  (Prediction prediction) {},
                              itemClick: (Prediction prediction) async {
                                setState(() {
                                  loadingMap = true;
                                  polylines.clear();
                                  carregouLatLng = false;
                                  markers.clear();
                                });
                                partida.text = prediction.description!;
                                partida.selection = TextSelection.fromPosition(
                                  TextPosition(
                                    offset: prediction.description!.length,
                                  ),
                                );
                                while (prediction.lat == null ||
                                    prediction.lng == null) {
                                  await Future.delayed(
                                      const Duration(milliseconds: 10000));
                                }
    
                                setState(() {
                                  location = LatLng(
                                    double.tryParse(prediction.lat!)!,
                                    double.tryParse(prediction.lng!)!,
                                  );
                                  carregouLatLng = true;
                                  loadingMap = false;
                                  markers.add(
                                    Marker(
                                      markerId: const MarkerId("institutoMarker"),
                                      position:
                                          widget.aluno.instituicao.localizacao,
                                      infoWindow: InfoWindow(
                                        title: widget.aluno.instituicao.descricao,
                                      ),
                                    ),
                                  );
                                  markers.add(
                                    Marker(
                                      markerId: const MarkerId("localMarker"),
                                      position: location!,
                                      infoWindow: InfoWindow(
                                        title: location.toString(),
                                      ),
                                    ),
                                  );
                                });
    
                                mapaController.getNewPosicao(location!);
                                List<LatLng>? newCoordinates =
                                    await googleMapPolyline
                                        .getCoordinatesWithLocation(
                                  origin: location!,
                                  destination:
                                      widget.aluno.instituicao.localizacao,
                                  mode: RouteMode.driving,
                                );
                                Polyline newPolyline = Polyline(
                                  polylineId: PolylineId('rota'),
                                  color: Colors.red,
                                  points: newCoordinates!,
                                  width: 2,
                                );
                                setState(() {
                                  polylines.add(newPolyline);
                                });
    
                                double calculateDistance(
                                    LatLng origin, LatLng destination) {
                                  final double distance =
                                      Geolocator.distanceBetween(
                                    origin.latitude,
                                    origin.longitude,
                                    destination.latitude,
                                    destination.longitude,
                                  );
    
                                  return distance;
                                }
    
                                double distance = calculateDistance(
                                  location!,
                                  widget.aluno.instituicao.localizacao,
                                );
    
                                double zoomLevel = 14;
                                if (distance > 0) {
                                  zoomLevel = 14 - (distance / 10000);
    
                                  zoomLevel = zoomLevel.clamp(0, 21);
                                }
                                mapaController.mapsController.animateCamera(
                                  CameraUpdate.newLatLngBounds(
                                    LatLngBounds(
                                      southwest: LatLng(
                                        location!.latitude <
                                                widget.aluno.instituicao
                                                    .localizacao.latitude
                                            ? location!.latitude
                                            : widget.aluno.instituicao.localizacao
                                                .latitude,
                                        location!.longitude <
                                                widget.aluno.instituicao
                                                    .localizacao.longitude
                                            ? location!.longitude
                                            : widget.aluno.instituicao.localizacao
                                                .longitude,
                                      ),
                                      northeast: LatLng(
                                        location!.latitude >
                                                widget.aluno.instituicao
                                                    .localizacao.latitude
                                            ? location!.latitude
                                            : widget.aluno.instituicao.localizacao
                                                .latitude,
                                        location!.longitude >
                                                widget.aluno.instituicao
                                                    .localizacao.longitude
                                            ? location!.longitude
                                            : widget.aluno.instituicao.localizacao
                                                .longitude,
                                      ),
                                    ),
                                    50,
                                  ),
                                );
                              },
                              itemBuilder:
                                  (context, index, Prediction prediction) {
                                return Container(
                                  padding: const EdgeInsets.all(10),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.location_on),
                                      const SizedBox(
                                        width: 7,
                                      ),
                                      Expanded(
                                          child:
                                              Text(prediction.description ?? ""))
                                    ],
                                  ),
                                );
                              },
                              seperatedBuilder: const Divider(),
                              isCrossBtnShown: true,
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: chegada,
                            enabled: false,
                            decoration: const InputDecoration(
                              labelText: "Local de chegada",
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 30),
                      TextFormField(
                        onTapOutside: (event) => FocusScope.of(context).unfocus(),
                        readOnly: true,
                        controller: TextEditingController(
                          text:
                              '${_saidaTime.hour}:${_saidaTime.minute.toString().padLeft(2, '0')}',
                        ),
                        onTap: () => _selectSaidaTime(context),
                        decoration: const InputDecoration(
                          labelText: 'Hora de Chegada',
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Preencha a hora de chegada";
                          } else {
                            return null;
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Stack(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 1.10,
                      height: MediaQuery.of(context).size.height / 2.25,
                      child: ChangeNotifierProvider<MapaController>(
                        create: (context) => MapaController(),
                        child: GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target:
                                LatLng(mapaController.lat, mapaController.long),
                            zoom: 13,
                          ),
                          zoomControlsEnabled: true,
                          mapType: MapType.normal,
                          myLocationEnabled: true,
                          onMapCreated: mapaController.onMapCreated,
                          polylines: polylines,
                          markers: Set<Marker>.from(markers),
                        ),
                      ),
                    ),
                    if (loadingMap)
                      Positioned.fill(
                        child: Center(
                          child: Container(
                              width: MediaQuery.of(context).size.width / 1.10,
                              height: MediaQuery.of(context).size.height / 2.25,
                              color: const Color.fromRGBO(255, 255, 255, 0.5),
                              child: const Center(
                                child:
                                    SizedBox(child: CircularProgressIndicator()),
                              )),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 1.25,
                  child: Row(
                    children: [
                      Checkbox(
                        value: todasInstituicoes,
                        onChanged: (checked) {
                          setState(
                            () {
                              todasInstituicoes = !todasInstituicoes;
                            },
                          );
                        },
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 1.5,
                        child: const Text(
                          "Mostrar apenas caronas para a minha instituição",
                          style: TextStyle(
                            fontFamily: "Inter",
                            fontSize: 16,
                          ),
                          softWrap: true,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 60),
                ElevatedButton(
                  onPressed: () {
                    if (partida.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Preencha seu local de saída"),
                        ),
                      );
                    } else if (!carregouLatLng) {
                      showConfirmationDialog(context);
                    } else {
                      var uuid = const Uuid();
                      Passageiro passageiro = Passageiro(
                          id: uuid.v4(),
                          passageiro: aluno,
                          carona: "",
                          horaSaida: _saidaTime,
                          origem: partida.text,
                          diasCarona: [],
                          localizacao: location!);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => CaronasDisponiveisPage(
                              alunoPassageiro: passageiro,
                              aluno: aluno,
                              destino: widget.aluno.instituicao,
                              localizacao: location!,
                              tudo: todasInstituicoes),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF186A11),
                    minimumSize: const Size(120, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    "Solicitar",
                    style: TextStyle(
                      fontFamily: "Inter",
                      fontSize: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      );
  }

  Future<bool?> showConfirmationDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Espere!",
            style: TextStyle(
              fontFamily: "Inter",
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            "Digite um endereço no primeiro campo, espere carregar os endereços, selecione um e então espere o mapa traçar uma rota para poder continuar",
            style: TextStyle(
              fontFamily: "Inter",
              fontSize: 16,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text(
                "OK",
                style: TextStyle(
                  fontFamily: "Inter",
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
