import 'package:flutter/material.dart';
import 'package:uniride/DAO/passageiro_dao.dart';
import 'package:uniride/model/aluno.dart';
import 'package:uniride/model/carona.dart';
import 'package:uniride/model/passageiro.dart';
import 'package:uniride/view/carona_solicitada_page.dart';

class WidgetCaronaSolicitadaModel extends StatefulWidget {
  final Carona carona;
  final Aluno aluno;
  final String passageiroId;
  const WidgetCaronaSolicitadaModel(
      {Key? key,
      required this.carona,
      required this.aluno,
      required this.passageiroId})
      : super(key: key);

  @override
  _WidgetCaronaSolicitadaModelState createState() =>
      _WidgetCaronaSolicitadaModelState();
}

class _WidgetCaronaSolicitadaModelState
    extends State<WidgetCaronaSolicitadaModel> {
  final partida = TextEditingController();
  var isPassageiro;
  Passageiro? passageiro;
  final PassageiroDAO passageiroDAO = PassageiroDAO();
  bool loading = false;

  @override
  void initState() {
    super.initState();
    ePassageiro();
    loadPassageiro();
  }

  void loadPassageiro() async {
    setState(() {
      loading = true;
    });
    Passageiro? passBanco = await passageiroDAO.retrieve(widget.passageiroId);
    if (passBanco != null) {
      setState(() {
        passageiro = passBanco;
      });
    }
    setState(() {
      loading = false;
    });
  }

  void ePassageiro() {
    for (var interessado in widget.carona.interessados) {
      if (interessado.id == widget.passageiroId) {
        setState(() {
          isPassageiro = false;
        });
      }
    }
    for (var passageiro in widget.carona.passageiros) {
      if (passageiro.id == widget.passageiroId) {
        setState(() {
          isPassageiro = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return (loading)
        ? const CircularProgressIndicator()
        : InkWell(
            onTap: () async {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CaronaSolicitadaPage(
                    aluno: passageiro!,
                    carona: widget.carona,
                    isPassageiro: isPassageiro,
                  ),
                ),
              );
            },
            child: Container(
              width: MediaQuery.of(context).size.width / 1.25,
              height: MediaQuery.of(context).size.height / 6,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Row(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width / 11,
                    height: MediaQuery.of(context).size.height / 6,
                    decoration: BoxDecoration(
                      color: (isPassageiro)
                          ? const Color(0xFF186A11)
                          : (widget.carona.vagasRestantes < 1)
                              ? Colors.amber[700]
                              : Colors.yellow,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(11.5),
                        bottomLeft: Radius.circular(11.5),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  (isPassageiro)
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 1.60,
                              child: Text(
                                widget.carona.destino.descricao,
                                style: const TextStyle(
                                  fontFamily: "InterLight",
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                softWrap: true,
                              ),
                            ),
                            Text(
                              "R\$ ${(widget.carona.preco / (widget.carona.passageiros.length + 1)).toStringAsFixed(2)}",
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
                                    const Text("Hora de saída"),
                                    Text(
                                      widget.carona.horaToString(
                                          widget.carona.horaSaida),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  children: [
                                    const Text("Passageiros"),
                                    Text(
                                      widget.carona.passageiros.length
                                          .toString(),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  children: [
                                    const Text("Vagas"),
                                    Text(widget.carona.vagasRestantes
                                        .toString()),
                                  ],
                                ),
                              ],
                            )
                          ],
                        )
                      : (widget.carona.vagasRestantes < 1)
                          ? Center(
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width /
                                        1.60,
                                    child: Text(
                                      widget.carona.destino.descricao,
                                      style: const TextStyle(
                                        fontFamily: "InterLight",
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      softWrap: true,
                                    ),
                                  ),
                                  const Text(
                                    "Carona cheia",
                                    style: TextStyle(
                                      fontFamily: "InterLight",
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                const Text(
                                  "Aguardando confirmação",
                                  style: TextStyle(
                                    fontFamily: "Inter",
                                    fontSize: 12,
                                  ),
                                ),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width / 1.60,
                                  child: Text(
                                    widget.carona.destino.descricao,
                                    style: const TextStyle(
                                      fontFamily: "InterLight",
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    softWrap: true,
                                  ),
                                ),
                                Text(
                                  (widget.carona.passageiros.isEmpty)
                                      ? "R\$ ${(widget.carona.preco / 2).toStringAsFixed(2)}"
                                      : "R\$ ${(widget.carona.preco / (widget.carona.passageiros.length + 2)).toStringAsFixed(2)}",
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
                                        const Text("Hora de saída"),
                                        Text(
                                          widget.carona.horaToString(
                                              widget.carona.horaSaida),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 10),
                                    Column(
                                      children: [
                                        const Text("Passageiros"),
                                        Text(
                                          widget.carona.passageiros.length
                                              .toString(),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 10),
                                    Column(
                                      children: [
                                        const Text("Vagas"),
                                        Text(widget.carona.vagasRestantes
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
          );
  }
}
