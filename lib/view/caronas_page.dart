import 'package:flutter/material.dart';
import 'package:uniride/DAO/carona_dao.dart';
import 'package:uniride/DAO/passageiro_dao.dart';
import 'package:uniride/model/aluno.dart';
import 'package:uniride/model/carona.dart';
import 'package:uniride/model/passageiro.dart';
import 'package:uniride/services/auth_service.dart';
import 'package:uniride/view/cadastro_veiculo_page.dart';
import 'package:uniride/view/carona_cadastrada_page.dart';
import 'package:uniride/view/criar_carona_page.dart';
import 'package:uniride/view/solicitar_carona_page.dart';
import 'package:uniride/widgets/widget_carona_solicitada_model.dart';

class CaronasPage extends StatefulWidget {
  final Aluno aluno;
  final AuthService auth;
  const CaronasPage({required this.aluno, required this.auth, super.key});

  @override
  State<CaronasPage> createState() => _CaronasPageState();
}

class _CaronasPageState extends State<CaronasPage> {
  List<Carona> caronasDoAluno = [];
  final CaronaDAO caronaDAO = CaronaDAO();
  final PassageiroDAO passageiroDAO = PassageiroDAO();
  Carona? carona;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    loadCarona();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void loadCarona() async {
    setState(() {
      loading = true;
    });
    Carona? caronaBanco = await caronaDAO.retrieve(widget.aluno.id);
    List<Carona> caronas = [];
    List<Passageiro> pass = [];
    for (var carona in widget.aluno.caronas) {
      Passageiro? passa = await passageiroDAO.retrieve(carona);
      if (passa != null) {
        pass.add(passa);
      }
    }
    for (var passageiro in pass) {
      Carona? caronaPass = await caronaDAO.retrieve(passageiro.carona);
      if (caronaPass != null) {
        caronas.add(caronaPass);
      }
    }
    if (mounted) {
      if (mounted) {
        setState(() {
          caronasDoAluno = caronas;
          loading = false;
        });
      }
      if (caronaBanco != null) {
        setState(
          () {
            carona = caronaBanco;
            loading = false;
          },
        );
      }
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Aluno aluno = widget.aluno;

    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Caronas')),
        centerTitle: true,
        backgroundColor: const Color(0xFF186A11),
      ),
      body: (loading == true)
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  Center(
                    child: (aluno.veiculo == null)
                        ? ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => CadastroVeiculoPage(
                                    aluno: widget.aluno,
                                    auth: widget.auth,
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 2, 197, 67),
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
                        : (carona != null)
                            ? Column(
                                children: [
                                  const Text(
                                    "Sua carona",
                                    style: TextStyle(
                                      fontFamily: "Inter",
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  InkWell(
                                    onTap: () async {
                                      var result = await Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => CaronaCadastradaPage(
                                              aluno: widget.aluno, carona: carona!),
                                        ),
                                      );
                                      if (result != null && result == true) {
                                        setState(() {
                                        });
                                      }
                                    },
                                    child: Container(
                                      width: MediaQuery.of(context).size.width /
                                          1.25,
                                      height:
                                          MediaQuery.of(context).size.height /
                                              6,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.black),
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                11,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                6,
                                            decoration: const BoxDecoration(
                                              color: Color(0xFF186A11),
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(11.5),
                                                bottomLeft:
                                                    Radius.circular(11.5),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 20),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    1.60,
                                                child: Text(
                                                  carona!.destino.descricao,
                                                  style: const TextStyle(
                                                    fontFamily: "InterLight",
                                                    fontSize: 18,
                                                  ),
                                                  softWrap: true,
                                                ),
                                              ),
                                              Text(
                                                "R\$ ${(carona!.preco).toStringAsFixed(2)}",
                                                style: const TextStyle(
                                                  fontFamily: "InterLight",
                                                  fontSize: 18,
                                                ),
                                              ),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                children: [
                                                  Column(
                                                    children: [
                                                      const Text(
                                                          "Hora de saída"),
                                                      Text(
                                                        carona!.horaToString(
                                                            carona!.horaSaida),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Column(
                                                    children: [
                                                      const Text("Passageiros"),
                                                      Text(
                                                        carona!
                                                            .passageiros.length
                                                            .toString(),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Column(
                                                    children: [
                                                      const Text("Vagas"),
                                                      Text(carona!
                                                          .vagasRestantes
                                                          .toString()),
                                                    ],
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          CriarCaronaPage(aluno: aluno),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF186A11),
                                  minimumSize: const Size(140, 60),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                ),
                                child: const Text(
                                  "Oferecer carona",
                                  style: TextStyle(
                                      fontFamily: "Inter", fontSize: 20),
                                ),
                              ),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => SolicitarCaronaPage(aluno: aluno),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF186A11),
                      minimumSize: const Size(140, 60),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    child: const Text(
                      "Solicitar carona",
                      style: TextStyle(fontFamily: "Inter", fontSize: 20),
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    "Suas solicitações",
                    style: TextStyle(
                      fontFamily: "Inter",
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 40),
                  (caronasDoAluno.isEmpty)
                      ? const Column(
                          children: [
                            Text(
                              "Você não solicitou",
                              style:
                                  TextStyle(fontFamily: "Inter", fontSize: 20),
                            ),
                            Text(
                              "nenhuma carona",
                              style:
                                  TextStyle(fontFamily: "Inter", fontSize: 20),
                            ),
                            SizedBox(height: 40),
                          ],
                        )
                      : Expanded(
                          child: ListView.builder(
                            itemCount: caronasDoAluno.length,
                            itemBuilder: (context, index) {
                              return Column(
                                children: [
                                  WidgetCaronaSolicitadaModel(
                                      carona: caronasDoAluno[index],
                                      aluno: widget.aluno,
                                      passageiroId:
                                          widget.aluno.caronas[index]),
                                  const SizedBox(height: 30),
                                ],
                              );
                            },
                          ),
                        ),
                ],
              ),
            ),
    );
  }
}
