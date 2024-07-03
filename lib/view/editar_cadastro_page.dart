import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:provider/provider.dart';
import 'package:uniride/DAO/aluno_dao.dart';
import 'package:uniride/DAO/instituicao_dao.dart';
import 'package:uniride/DAO/veiculo_dao.dart';
import 'package:uniride/model/instituicao.dart';
import 'package:uniride/model/aluno.dart';
import 'package:uniride/model/veiculo.dart';
import 'package:uniride/services/auth_service.dart';
import 'package:uniride/utils/utils.dart';
import 'package:uniride/widgets/auth_check.dart';

class EditarCadastroPage extends StatefulWidget {
  final Aluno aluno;
  const EditarCadastroPage({Key? key, required this.aluno}) : super(key: key);

  @override
  _EditarCadastroPageState createState() => _EditarCadastroPageState();
}

class _EditarCadastroPageState extends State<EditarCadastroPage> {
  final db = FirebaseFirestore.instance;
  final formKey = GlobalKey<FormState>();
  final nomeForm = TextEditingController();
  final dataForm = TextEditingController();
  var sexoForm;
  final emailForm = TextEditingController();
  final foneForm = TextEditingController();
  final senhaForm = TextEditingController();
  var institutoForm;
  final matriculaForm = TextEditingController();
  final novaSenhaForm = TextEditingController();
  final confirmaSenha = TextEditingController();
  final tipoVeiculoForm = TextEditingController();
  final modeloVeiculoForm = TextEditingController();
  final placaVeiculoForm = TextEditingController();
  final corVeiculoForm = TextEditingController();

  bool loading = false;

  final dropValue = ValueNotifier('');
  final dropOpcoesSexo = ['Masculino', 'Feminino'];

