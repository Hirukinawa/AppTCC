import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_map_polyline_new/google_map_polyline_new.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:provider/provider.dart';
import 'package:uniride/DAO/aluno_dao.dart';
import 'package:uniride/controller/mapa_controller.dart';
import 'package:uniride/model/carona.dart';
import 'package:uniride/model/aluno.dart';
import 'package:uniride/model/passageiro.dart';
import 'package:uniride/widgets/auth_check.dart';

class CriarCaronaPage extends StatefulWidget {
  final Aluno aluno;
  const CriarCaronaPage({Key? key, required this.aluno}) : super(key: key);

  @override
  _CriarCaronaPageState createState() => _CriarCaronaPageState();
}

class _CriarCaronaPageState extends State<CriarCaronaPage> {
  final db = FirebaseFirestore.instance;
  final formKey = GlobalKey<FormState>();
  final horasaidaForm = TextEditingController();
  final horaChegadaForm = TextEditingController();
  final partidaForm = TextEditingController();
  final destinoForm = TextEditingController();
  final vagasForm = TextEditingController();
  final precoForm = TextEditingController();
  bool monday = false;
  bool tuesday = false;
  bool wednesday = false;
  bool thursday = false;
  bool friday = false;
  bool saturday = false;

  TimeOfDay _saidaTime = TimeOfDay.now();
  TimeOfDay _chegadaTime = TimeOfDay.now();

  LatLng? location;
  List<Marker> markers = [];
  Set<Polyline> polylines = {};
  bool loadingMap = false;
  bool carregouLatLng = false;

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

