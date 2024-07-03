import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:uniride/DAO/avaliacao_dao.dart';
import 'package:uniride/DAO/aluno_dao.dart';
import 'package:uniride/model/avaliacao.dart';
import 'package:uniride/model/aluno.dart';

class AvaliacoesPage extends StatefulWidget {
  final Aluno aluno;
  const AvaliacoesPage({
    Key? key,
    required this.aluno,
  }) : super(key: key);

  @override
  _AvaliacoesPageState createState() => _AvaliacoesPageState();
}

class _AvaliacoesPageState extends State<AvaliacoesPage> {
  FirebaseStorage storage = FirebaseStorage.instance;
  final AvaliacaoDAO avaliacaoDAO = AvaliacaoDAO();
  final AlunoDAO alunoDAO = AlunoDAO();

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
        title: const Text('Avaliações'),
        centerTitle: true,
        backgroundColor: const Color(0xFF186A11),
      ),
      body: Center(
        child: FutureBuilder<List<Avaliacao>?>(
          future: avaliacaoDAO.retrieveAll(widget.aluno.id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text("Erro: ${snapshot.error}");
            } else {
              final List<Avaliacao> avaliacoes = snapshot.data ?? [];

              if (avaliacoes.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Nenhuma avaliação encontrada",
                        style: TextStyle(
                          fontFamily: "Inter",
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return ListView.builder(
                  itemCount: avaliacoes.length,
                  itemBuilder: (context, index) {
                    return FutureBuilder<Aluno?>(
                      future: (!avaliacoes[index].anonimo)
                          ? alunoDAO.retrieve(avaliacoes[index].avaliadorId)
                          : Future.value(null),
                      builder: (context, alunoSnapshot) {
                        final Avaliacao avaliacao = avaliacoes[index];
                        final aluno = alunoSnapshot.data;
                        return FutureBuilder(
                            future: (!avaliacoes[index].anonimo)
                                ? loadImages(avaliacao.avaliadorId)
                                : Future.value(null),
                            builder: (context, snapshot) {
                              final imageUrl = snapshot.data;

                              return SizedBox(
                                width: MediaQuery.of(context).size.width / 1.5,
                                child: Center(
                                  child: Column(
                                    children: [
                                      ListTile(
                                        leading: (imageUrl != null &&
                                                !avaliacao.anonimo)
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
                                            (avaliacao.anonimo)
                                                ? const Text(
                                                    "Usuário anônimo",
                                                    style: TextStyle(
                                                      fontFamily: "Inter",
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  )
                                                : Text(
                                                    aluno?.nome ?? "",
                                                    style: const TextStyle(
                                                      fontFamily: "Inter",
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                            Text(avaliacao.comentario),
                                          ],
                                        ),
                                        trailing: Text(
                                          avaliacao.nota.toString(),
                                          style: const TextStyle(
                                            fontFamily: "Inter",
                                          ),
                                        ),
                                      ),
                                      const Divider(color: Colors.black),
                                    ],
                                  ),
                                ),
                              );
                            });
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
