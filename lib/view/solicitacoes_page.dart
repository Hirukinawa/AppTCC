import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:uniride/DAO/carona_dao.dart';
import 'package:uniride/model/carona.dart';
import 'package:uniride/model/aluno.dart';
import 'package:uniride/model/passageiro.dart';
import 'package:uniride/services/auth_service.dart';
import 'package:uniride/view/cadastro_veiculo_page.dart';
import 'package:uniride/view/detalhes_solicitacao_page.dart';

class SolicitacoesPage extends StatefulWidget {
  final Aluno aluno;
  final AuthService auth;
  const SolicitacoesPage({required this.aluno, super.key, required this.auth});

  @override
  State<SolicitacoesPage> createState() => _SolicitacoesPageState();
}

class _SolicitacoesPageState extends State<SolicitacoesPage> {
  FirebaseStorage storage = FirebaseStorage.instance;
  List<Reference> refs = [];
  String? imagem;
  List<String>? arquivos;
  bool loading = true;
  String? imageUrl;
  CaronaDAO caronaDAO = CaronaDAO();

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solicitações'),
        centerTitle: true,
        backgroundColor: const Color(0xFF186A11),
      ),
      body: (widget.aluno.veiculo == null)
          ? Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width / 1.33,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Center(
                      child: Text(
                        "Você não tem um veículo para oferecer caronas",
                        style: TextStyle(
                          fontFamily: "Inter",
                          fontSize: 20,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => CadastroVeiculoPage(
                                aluno: widget.aluno, auth: widget.auth)));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 2, 197, 67),
                        minimumSize: const Size(140, 60),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      child: const Text(
                        "Cadastrar veículo",
                        style: TextStyle(
                          fontFamily: "Inter",
                          fontSize: 18,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            )
          : Center(
              child: FutureBuilder<Carona?>(
                future: caronaDAO.retrieve(widget.aluno.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text("Erro: ${snapshot.error}");
                  } else if (snapshot.data == null) {
                    return const Center(
                      child: Text(
                        "Nenhuma carona cadastrada",
                        style: TextStyle(
                          fontFamily: "Inter",
                          fontSize: 20,
                        ),
                      ),
                    );
                  } else {
                    final Carona? carona = snapshot.data;

                    if (carona!.interessados.isEmpty) {
                      return const Center(
                        child: Text(
                          "Nenhuma solicitação",
                          style: TextStyle(
                            fontFamily: "Inter",
                            fontSize: 20,
                          ),
                        ),
                      );
                    } else if (carona.vagasRestantes == 0) {

                      return const Center(
                        child: Text(
                          "Limite de passageiros atingido",
                          style: TextStyle(
                            fontFamily: "Inter",
                            fontSize: 20,
                          ),
                        ),
                      );

                    }else {
                      return ListView.builder(
                        itemCount: carona.interessados.length,
                        itemBuilder: (context, index) {
                          final Passageiro interessado =
                              carona.interessados[index];

                          return FutureBuilder(
                            future: loadImages(interessado.passageiro.id),
                            builder: (context, snapshot) {
                              final imageUrl = snapshot.data;

                              return SizedBox(
                                width: MediaQuery.of(context).size.width / 2,
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
                                        title:
                                            Text(interessado.passageiro.nome),
                                        trailing: Text(
                                          (interessado.passageiro.avaliacoes
                                                  .isEmpty)
                                              ? "0"
                                              : (interessado.passageiro
                                                          .somaAvaliacoes /
                                                      interessado.passageiro
                                                          .avaliacoes.length)
                                                  .toStringAsFixed(1),
                                        ),
                                        onTap: () async {
                                          final result =
                                              await Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  DetalhesSolicitacoesPage(
                                                      motorista: widget.aluno,
                                                      carona: carona,
                                                      interessado: interessado),
                                            ),
                                          );
                                          if (result != null &&
                                              result == true) {
                                            setState(() {});
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