  @override
  Widget build(BuildContext context) {
    AuthService auth = Provider.of<AuthService>(context);
    AlunoDAO alunoDAO = AlunoDAO();
    Aluno aluno = widget.aluno;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Editar Usuário",
          style: TextStyle(fontSize: 23),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF186A11),
      ),
      body: Center(
        child: FutureBuilder<Aluno?>(
          future: alunoDAO.retrieve(auth.usuario!.uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Erro ao carregar dados do aluno: ${snapshot.error}');
            } else {
              nomeForm.text = aluno.nome;
              dataForm.text = aluno.dataNascimento;
              emailForm.text = aluno.email;
              foneForm.text = aluno.numeroTelefone;
              matriculaForm.text = aluno.numeroMatricula;
              if (aluno.veiculo != null) {
                tipoVeiculoForm.text = aluno.veiculo!.tipoVeiculo;
                modeloVeiculoForm.text = aluno.veiculo!.modelo;
                placaVeiculoForm.text = aluno.veiculo!.placa;
                corVeiculoForm.text = aluno.veiculo!.cor;
              }

              return Scaffold(
                body: SingleChildScrollView(
                  child: Center(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width / 1.5,
                      child: Form(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(
                              height: 50,
                            ),
                            TextFormField(
                              onTapOutside: (event) {
                                nomeForm.text = nomeForm.text;
                                FocusScope.of(context).unfocus();
                              },
                              onChanged: (newValue) {
                                aluno.nome = newValue;
                              },
                              controller: nomeForm,
                              decoration: const InputDecoration(
                                labelText: "Nome Completo",
                              ),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Preencha o nome';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            TextFormField(
                              onTapOutside: (event) =>
                                  FocusScope.of(context).unfocus(),
                              controller: dataForm,
                              onChanged: (newValue) {
                                aluno.dataNascimento = newValue;
                              },
                              decoration: const InputDecoration(
                                labelText: "Data de nascimento",
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9]')),
                                LengthLimitingTextInputFormatter(8),
                                MaskTextInputFormatter(
                                    mask: "##/##/####",
                                    filter: {"#": RegExp(r"[0-9]")}),
                              ],
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Preencha a data';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            TapRegion(
                              onTapOutside: (event) =>
                                  FocusScope.of(context).unfocus(),
                              child: ValueListenableBuilder(
                                valueListenable: dropValue,
                                builder:
                                    (BuildContext context, String value, _) {
                                  return DropdownButtonFormField<String>(
                                    hint: const Text("Sexo"),
                                    value: sexoForm,
                                    onChanged: (escolha) {
                                      dropValue.value = escolha.toString();
                                      sexoForm = escolha.toString();
                                    },
                                    items: dropOpcoesSexo
                                        .map(
                                          (op) => DropdownMenuItem(
                                            value: op,
                                            child: Text(op),
                                          ),
                                        )
                                        .toList(),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            TextFormField(
                              onTapOutside: (event) =>
                                  FocusScope.of(context).unfocus(),
                              controller: foneForm,
                              onChanged: (newValue) {
                                aluno.numeroTelefone = newValue;
                              },
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: false),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9]')),
                                LengthLimitingTextInputFormatter(14),
                                MaskTextInputFormatter(
                                    mask: "(##)#####-####",
                                    filter: {"#": RegExp(r"[0-9]")}),
                              ],
                              decoration: const InputDecoration(
                                labelText: "Telefone",
                              ),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Preencha o telefone';
                                } else if (value.length < 10) {
                                  return 'Insira o número com DDD';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('instituicao')
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return const CircularProgressIndicator();
                                }

                                List<String> institutos = [];

                                for (var doc in snapshot.data!.docs) {
                                  institutos.add(doc['descricao']);
                                }

                                return TapRegion(
                                  onTapOutside: (event) =>
                                      FocusScope.of(context).unfocus(),
                                  child: StreamBuilder<QuerySnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection('instituicao')
                                        .snapshots(),
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData) {
                                        return const CircularProgressIndicator();
                                      }

                                      List<String> institutos = [];

                                      for (var doc in snapshot.data!.docs) {
                                        institutos.add(doc['descricao']);
                                      }

                                      return TapRegion(
                                        onTapOutside: (event) =>
                                            FocusScope.of(context).unfocus(),
                                        child: DropdownButtonFormField<String>(
                                          isExpanded: true,
                                          decoration: const InputDecoration(
                                              labelText:
                                                  "Instituição de Ensino"),
                                          value: institutoForm,
                                          onChanged: (institutoSelecionado) {
                                            setState(() {
                                              institutoForm =
                                                  institutoSelecionado!;
                                            });
                                          },
                                          items: institutos
                                              .map<DropdownMenuItem<String>>(
                                                  (String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value),
                                            );
                                          }).toList(),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            TextFormField(
                              onTapOutside: (event) =>
                                  FocusScope.of(context).unfocus(),
                              controller: matriculaForm,
                              onChanged: (newValue) {
                                aluno.numeroMatricula = newValue;
                              },
                              decoration: const InputDecoration(
                                labelText: "Número de matrícula",
                              ),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Preencha a matrícula';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(
                              height: 45,
                            ),
                            (widget.aluno.veiculo == null)
                                ? const SizedBox()
                                : SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width / 1.5,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "Informações do veículo (opcional)",
                                          style: TextStyle(
                                              fontFamily: "Inter",
                                              fontSize: 18),
                                        ),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        TextFormField(
                                          onTapOutside: (event) =>
                                              FocusScope.of(context).unfocus(),
                                          controller: tipoVeiculoForm,
                                          decoration: const InputDecoration(
                                            labelText: "Tipo de veículo",
                                          ),
                                          onChanged: (newValue) {
                                            aluno.veiculo!.tipoVeiculo =
                                                newValue;
                                          },
                                          validator: (value) {
                                            if (tipoVeiculoForm
                                                .text.isNotEmpty) {
                                              if (modeloVeiculoForm
                                                  .text.isEmpty) {
                                                return 'Informe o modelo de veículo';
                                              } else if (placaVeiculoForm
                                                  .text.isEmpty) {
                                                return 'Informe a placa do veículo';
                                              } else if (corVeiculoForm
                                                  .text.isEmpty) {
                                                return 'Informe a cor do veículo';
                                              }
                                            }
                                            return null;
                                          },
                                        ),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        TextFormField(
                                          onTapOutside: (event) =>
                                              FocusScope.of(context).unfocus(),
                                          controller: modeloVeiculoForm,
                                          decoration: const InputDecoration(
                                            labelText: "Modelo",
                                          ),
                                          onChanged: (newValue) {
                                            aluno.veiculo!.modelo = newValue;
                                          },
                                          validator: (value) {
                                            if (modeloVeiculoForm
                                                .text.isNotEmpty) {
                                              if (tipoVeiculoForm
                                                  .text.isEmpty) {
                                                return 'Informe o tipo de veículo';
                                              } else if (placaVeiculoForm
                                                  .text.isEmpty) {
                                                return 'Informe a placa do veículo';
                                              } else if (corVeiculoForm
                                                  .text.isEmpty) {
                                                return 'Informe a cor do veículo';
                                              }
                                            }
                                            return null;
                                          },
                                        ),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        TextFormField(
                                          onTapOutside: (event) =>
                                              FocusScope.of(context).unfocus(),
                                          controller: placaVeiculoForm,
                                          decoration: const InputDecoration(
                                            labelText: "Placa",
                                          ),
                                          onChanged: (newValue) {
                                            aluno.veiculo!.placa = newValue;
                                          },
                                          validator: (value) {
                                            if (placaVeiculoForm
                                                .text.isNotEmpty) {
                                              if (modeloVeiculoForm
                                                  .text.isEmpty) {
                                                return 'Informe o modelo de veículo';
                                              } else if (tipoVeiculoForm
                                                  .text.isEmpty) {
                                                return 'Informe o tipo de veículo';
                                              } else if (corVeiculoForm
                                                  .text.isEmpty) {
                                                return 'Informe a cor do veículo';
                                              }
                                            }
                                            return null;
                                          },
                                        ),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        TextFormField(
                                          onTapOutside: (event) =>
                                              FocusScope.of(context).unfocus(),
                                          controller: corVeiculoForm,
                                          decoration: const InputDecoration(
                                            labelText: "Cor",
                                          ),
                                          onChanged: (newValue) {
                                            aluno.veiculo!.cor = newValue;
                                          },
                                          validator: (value) {
                                            if (corVeiculoForm
                                                .text.isNotEmpty) {
                                              if (modeloVeiculoForm
                                                  .text.isEmpty) {
                                                return 'Informe o modelo de veículo';
                                              } else if (placaVeiculoForm
                                                  .text.isEmpty) {
                                                return 'Informe a placa do veículo';
                                              } else if (tipoVeiculoForm
                                                  .text.isEmpty) {
                                                return 'Informe o tipo de veículo';
                                              }
                                            }
                                            return null;
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                            const SizedBox(height: 45),
                            ElevatedButton(
                              onPressed: () async {
                                if (formKey.currentState!.validate()) {
                                  setState(() => loading = true);

                                  if (aluno.veiculo == null) {
                                    if (tipoVeiculoForm.text.isNotEmpty ||
                                        modeloVeiculoForm.text.isNotEmpty ||
                                        placaVeiculoForm.text.isNotEmpty ||
                                        corVeiculoForm.text.isNotEmpty) {
                                      VeiculoDAO veiculoDAO = VeiculoDAO();
                                      Veiculo veiculo = Veiculo(
                                        id: aluno.id,
                                        tipoVeiculo: tipoVeiculoForm.text,
                                        modelo: modeloVeiculoForm.text,
                                        placa: placaVeiculoForm.text,
                                        cor: corVeiculoForm.text,
                                      );
                                      veiculoDAO.create(
                                          veiculo, aluno, aluno.id);
                                      aluno.veiculo = veiculo;
                                    }
                                  } else {
                                    VeiculoDAO veiculoDAO = VeiculoDAO();
                                    Veiculo veiculo = Veiculo(
                                      id: aluno.id,
                                      tipoVeiculo: tipoVeiculoForm.text,
                                      modelo: modeloVeiculoForm.text,
                                      placa: placaVeiculoForm.text,
                                      cor: corVeiculoForm.text,
                                    );
                                    veiculoDAO.update(veiculo);
                                  }

                                  InstituicaoDAO instituicaoDAO =
                                      InstituicaoDAO();

                                  Instituicao? instituicao =
                                      await instituicaoDAO
                                          .retrieveDescricao(institutoForm);

                                  if (dataForm.text.contains("/")) {
                                    dataForm.text =
                                        Utils.tiraBarra(dataForm.text);
                                  }

                                  aluno.nome = nomeForm.text;
                                  aluno.email = emailForm.text;
                                  aluno.sexo = sexoForm;
                                  aluno.dataNascimento =
                                      Utils.stringToDate(dataForm.text);
                                  aluno.numeroMatricula = matriculaForm.text;
                                  aluno.numeroTelefone = foneForm.text;
                                  aluno.instituicao = instituicao!;

                                  await alunoDAO.update(aluno);

                                  setState(() => loading = false);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Cadastro alterado"),
                                    ),
                                  );
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                      builder: (_) => const AuthCheck(),
                                    ),
                                    (Route<dynamic> route) => false,
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              "Preencha os campos obrigatórios")));
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(70, 40),
                                  backgroundColor: const Color(0xFF186A11)),
                              child: (loading)
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'Alterar cadastro',
                                      style: TextStyle(
                                          fontSize: 15, fontFamily: 'Inter'),
                                    ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
