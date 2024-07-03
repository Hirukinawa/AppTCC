import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:uniride/DAO/aluno_dao.dart';
import 'package:uniride/DAO/passageiro_dao.dart';
import 'package:uniride/model/carona.dart';
import 'package:uniride/model/aluno.dart';
import 'package:uniride/model/instituicao.dart';
import 'package:uniride/model/passageiro.dart';
import 'package:uniride/utils/utils.dart';
import 'package:uniride/view/perfil_aluno_page.dart';
import 'package:uniride/widgets/auth_check.dart';

class DetalhesCaronaPage extends StatefulWidget {
  final Carona carona;
  final Aluno aluno;
  final Instituicao destino;
  final Passageiro passageiro;

  const DetalhesCaronaPage({
    Key? key,
    required this.carona,
    required this.aluno,
    required this.destino,
    required this.passageiro,
  }) : super(key: key);

  @override
  _DetalhesCaronaPageState createState() => _DetalhesCaronaPageState();
}

class _DetalhesCaronaPageState extends State<DetalhesCaronaPage> {
  AlunoDAO alunoDAO = AlunoDAO();
  FirebaseStorage storage = FirebaseStorage.instance;
  bool uploading = false;
  double total = 0;
  List<Reference> refs = [];
  String? imagem;
  bool loading = true;
  String? imageUrl;
  List<bool> diasPassageiro = List.generate(6, (index) => false);
  bool selecionou = false;
  bool confirmouUniversidade = true;

  loadImage() async {
    String imageName = "${widget.carona.motorista.id}.jpg";
    try {
      final ref = storage.ref("images/profile/$imageName");
      imagem = await ref.getDownloadURL();
      setState(() {
        imageUrl = imagem;
        loading = false;
      });
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
    Carona carona = widget.carona;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carona'),
        backgroundColor: const Color(0xFF186A11),
        centerTitle: true,
      ),
      body: Center(
        child: FutureBuilder<Aluno?>(
          future: alunoDAO.retrieve(carona.motorista.id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text("Erro: ${snapshot.error}");
            } else if (!snapshot.hasData) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Erro ao adquirir dados da carona"),
                    Text("Tente novamente mais tarde"),
                  ],
                ),
              );
            } else if (snapshot.data == null) {
              return const Text("Ta null");
            } else {
              final Aluno motorista = snapshot.data!;
              return SingleChildScrollView(
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
                        ],
                      ),
                    ),
                    const Divider(color: Colors.black),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 1.25,
                      child: Column(
                        children: [
                          const Text(
                            "Motorista",
                            style: TextStyle(
                              fontFamily: "Inter",
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 40),
                          (imageUrl == null)
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
                                    imageUrl!,
                                    width: 90,
                                    height: 90,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                          const SizedBox(height: 20),
                          Column(
                            children: [
                              Text(
                                motorista.nome,
                                style: const TextStyle(
                                  fontFamily: "Inter",
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                              const SizedBox(height: 15),
                              Text(
                                (motorista.avaliacoes.isEmpty)
                                    ? "Nenhuma avaliação"
                                    : "Avaliação: ${motorista.somaAvaliacoes / motorista.avaliacoes.length}",
                                style: const TextStyle(
                                  fontFamily: "InterLight",
                                  fontSize: 20,
                                ),
                              )
                            ],
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
                                  builder: (_) => PerfilAlunoPage(
                                    alunoPerfil: motorista,
                                  ),
                                ),
                              );
                            },
                            child: const Text(
                              "Ver perfil",
                              style:
                                  TextStyle(fontFamily: "Inter", fontSize: 18),
                            ),
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                        ],
                      ),
                    ),
                    const Divider(color: Colors.black),
                    const SizedBox(
                      height: 30,
                    ),
                    const Text(
                      "Informações da carona",
                      style: TextStyle(
                        fontFamily: "Inter",
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 1.2,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                widget.carona
                                    .horaToString(widget.carona.horaSaida),
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
                                    : widget.carona.passageiros.length
                                        .toString(),
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
                    const SizedBox(height: 50),
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF186A11),
                          minimumSize: const Size(140, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        onPressed: () async {
                          await confirmarDias(context, carona);
                          if (widget.aluno.instituicao.id !=
                              widget.carona.destino.id) {
                            await confirmaUniversidade(context);
                          }
                          if (selecionou) {
                            if (confirmouUniversidade) {
                              widget.passageiro.carona = widget.carona.id;
                              widget.passageiro.diasCarona = diasPassageiro;
                              await widget.aluno
                                  .solicitaCarona(carona, widget.passageiro);
                              PassageiroDAO passageiroDAO = PassageiroDAO();
                              await passageiroDAO.create(
                                  widget.passageiro, widget.aluno);
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Carona solicitada")));
                              Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                      builder: (_) => const AuthCheck()),
                                  (route) => false);
                            }
                          }
                        },
                        child: const Text(
                          "Solicitar carona",
                          style: TextStyle(fontFamily: "Inter", fontSize: 18),
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Future<void> confirmarDias(BuildContext context, Carona carona) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Selecionar dias da semana",
            style: TextStyle(
              fontFamily: "Inter",
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(carona.diasCarona.length, (index) {
                  final dia = Utils.getDias(index);
                  final isDayEnabled = carona.diasCarona[index];

                  return CheckboxListTile(
                    title: Text(dia),
                    value: isDayEnabled && diasPassageiro[index],
                    onChanged: (bool? value) {
                      if (isDayEnabled) {
                        setState(() {
                          diasPassageiro[index] = value!;
                        });
                      }
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                    secondary: !isDayEnabled
                        ? const Icon(Icons.block, color: Colors.grey)
                        : null,
                  );
                }),
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                "Cancelar",
                style: TextStyle(
                  fontFamily: "Inter",
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                for (var dia in diasPassageiro) {
                  if (dia) {
                    setState(
                      () {
                        selecionou = true;
                      },
                    );
                  }
                }
                if (selecionou == true) {
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Selecione pelo menos um dia da semana",
                        style: TextStyle(
                          fontFamily: "Inter",
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }
              },
              child: const Text(
                "Confirmar",
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
            "A instituição de destino dessa carona não é a mesma que a sua, deseja continuar mesmo assim?",
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

  Future<bool?> pedirOutra(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "",
            style: TextStyle(
              fontFamily: "Inter",
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            "A instituição de destino dessa carona não é a mesma que a sua, deseja continuar mesmo assim?",
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
