import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uniride/model/carona.dart';
import 'package:uniride/model/aluno.dart';
import 'package:uniride/model/passageiro.dart';
import 'package:uniride/utils/utils.dart';
import 'package:uniride/view/perfil_aluno_page.dart';

class DetalhesSolicitacoesPage extends StatefulWidget {
  final Passageiro interessado;
  final Aluno motorista;
  final Carona carona;
  const DetalhesSolicitacoesPage(
      {Key? key,
      required this.motorista,
      required this.carona,
      required this.interessado})
      : super(key: key);

  @override
  _DetalhesSolicitacoesPageState createState() =>
      _DetalhesSolicitacoesPageState();
}

class _DetalhesSolicitacoesPageState extends State<DetalhesSolicitacoesPage> {
  FirebaseStorage storage = FirebaseStorage.instance;
  bool uploading = false;
  List<Reference> refs = [];
  String? imagem;
  bool loading = true;
  String? imageUrl;
  bool confirmouUniversidade = true;

  loadImage() async {
    String imageName = "${widget.interessado.passageiro.id}.jpg";
    try {
      final ref = storage.ref("images/profile/$imageName");
      bool exists = ref != "" ? true : false;
      if (exists) {
        imagem = await ref.getDownloadURL();
        setState(
          () {
            imageUrl = imagem;
            loading = false;
          },
        );
      } else {}
    } catch (e) {
      print("Erro ao carregar a imagem: $e");
    }
  }

  @override
  initState() {
    super.initState();
    if (mounted) loadImage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Solicitação"),
        centerTitle: true,
        backgroundColor: const Color(0xFF186A11),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),
            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width / 1.3,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        (imageUrl == null)
                            ? Image.asset(
                                'assets/images/perfil_final.png',
                                width: 100,
                                height: 100,
                              )
                            : ClipOval(
                                child: Image.network(
                                  imagem!,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                        const SizedBox(width: 60),
                        (widget.interessado.passageiro.avaliacoes.isEmpty)
                            ? const Text("Nenhuma avaliação")
                            : Text(
                                "Avaliação: ${widget.interessado.passageiro.somaAvaliacoes / widget.interessado.passageiro.avaliacoes.length}",
                                style: const TextStyle(
                                    fontFamily: 'InterLight', fontSize: 16),
                              ),
                      ],
                    ),
                    const SizedBox(height: 50),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => PerfilAlunoPage(
                                alunoPerfil: widget.interessado.passageiro),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF186A11),
                        minimumSize: const Size(200, 55),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: const Text(
                        "Ver perfil",
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: "Inter",
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Text(
                      Utils.mostraDias(widget.interessado.diasCarona),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: "Inter",
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 40),
                    const Text(
                      "Ponto de encontro:",
                      style: TextStyle(
                        fontFamily: "Inter",
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      widget.interessado.origem,
                      style: const TextStyle(
                          fontFamily: "InterLight", fontSize: 18),
                    ),
                    const SizedBox(height: 40),
                    const Text(
                      "Destino:",
                      style: TextStyle(
                        fontFamily: "Inter",
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      widget.interessado.passageiro.instituicao.descricao,
                      style: const TextStyle(
                          fontFamily: "InterLight", fontSize: 18),
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 1.10,
                      height: MediaQuery.of(context).size.height / 3,
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: widget.interessado.localizacao,
                          zoom: 13,
                        ),
                        zoomControlsEnabled: true,
                        mapType: MapType.normal,
                        myLocationEnabled: true,
                        markers: <Marker>{
                          Marker(
                            markerId: const MarkerId("passageiroMarker"),
                            position: widget.interessado.localizacao,
                            infoWindow: const InfoWindow(
                              title: "Localização do Passageiro",
                            ),
                          ),
                        },
                      ),
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: () async {
                        if (widget.interessado.passageiro.instituicao.id != widget.motorista.instituicao.id) {
                          await confirmaUniversidade(context);
                        }
                        if (confirmouUniversidade) {
                        await widget.motorista
                            .aceitaPedido(widget.carona, widget.interessado);
                        Navigator.of(context).pop(true);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF186A11),
                          minimumSize: const Size(200, 55),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18))),
                      child: const Text(
                        "Aceitar pedido",
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: "Inter",
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        await widget.motorista
                            .removeInteressado(widget.carona, widget.interessado.id);
                        Navigator.of(context).pop(true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        minimumSize: const Size(200, 55),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: const Text(
                        "Recusar pedido",
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: "Inter",
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40)
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
  Future<void> confirmaUniversidade(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Atenção!",
            style: TextStyle(
              fontFamily: "Inter",
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            "A instituição desse aluno é diferente da sua, deseja aceitar mesmo assim?",
            style: TextStyle(
              fontFamily: "Inter",
              fontSize: 16,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                setState(() {
                  confirmouUniversidade = true;
                });
                Navigator.of(context).pop();
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
                setState(() {
                  confirmouUniversidade = false;
                });
                Navigator.of(context).pop();
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
