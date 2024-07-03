import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:uniride/DAO/carona_dao.dart';
import 'package:uniride/DAO/passageiro_dao.dart';
import 'package:uniride/model/carona.dart';
import 'package:uniride/model/passageiro.dart';
import 'package:uniride/utils/utils.dart';
import 'package:uniride/view/perfil_carona_page.dart';
import 'package:uniride/widgets/auth_check.dart';

class CaronaSolicitadaPage extends StatefulWidget {
  final Passageiro aluno;
  final Carona carona;
  final bool isPassageiro;
  const CaronaSolicitadaPage(
      {Key? key,
      required this.aluno,
      required this.carona,
      required this.isPassageiro})
      : super(key: key);

  @override
  _CaronaSolicitadaPageState createState() => _CaronaSolicitadaPageState();
}

class _CaronaSolicitadaPageState extends State<CaronaSolicitadaPage> {
  FirebaseStorage storage = FirebaseStorage.instance;
  List<Reference> refs = [];
  String? imagem;
  List<String>? arquivos;
  bool loading = true;

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

  final CaronaDAO caronaDAO = CaronaDAO();
  final PassageiroDAO passageiroDAO = PassageiroDAO();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                width: MediaQuery.of(context).size.width / 1.25,
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
                    const SizedBox(height: 30)
                  ],
                ),
              ),
              const Divider(color: Colors.black),
              Column(
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    "Motorista",
                    style: TextStyle(
                      fontFamily: "Inter",
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 40),
                  FutureBuilder(
                    future: loadImages(widget.carona.motorista.id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return const Text('Erro ao carregar imagem');
                      } else {
                        final imageUrl = snapshot.data;
                        return (imageUrl == null)
                            ? ClipOval(
                                child: Image.asset(
                                  'assets/images/perfil_final.png',
                                  width: 90,
                                  height: 90,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : ClipOval(
                                child: Image.network(
                                  imageUrl,
                                  width: 90,
                                  height: 90,
                                  fit: BoxFit.cover,
                                ),
                              );
                      }
                    },
                  ),
                  const SizedBox(height: 15),
                  Text(
                    widget.carona.motorista.nome,
                    style: const TextStyle(
                      fontFamily: "Inter",
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 15),
                  (widget.carona.motorista.avaliacoes.isEmpty)
                      ? const Column(
                          children: [
                            Text(
                              "Nenhuma avaliação",
                              style: TextStyle(
                                fontFamily: "InterLight",
                                fontSize: 16,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          "Avaliação: ${(widget.carona.motorista.somaAvaliacoes / widget.carona.motorista.avaliacoes.length).toStringAsFixed(1)}",
                          style: const TextStyle(
                            fontFamily: "InterLight",
                            fontSize: 16,
                          ),
                        ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF186A11),
                      minimumSize: const Size(140, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => PerfilCaronaPage(
                              alunoPerfil: widget.carona.motorista,
                              aluno: widget.aluno.passageiro,
                              isPassageiro: widget.isPassageiro),
                        ),
                      );
                    },
                    child: const Text(
                      "Ver perfil",
                      style: TextStyle(fontFamily: "Inter", fontSize: 18),
                    ),
                  ),
                ],
              ),
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
                          widget.carona.horaToString(widget.carona.horaChegada),
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
                              ? "R\$ ${(widget.carona.preco / 2).toStringAsFixed(2)}"
                              : "R\$ ${(widget.carona.preco / (widget.carona.passageiros.length + 2)).toStringAsFixed(2)}",
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
              (!widget.isPassageiro)
                  ? const SizedBox()
                  : Column(
                      children: [
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
                                      future:
                                          loadImages(passageiro.passageiro.id),
                                      builder: (context, snapshot) {
                                        final imageUrl = snapshot.data;
                                        return Column(
                                          children: [
                                            SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  1.25,
                                              child: Center(
                                                child: Column(
                                                  children: [
                                                    (imageUrl != null)
                                                        ? ClipOval(
                                                            child:
                                                                Image.network(
                                                              imageUrl,
                                                              width: 75,
                                                              height: 75,
                                                              fit: BoxFit.cover,
                                                            ),
                                                          )
                                                        : Image.asset(
                                                            'assets/images/perfil_final.png',
                                                            width: 75,
                                                            height: 75,
                                                          ),
                                                    const SizedBox(height: 15),
                                                    Text(
                                                      passageiro
                                                          .passageiro.nome,
                                                      style: const TextStyle(
                                                          fontFamily: "Inter",
                                                          fontSize: 20),
                                                    ),
                                                    const SizedBox(height: 15),
                                                    Text(
                                                      (passageiro
                                                              .passageiro
                                                              .avaliacoes
                                                              .isEmpty)
                                                          ? ("Nenhuma avaliação")
                                                          : (passageiro
                                                                      .passageiro
                                                                      .somaAvaliacoes /
                                                                  passageiro
                                                                      .passageiro
                                                                      .avaliacoes
                                                                      .length)
                                                              .toStringAsFixed(
                                                                  1),
                                                      style: const TextStyle(
                                                          fontFamily: "Inter",
                                                          fontSize: 18),
                                                    ),
                                                    (passageiro.id ==
                                                            widget.aluno.id)
                                                        ? const SizedBox()
                                                        : Column(
                                                            children: [
                                                              const SizedBox(
                                                                  height: 30),
                                                              ElevatedButton(
                                                                style: ElevatedButton
                                                                    .styleFrom(
                                                                  backgroundColor:
                                                                      const Color(
                                                                          0xFF186A11),
                                                                  minimumSize:
                                                                      const Size(
                                                                          140,
                                                                          50),
                                                                  shape:
                                                                      RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            18),
                                                                  ),
                                                                ),
                                                                onPressed: () {
                                                                  Navigator.of(
                                                                          context)
                                                                      .push(
                                                                    MaterialPageRoute(
                                                                      builder: (_) => PerfilCaronaPage(
                                                                          alunoPerfil: passageiro
                                                                              .passageiro,
                                                                          aluno: widget
                                                                              .aluno
                                                                              .passageiro,
                                                                              isPassageiro: widget.isPassageiro),
                                                                    ),
                                                                  );
                                                                },
                                                                child:
                                                                    const Text(
                                                                  "Ver perfil",
                                                                  style: TextStyle(
                                                                      fontFamily:
                                                                          "Inter",
                                                                      fontSize:
                                                                          18),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                    const SizedBox(height: 30),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            const Divider(color: Colors.black),
                                            const SizedBox(height: 20),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                ).toList(),
                              ),
                      ],
                    ),
              (widget.isPassageiro)
                  ? ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        minimumSize: const Size(140, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      onPressed: () async {
                        bool? confirm = await showConfirmationDialog(
                            context, "Deseja mesmo sair dessa carona?");
                        if (confirm!) {
                          widget.aluno.passageiro.removePassageiro(
                              widget.carona, widget.aluno.passageiro.id);
                          Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (_) => const AuthCheck()),
                              (route) => false);
                        }
                      },
                      child: const Text(
                        "Sair da carona",
                        style: TextStyle(fontFamily: "Inter", fontSize: 18),
                      ),
                    )
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        minimumSize: const Size(140, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      onPressed: () async {
                        bool? confirm = await showConfirmationDialog(
                            context, "Deseja mesmo cancelar a solicitação?");
                        if (confirm!) {
                          widget.aluno.passageiro.removeInteressado(
                              widget.carona, widget.aluno.id);
                          Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (_) => const AuthCheck()),
                              (route) => false);
                        }
                      },
                      child: const Text(
                        "Cancelar solicitação",
                        style: TextStyle(fontFamily: "Inter", fontSize: 18),
                      ),
                    ),
              const SizedBox(height: 30),
            ],
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
