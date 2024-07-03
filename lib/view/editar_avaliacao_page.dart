import 'package:flutter/material.dart';
import 'package:uniride/DAO/avaliacao_dao.dart';
import 'package:uniride/model/aluno.dart';
import 'package:uniride/model/avaliacao.dart';

class EditarAvaliacaoPage extends StatefulWidget {
  final Aluno avaliador;
  final Aluno avaliado;
  const EditarAvaliacaoPage(
      {Key? key, required this.avaliador, required this.avaliado})
      : super(key: key);

  @override
  _EditarAvaliacaoPageState createState() => _EditarAvaliacaoPageState();
}

class _EditarAvaliacaoPageState extends State<EditarAvaliacaoPage> {
  var comentarioForm = TextEditingController();
  var avaliadorForm = TextEditingController();
  var avaliadoForm = TextEditingController();
  bool anonimo = false;

  double nota = 0.0;
  var loading = false;
  AvaliacaoDAO avaliacaoDAO = AvaliacaoDAO();
  Avaliacao? avaliacao;

  @override
  void initState() {
    super.initState();
    loadAvaliacao();
  }

  void loadAvaliacao() async {
    setState(() {
      loading = true;
    });
    Avaliacao? avaliacaoBanco = await avaliacaoDAO.retrieveByIDS(
        avaliadoId: widget.avaliado.id, avaliadorId: widget.avaliador.id);
    if (mounted) {
      if (avaliacaoBanco != null) {
        setState(
          () {
            avaliacao = avaliacaoBanco;
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
    avaliadorForm.text = "Avaliador: ${widget.avaliador.nome}";
    avaliadoForm.text = "Avaliado: ${widget.avaliado.nome}";
    return Scaffold(
      appBar: AppBar(
        title: const Text('Avaliar usuário'),
        centerTitle: true,
        backgroundColor: const Color(0xFF186A11),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width / 1.5,
            child: (loading == true)
                ? const CircularProgressIndicator()
                : (avaliacao == null)
                    ? const Text("Avaliação não existe")
                    : Column(
                        children: [
                          Form(
                            child: Column(
                              children: [
                                const SizedBox(height: 30),
                                TextFormField(
                                  enabled: false,
                                  controller: avaliadorForm,
                                ),
                                const SizedBox(height: 30),
                                TextFormField(
                                  enabled: false,
                                  controller: avaliadoForm,
                                ),
                                const SizedBox(height: 30),
                                Text(
                                  "Nota: ${nota.toStringAsFixed(1)}",
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontFamily: "Inter",
                                  ),
                                ),
                                Slider(
                                  value: nota,
                                  min: 0,
                                  max: 5,
                                  divisions: 10,
                                  onChanged: (notaFinal) {
                                    setState(() {
                                      nota = notaFinal;
                                    });
                                  },
                                ),
                                const SizedBox(height: 30),
                              ],
                            ),
                          ),
                          TextField(
                            onTapOutside: (event) =>
                                FocusScope.of(context).unfocus(),
                            controller: comentarioForm,
                            maxLines: null,
                            decoration: const InputDecoration(
                              labelText: 'Deixe um comentário (opcional)',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 30),
                          Row(
                            children: [
                              Checkbox(
                                value: anonimo,
                                onChanged: (checked) {
                                  setState(
                                    () {
                                      anonimo = !anonimo;
                                    },
                                  );
                                },
                              ),
                              const Text("Avaliação anônima",
                                  style: TextStyle(
                                    fontFamily: "Inter",
                                    fontSize: 20,
                                  ))
                            ],
                          ),
                          const SizedBox(height: 30),
                          ElevatedButton(
                            onPressed: () async {
                              widget.avaliado.somaAvaliacoes -= avaliacao!.nota;
                              avaliacao!.nota = nota;
                              avaliacao!.comentario = comentarioForm.text;
                              avaliacao!.anonimo = anonimo;

                              widget.avaliador
                                  .editaAvaliacao(widget.avaliado, avaliacao!);
                              Navigator.of(context).pop(true);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF186A11),
                              minimumSize: const Size(140, 70),
                              maximumSize: const Size(250, 80),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                            child: const Text(
                              "Avaliar",
                              style: TextStyle(
                                fontSize: 20,
                                fontFamily: "Inter",
                              ),
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
}
