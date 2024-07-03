import 'dart:async';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_map_polyline_new/google_map_polyline_new.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uniride/DAO/carona_dao.dart';
import 'package:uniride/model/carona.dart';
import 'package:uniride/model/aluno.dart';
import 'package:uniride/utils/utils.dart';
import 'package:uniride/view/perfil_carona_page.dart';
import 'package:uniride/view/rota_page.dart';
import 'package:haversine_distance/haversine_distance.dart';
import 'package:uniride/widgets/auth_check.dart';

class CaronaCadastradaPage extends StatefulWidget {
  final Aluno aluno;
  final Carona carona;
  const CaronaCadastradaPage(
      {Key? key, required this.aluno, required this.carona})
      : super(key: key);

  @override
  _CaronaCadastradaPageState createState() => _CaronaCadastradaPageState();
}

class _CaronaCadastradaPageState extends State<CaronaCadastradaPage> {
  FirebaseStorage storage = FirebaseStorage.instance;
  List<Reference> refs = [];
  String? imagem;
  List<String>? arquivos;
  bool loading = true;
  String? imageUrl;
  Set<Polyline> polylines = {};
  GoogleMapPolyline googleMapPolyline =
      GoogleMapPolyline(apiKey: "APIKEY");
  List<Color> routeColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange
  ];
  bool loadingRota = false;
  bool alterouCarona = false;
  final haver = HaversineDistance();
  List<Marker> markers = [];

  @override
  void initState() {
    super.initState();
  }

  bool foiAvaliado(Aluno aluno) {
    bool foi = false;
    for (var avaliacao in aluno.avaliacoes) {
      if (avaliacao.avaliadorId == widget.aluno.id) {
        foi = true;
      }
    }

    return foi;
  }

  Future<String?> loadImages(String id) async {
    try {
      final ref = storage.ref("images/profile/$id.jpg");
      final url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      return null;
    }
  }

  List<LatLng> calculaRota(
      LatLng origem, List<LatLng> paradas, LatLng destino) {
    List<LatLng> rotaFinal = [];
    List<double> distancias = [];
    List<int> indexes = [];
    rotaFinal.add(origem);
    markers.clear();

    if (paradas.length < 2) {
      rotaFinal.add(paradas[0]);
    } else {
      double menorDistancia = double.infinity;
      int indexMenorDistanca = -1;

      List<LatLng> newl = List<LatLng>.from(paradas);

      for (int i = 0; i < newl.length; i++) {
        for (int e = 0; e < (paradas.length); e++) {
          final parada = rotaFinal[i];
          final startLocal =
              Location(paradas[e].latitude, paradas[e].longitude);
          final end = Location(parada.latitude, parada.longitude);

          distancias.add(haver.haversine(startLocal, end, Unit.METER));
          indexes.add(i);
        }
        for (int a = 0; a < distancias.length; a++) {
          if (distancias.length < 2) {
            menorDistancia = distancias[a];
            indexMenorDistanca = a;
          } else {
            if (distancias[a] < menorDistancia) {
              menorDistancia = distancias[a];
              indexMenorDistanca = a;
            }
          }
        }
        rotaFinal.add(paradas[indexMenorDistanca]);
        paradas.remove(paradas[indexMenorDistanca]);
        distancias.clear();
        indexes.clear();
        menorDistancia = double.infinity;
        indexMenorDistanca = -1;
      }
    }

    rotaFinal.add(destino);
    setState(
      () {
        for (var local in rotaFinal) {
          markers.add(
            Marker(
              markerId: const MarkerId("institutoMarker"),
              position: local,
              infoWindow: InfoWindow(
                title: local.toString(),
              ),
            ),
          );
        }
      },
    );
    return rotaFinal;
  }

  final CaronaDAO caronaDAO = CaronaDAO();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (alterouCarona) {
          setState(() {});
          Navigator.of(context).pop(true);
          return true;
        } else {
          Navigator.of(context).pop(false);
          return true;
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Carona'),
          centerTitle: true,
          backgroundColor: const Color(0xFF186A11),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width / 1.20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 30),
                      const Text(
                        "Local de saída:",
                        style: TextStyle(
                          fontFamily: "Inter",
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        widget.carona.origem,
                        style: const TextStyle(
                          fontFamily: "InterLight",
                          fontSize: 20,
                          color: Color.fromARGB(255, 99, 99, 99),
                        ),
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        "Destino:",
                        style: TextStyle(
                          fontFamily: "Inter",
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        widget.carona.destino.descricao,
                        style: const TextStyle(
                          fontFamily: "InterLight",
                          fontSize: 20,
                          color: Color.fromARGB(255, 99, 99, 99),
                        ),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: () async {
                          List<LatLng> rota = [];
                          loadingRota = true;
                          polylines.clear();
                          markers.clear();

                          if (widget.carona.passageiros.isEmpty) {
                            markers.add(
                              Marker(
                                markerId: const MarkerId("origemMarker"),
                                position: widget.carona.localizacao,
                                infoWindow:  InfoWindow(
                                  title: widget.carona.origem,
                                ),
                              ),
                            );
                            markers.add(
                              Marker(
                                markerId: const MarkerId("destinoMarker"),
                                position: widget
                                    .carona.motorista.instituicao.localizacao,
                                infoWindow: InfoWindow(
                                  title: widget.carona.motorista.instituicao.descricao,
                                ),
                              ),
                            );
                            List<LatLng>? newCoordinates =
                                await googleMapPolyline
                                    .getCoordinatesWithLocation(
                              origin: widget.carona.localizacao,
                              destination: widget.aluno.instituicao.localizacao,
                              mode: RouteMode.driving,
                            );
                            Polyline newPolyline = Polyline(
                              polylineId: const PolylineId('rota'),
                              color: Colors.red,
                              points: newCoordinates!,
                              width: 1,
                            );
                            setState(
                              () {
                                polylines.add(newPolyline);
                              },
                            );
                          } else {
                            List<LatLng> passageirosLocal = [];
                            for (var passageiro in widget.carona.passageiros) {
                              passageirosLocal.add(passageiro.localizacao);
                            }

                            List<LatLng> rotaFinal = calculaRota(
                              widget.carona.localizacao,
                              passageirosLocal,
                              widget.aluno.instituicao.localizacao,
                            );

                            rota = rotaFinal.sublist(1, rotaFinal.length - 1);

                            for (var i = 1; i < rotaFinal.length; i++) {
                              final int colorIndex = i % routeColors.length;
                              List<LatLng>? newCoordinates =
                                  await googleMapPolyline
                                      .getCoordinatesWithLocation(
                                origin: rotaFinal[i - 1],
                                destination: rotaFinal[i],
                                mode: RouteMode.driving,
                              );
                              Polyline newPolyline = Polyline(
                                polylineId: PolylineId('rota$i'),
                                color: routeColors[colorIndex],
                                points: newCoordinates!,
                                width: 2,
                              );
                              setState(
                                () {
                                  polylines.add(newPolyline);
                                  loadingRota = false;
                                },
                              );
                            }
                          }
                          setState(() {
                            loadingRota = false;
                          });

                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => RotaPage(
                                rota: polylines,
                                origem: widget.carona.localizacao,
                                destino: widget.aluno.instituicao.localizacao,
                                paradas: rota,
                                markers: markers,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF186A11),
                          minimumSize: const Size(140, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: (loadingRota)
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text(
                                "Ver rota",
                                style: TextStyle(
                                  fontFamily: "Inter",
                                  fontSize: 20,
                                ),
                              ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
                const Divider(color: Colors.black),
                const SizedBox(height: 30),
                const Text(
                  "Informações da carona",
                  style: TextStyle(
                    fontFamily: "Inter",
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 50),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 1.2,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Text(
                            "Hora de saída",
                            style: TextStyle(
                                fontFamily: "Inter",
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 15),
                          Text(
                            widget.carona.horaToString(widget.carona.horaSaida),
                            style: const TextStyle(
                              fontFamily: "Inter",
                              fontSize: 18,
                              color: Color.fromARGB(255, 99, 99, 99),
                            ),
                          ),
                          const SizedBox(height: 30),
                          const Text(
                            "Preço total",
                            style: TextStyle(
                                fontFamily: "Inter",
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 15),
                          Text(
                            "R\$ ${widget.carona.preco.toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontFamily: "Inter",
                              fontSize: 18,
                              color: Color.fromARGB(255, 99, 99, 99),
                            ),
                          ),
                          const SizedBox(height: 30),
                          const Text(
                            "Vagas restantes",
                            style: TextStyle(
                                fontFamily: "Inter",
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 15),
                          Text(
                            widget.carona.vagasRestantes.toString(),
                            style: const TextStyle(
                              fontFamily: "Inter",
                              fontSize: 18,
                              color: Color.fromARGB(255, 99, 99, 99),
                            ),
                          ),
                          const SizedBox(height: 30),
                          const Text(
                            "Tipo de veículo",
                            style: TextStyle(
                                fontFamily: "Inter",
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 15),
                          Text(
                            widget.carona.motorista.veiculo!.tipoVeiculo,
                            style: const TextStyle(
                              fontFamily: "Inter",
                              fontSize: 18,
                              color: Color.fromARGB(255, 99, 99, 99),
                            ),
                          ),
                          const SizedBox(height: 30),
                          const Text(
                            "Placa do veículo",
                            style: TextStyle(
                                fontFamily: "Inter",
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 15),
                          Text(
                            widget.carona.motorista.veiculo!.placa,
                            style: const TextStyle(
                              fontFamily: "Inter",
                              fontSize: 18,
                              color: Color.fromARGB(255, 99, 99, 99),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          const Text(
                            "Hora de chegada",
                            style: TextStyle(
                                fontFamily: "Inter",
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 15),
                          Text(
                            widget.carona
                                .horaToString(widget.carona.horaChegada),
                            style: const TextStyle(
                              fontFamily: "Inter",
                              fontSize: 18,
                              color: Color.fromARGB(255, 99, 99, 99),
                            ),
                          ),
                          const SizedBox(height: 30),
                          const Text(
                            "Preço por pessoa",
                            style: TextStyle(
                                fontFamily: "Inter",
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 15),
                          Text(
                            (widget.carona.passageiros.isEmpty)
                                ? "R\$ ${widget.carona.preco.toStringAsFixed(2)}"
                                : "R\$ ${(widget.carona.preco / (widget.carona.passageiros.length + 1)).toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontFamily: "Inter",
                              fontSize: 18,
                              color: Color.fromARGB(255, 99, 99, 99),
                            ),
                          ),
                          const SizedBox(height: 30),
                          const Text(
                            "Vagas ocupadas",
                            style: TextStyle(
                                fontFamily: "Inter",
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 15),
                          Text(
                            (widget.carona.passageiros.isEmpty)
                                ? "0"
                                : widget.carona.passageiros.length.toString(),
                            style: const TextStyle(
                              fontFamily: "Inter",
                              fontSize: 18,
                              color: Color.fromARGB(255, 99, 99, 99),
                            ),
                          ),
                          const SizedBox(height: 30),
                          const Text(
                            "Modelo do veículo",
                            style: TextStyle(
                                fontFamily: "Inter",
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 15),
                          Text(
                            widget.carona.motorista.veiculo!.modelo,
                            style: const TextStyle(
                              fontFamily: "Inter",
                              fontSize: 18,
                              color: Color.fromARGB(255, 99, 99, 99),
                            ),
                          ),
                          const SizedBox(height: 30),
                          const Text(
                            "Cor do veículo",
                            style: TextStyle(
                                fontFamily: "Inter",
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 15),
                          Text(
                            widget.carona.motorista.veiculo!.cor,
                            style: const TextStyle(
                              fontFamily: "Inter",
                              fontSize: 18,
                              color: Color.fromARGB(255, 99, 99, 99),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  "Dias da carona",
                  style: TextStyle(
                      fontFamily: "Inter",
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                Text(
                  Utils.mostraDias(widget.carona.diasCarona),
                  style: const TextStyle(
                    fontFamily: "Inter",
                    fontSize: 18,
                    color: Color.fromARGB(255, 99, 99, 99),
                  ),
                ),
                const SizedBox(height: 30),
                const Divider(color: Colors.black),
                const SizedBox(height: 30),
                const Text(
                  "Passageiros",
                  style: TextStyle(
                    fontFamily: "Inter",
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),
                (widget.carona.passageiros.isEmpty)
                    ? const Column(
                        children: [
                          Text("Nenhum passageiro"),
                          SizedBox(height: 50),
                        ],
                      )
                    : Column(
                        children: widget.carona.passageiros.map(
                          (passageiro) {
                            return FutureBuilder(
                              future: loadImages(passageiro.passageiro.id),
                              builder: (context, snapshot) {
                                final imageUrl = snapshot.data;

                                return Column(
                                  children: [
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width /
                                          1.25,
                                      child: Center(
                                        child: Column(
                                          children: [
                                            (imageUrl != null)
                                                ? ClipOval(
                                                    child: Image.network(
                                                      imageUrl,
                                                      width: 100,
                                                      height: 100,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  )
                                                : Image.asset(
                                                    'assets/images/perfil_final.png',
                                                    width: 100,
                                                    height: 100,
                                                  ),
                                            const SizedBox(height: 10),
                                            Text(
                                              passageiro.passageiro.nome,
                                              style: const TextStyle(
                                                  fontFamily: "Inter",
                                                  fontSize: 22),
                                            ),
                                            const SizedBox(height: 10),
                                            Text(
                                              (passageiro.passageiro.avaliacoes
                                                      .isEmpty)
                                                  ? ("Nenhuma avaliação")
                                                  : (passageiro.passageiro
                                                              .somaAvaliacoes /
                                                          passageiro
                                                              .passageiro
                                                              .avaliacoes
                                                              .length)
                                                      .toStringAsFixed(1),
                                              style: const TextStyle(
                                                  fontFamily: "Inter",
                                                  fontSize: 18),
                                            ),
                                            const SizedBox(height: 30),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    const Color(0xFF186A11),
                                                minimumSize:
                                                    const Size(140, 50),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(18),
                                                ),
                                              ),
                                              onPressed: () {
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: (_) =>
                                                        PerfilCaronaPage(
                                                            alunoPerfil:
                                                                passageiro
                                                                    .passageiro,
                                                            aluno:
                                                                widget.aluno,
                                                                isPassageiro: true,),
                                                  ),
                                                );
                                              },
                                              child: const Text(
                                                "Ver perfil",
                                                style: TextStyle(
                                                    fontFamily: "Inter",
                                                    fontSize: 18),
                                              ),
                                            ),
                                            const SizedBox(height: 30),
                                            Text(
                                              Utils.mostraDias(
                                                  passageiro.diasCarona),
                                              style: const TextStyle(
                                                  fontFamily: "Inter",
                                                  fontSize: 20),
                                            ),
                                            const SizedBox(height: 20),
                                            const Text(
                                              "Local do passageiro",
                                              style: TextStyle(
                                                  fontFamily: "Inter",
                                                  fontSize: 25,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(height: 10),
                                            Text(
                                              passageiro.origem.toString(),
                                              style: const TextStyle(
                                                  fontFamily: "Inter",
                                                  fontSize: 18),
                                            ),
                                            const SizedBox(height: 30),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    const Color.fromARGB(
                                                        255, 255, 136, 0),
                                                minimumSize:
                                                    const Size(140, 50),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(18),
                                                ),
                                              ),
                                              onPressed: () async {
                                                bool? confirm =
                                                    await showConfirmationDialog(
                                                        context,
                                                        "Deseja remover este passageiro?");
                                                if (confirm!) {
                                                  await widget.carona.motorista
                                                      .removePassageiro(
                                                          widget.carona,
                                                          passageiro
                                                              .passageiro.id);
                                                  setState(() {
                                                    alterouCarona = true;
                                                  });
                                                }
                                              },
                                              child: const Text(
                                                "Remover passageiro",
                                                style: TextStyle(
                                                    fontFamily: "Inter",
                                                    fontSize: 18),
                                              ),
                                            ),
                                            const SizedBox(height: 30),
                                            const Divider(color: Colors.black),
                                            const SizedBox(height: 20),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ).toList(),
                      ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    minimumSize: const Size(140, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: () async {
                    bool? confirm = await showConfirmationDialog(
                        context, "Deseja cancelar essa carona?");
                    if (confirm!) {
                      await widget.carona.motorista
                          .cancelaCarona(widget.carona);
                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const AuthCheck()),
                          (route) => false);
                    }
                  },
                  child: const Text(
                    "Cancelar carona",
                    style: TextStyle(fontFamily: "Inter", fontSize: 18),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool?> showConfirmationDialog(
      BuildContext context, String message) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Confirmação",
            style: TextStyle(
              fontFamily: "Inter",
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            message,
            style: const TextStyle(
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
                "Sim",
                style: TextStyle(
                  fontFamily: "Inter",
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text(
                "Não",
                style: TextStyle(
                  fontFamily: "Inter",
                  fontSize: 18,
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
