import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uniride/DAO/carona_dao.dart';
import 'package:uniride/model/carona.dart';
import 'package:uniride/model/aluno.dart';
import 'package:uniride/model/instituicao.dart';
import 'package:uniride/model/passageiro.dart';
import 'package:uniride/view/detalhes_carona_page.dart';

class CaronasDisponiveisPage extends StatefulWidget {
  final Passageiro alunoPassageiro;
  final Instituicao destino;
  final Aluno aluno;
  final LatLng localizacao;
  final bool tudo;
  const CaronasDisponiveisPage({
    Key? key,
    required this.alunoPassageiro,
    required this.destino,
    required this.aluno,
    required this.localizacao,
    required this.tudo,
  }) : super(key: key);

  @override
  _CaronasDisponiveisPageState createState() => _CaronasDisponiveisPageState();
}

class _CaronasDisponiveisPageState extends State<CaronasDisponiveisPage> {
  FirebaseStorage storage = FirebaseStorage.instance;
  List<Reference> refs = [];
  String? imagem;
  List<String>? arquivos;
  bool loading = true;
  String? imageUrl;

  Future<String?> loadImages(String id) async {
    try {
      final ref = storage.ref("images/profile/$id.jpg");
      final url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final CaronaDAO caronaDAO = CaronaDAO();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Solicitar carona'),
        centerTitle: true,
        backgroundColor: const Color(0xFF186A11),
      ),
      body: Center(
        child: FutureBuilder<List<Carona>>(
          future: (!widget.tudo)
              ? caronaDAO.retrieveAllCaronasDisponiveis(
                  widget.destino, widget.aluno.id, widget.alunoPassageiro)
              : caronaDAO.retrieveCaronasDisponiveis(
                  widget.destino, widget.aluno.id, widget.alunoPassageiro),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text("Erro: ${snapshot.error}");
            } else {
              final List<Carona> caronasDisponiveis = snapshot.data ?? [];

              if (caronasDisponiveis.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Nenhuma carona encontrada"),
                    ],
                  ),
                );
              } else {
                return ListView.builder(
                  itemCount: caronasDisponiveis.length,
                  itemBuilder: (context, index) {
                    final Carona carona = caronasDisponiveis[index];

                    return FutureBuilder(
                      future: loadImages(carona.id),
                      builder: (context, snapshot) {
                        final imageUrl = snapshot.data;

                        return SizedBox(
                          width: MediaQuery.of(context).size.width / 1.5,
                          child: Center(
                            child: Column(
                              children: [
                                ListTile(
                                  leading: (imageUrl != null)
                                      ? ClipOval(
                                          child: Image.network(
                                            imageUrl,
                                            width: 50,
                                            height: 50,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : Image.asset(
                                          'assets/images/perfil_final.png',
                                          width: 50,
                                          height: 50,
                                        ),
                                  title: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        carona.motorista.nome,
                                        style: const TextStyle(
                                            fontFamily: "Inter",
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        "Vagas restantes: ${carona.vagasRestantes}",
                                        style: const TextStyle(
                                          fontFamily: "Inter",
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: Text(
                                    (carona.passageiros.isEmpty)
                                        ? "R\$ ${(carona.preco / 2).toStringAsFixed(2)}"
                                        : "R\$ ${(carona.preco / (carona.passageiros.length + 2)).toStringAsFixed(2)}",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontFamily: "Inter",
                                        fontSize: 16),
                                  ),
                                  onTap: () async {
                                    var result = await Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => DetalhesCaronaPage(
                                          carona: carona,
                                          aluno: widget.aluno,
                                          destino: widget.destino,
                                          passageiro: widget.alunoPassageiro,
                                        ),
                                      ),
                                    );
                                    if (result != null && result == true) {
                                      setState(() {
                                        
                                      });
                                    }
                                  },
                                ),
                                const Divider(color: Colors.black),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              }
            }
          },
        ),
      ),
    );
  }
}