  Future<void> _selectChegadaTime(BuildContext context) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _chegadaTime,
    );

    if (pickedTime != null && pickedTime != _chegadaTime) {
      setState(() {
        _chegadaTime = pickedTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final AlunoDAO alunoDAO = AlunoDAO();
    final Aluno aluno = widget.aluno;
    List<bool> diasSemana = [
      monday,
      tuesday,
      wednesday,
      thursday,
      friday,
      saturday
    ];

    final MapaController mapaController = Provider.of<MapaController>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Oferecer carona'),
        centerTitle: true,
        backgroundColor: const Color(0xFF186A11),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width / 1.25,
            child: Column(
              children: [
                Form(
                  key: formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 30),
                      TextFormField(
                        onTapOutside: (event) =>
                            FocusScope.of(context).unfocus(),
                        readOnly: true,
                        controller: TextEditingController(
                          text:
                              '${_saidaTime.hour}:${_saidaTime.minute.toString().padLeft(2, '0')}',
                        ),
                        onTap: () => _selectSaidaTime(context),
                        decoration: const InputDecoration(
                          labelText: 'Hora da Saída',
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Preencha a hora de saída";
                          } else {
                            return null;
                          }
                        },
                      ),
                      const SizedBox(height: 30),
                      TextFormField(
                        onTapOutside: (event) =>
                            FocusScope.of(context).unfocus(),
                        readOnly: true,
                        controller: TextEditingController(
                          text:
                              '${_chegadaTime.hour}:${_chegadaTime.minute.toString().padLeft(2, '0')}',
                        ),
                        onTap: () => _selectChegadaTime(context),
                        decoration: const InputDecoration(
                          labelText: 'Hora de Chegada (horário da aula)',
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Preencha a hora de chegada";
                          } else {
                            return null;
                          }
                        },
                      ),
                      const SizedBox(height: 30),
                      TextFormField(
                        onTapOutside: (event) =>
                            FocusScope.of(context).unfocus(),
                        controller: precoForm,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: const InputDecoration(
                          labelText: "Preço da viagem",
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Escolha um preço";
                          } else {
                            return null;
                          }
                        },
                      ),
                      const SizedBox(height: 30),
                      TextFormField(
                        onTapOutside: (event) =>
                            FocusScope.of(context).unfocus(),
                        controller: vagasForm,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        decoration: const InputDecoration(
                          labelText: "Vagas de passageiros",
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Preencha a quantidade de vagas";
                          } else {
                            return null;
                          }
                        },
                      ),
                      const SizedBox(height: 30),
                      TapRegion(
                        onTapOutside: (event) =>
                            FocusScope.of(context).unfocus(),
                        child: GooglePlaceAutoCompleteTextField(
                          textEditingController: partidaForm,
                          googleAPIKey:
                              "APIKEY",
                          inputDecoration: const InputDecoration(
                            labelText: "Local de partida",
                          ),
                          debounceTime: 800,
                          countries: const ["br"],
                          isLatLngRequired: true,
                          getPlaceDetailWithLatLng: (Prediction prediction) {},
                          itemClick: (Prediction prediction) async {
                            setState(() {
                              loadingMap = true;
                              polylines.clear();
                              carregouLatLng = false;
                              markers.clear();
                            });
                            partidaForm.text = prediction.description!;
                            partidaForm.selection = TextSelection.fromPosition(
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
                              destination: widget.aluno.instituicao.localizacao,
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
                                            widget.aluno.instituicao.localizacao
                                                .latitude
                                        ? location!.latitude
                                        : widget.aluno.instituicao.localizacao
                                            .latitude,
                                    location!.longitude <
                                            widget.aluno.instituicao.localizacao
                                                .longitude
                                        ? location!.longitude
                                        : widget.aluno.instituicao.localizacao
                                            .longitude,
                                  ),
                                  northeast: LatLng(
                                    location!.latitude >
                                            widget.aluno.instituicao.localizacao
                                                .latitude
                                        ? location!.latitude
                                        : widget.aluno.instituicao.localizacao
                                            .latitude,
                                    location!.longitude >
                                            widget.aluno.instituicao.localizacao
                                                .longitude
                                        ? location!.longitude
                                        : widget.aluno.instituicao.localizacao
                                            .longitude,
                                  ),
                                ),
                                50,
                              ),
                            );
                          },
                          itemBuilder: (context, index, Prediction prediction) {
                            return Container(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                children: [
                                  const Icon(Icons.location_on),
                                  const SizedBox(
                                    width: 7,
                                  ),
                                  Expanded(
                                      child: Text(prediction.description ?? ""))
                                ],
                              ),
                            );
                          },
                          seperatedBuilder: const Divider(),
                          isCrossBtnShown: true,
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
                                  target: LatLng(
                                      mapaController.lat, mapaController.long),
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
                                  width:
                                      MediaQuery.of(context).size.width / 1.10,
                                  height:
                                      MediaQuery.of(context).size.height / 2.25,
                                  color:
                                      const Color.fromRGBO(255, 255, 255, 0.5),
                                  child: const Center(
                                    child: SizedBox(
                                        child: CircularProgressIndicator()),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        "Dias das caronas",
                        style: TextStyle(
                          fontFamily: "Inter",
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 30),
                      Row(
                        children: [
                          Checkbox(
                            value: monday,
                            onChanged: (checked) {
                              setState(
                                () {
                                  monday = !monday;
                                },
                              );
                            },
                          ),
                          const Text(
                            "Segunda-feira",
                            style: TextStyle(
                              fontFamily: "Inter",
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Checkbox(
                            value: tuesday,
                            onChanged: (checked) {
                              setState(
                                () {
                                  tuesday = !tuesday;
                                },
                              );
                            },
                          ),
                          const Text(
                            "Terça-feira",
                            style: TextStyle(
                              fontFamily: "Inter",
                              fontSize: 18,
                            ),
                          )
                        ],
                      ),
                      Row(
                        children: [
                          Checkbox(
                            value: wednesday,
                            onChanged: (checked) {
                              setState(
                                () {
                                  wednesday = !wednesday;
                                },
                              );
                            },
                          ),
                          const Text(
                            "Quarta-feira",
                            style: TextStyle(
                              fontFamily: "Inter",
                              fontSize: 18,
                            ),
                          )
                        ],
                      ),
                      Row(
                        children: [
                          Checkbox(
                            value: thursday,
                            onChanged: (checked) {
                              setState(
                                () {
                                  thursday = !thursday;
                                },
                              );
                            },
                          ),
                          const Text(
                            "Quinta-feira",
                            style: TextStyle(
                              fontFamily: "Inter",
                              fontSize: 18,
                            ),
                          )
                        ],
                      ),
                      Row(
                        children: [
                          Checkbox(
                            value: friday,
                            onChanged: (checked) {
                              setState(
                                () {
                                  friday = !friday;
                                },
                              );
                            },
                          ),
                          const Text(
                            "Sexta-feira",
                            style: TextStyle(
                              fontFamily: "Inter",
                              fontSize: 18,
                            ),
                          )
                        ],
                      ),
                      Row(
                        children: [
                          Checkbox(
                            value: saturday,
                            onChanged: (checked) {
                              setState(
                                () {
                                  saturday = !saturday;
                                },
                              );
                            },
                          ),
                          const Text(
                            "Sábado",
                            style: TextStyle(
                              fontFamily: "Inter",
                              fontSize: 18,
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      if (monday ||
                          tuesday ||
                          wednesday ||
                          thursday ||
                          friday ||
                          saturday) {
                        if (partidaForm.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Preencha o local de partida"),
                            ),
                          );
                        } else if (!carregouLatLng) {
                          showConfirmationDialog(context);
                        } else {
                          int vagasRestantes = int.parse(vagasForm.text);
                          String precoText =
                              precoForm.text.replaceAll('R\$ ', '');
                          double precoViagem = double.parse(precoText);
                          List<Passageiro> passageiros = [];
                          List<Passageiro> interessados = [];

                          Carona carona = Carona(
                              id: aluno.id,
                              horaSaida: _saidaTime,
                              horaChegada: _chegadaTime,
                              vagasRestantes:
                                  (vagasRestantes < 1) ? 1 : vagasRestantes,
                              motorista: aluno,
                              preco: precoViagem,
                              diasCarona: diasSemana,
                              destino: aluno.instituicao,
                              origem: partidaForm.text,
                              interessados: interessados,
                              passageiros: passageiros,
                              localizacao: location!);

                          try {
                            await aluno.ofereceCarona(carona);
                            await alunoDAO.update(aluno);
                            Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (_) => const AuthCheck()),
                                (route) => false);
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Erro ao cadastrar"),
                              ),
                            );
                          }
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Selecione ao menos um dia"),
                          ),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Preencha todos os campos"),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF186A11),
                    minimumSize: const Size(140, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Criar carona",
                    style: TextStyle(
                      fontFamily: "Inter",
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(height: 50)
              ],
            ),
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
