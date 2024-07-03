import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:uniride/DAO/instituicao_dao.dart';
import 'package:uniride/model/aluno.dart';
import 'package:uniride/model/avaliacao.dart';
import 'package:uniride/model/instituicao.dart';
import 'package:uniride/model/veiculo.dart';
import 'package:uniride/services/auth_service.dart';
import 'package:uniride/widgets/auth_check.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class CadastroPage extends StatefulWidget {
  const CadastroPage({Key? key}) : super(key: key);

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final db = FirebaseFirestore.instance;
  final formKey = GlobalKey<FormState>();
  final nomeForm = TextEditingController();
  final dataForm = TextEditingController();
  var sexoForm = null;
  final emailForm = TextEditingController();
  final foneForm = TextEditingController();
  final senhaForm = TextEditingController();
  var institutoForm = null;
  final matriculaForm = TextEditingController();
  final confirmaSenha = TextEditingController();
  final tipoVeiculo = TextEditingController();
  final modeloVeiculo = TextEditingController();
  final placaVeiculo = TextEditingController();
  final corVeiculo = TextEditingController();

  bool loading = false;

  final dropValue = ValueNotifier('');
  final dropOpcoesSexo = ['Masculino', 'Feminino'];

  registrar(Aluno aluno, AuthService auth, Veiculo veiculo,
      FirebaseFirestore db) async {
    setState(() => loading = true);
    try {
      await context.read<AuthService>().registrar(aluno, auth, veiculo);
      setState(() => loading = false);
    } on AuthException catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    AuthService auth = Provider.of<AuthService>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Cadastro de Aluno",
          style: TextStyle(fontSize: 23),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF186A11),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              SizedBox(
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
                        onTapOutside: (event) =>
                            FocusScope.of(context).unfocus(),
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
                        decoration: const InputDecoration(
                          labelText: "Data de nascimento",
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                          LengthLimitingTextInputFormatter(8),
                          MaskTextInputFormatter(
                              mask: "##/##/####",
                              filter: {"#": RegExp(r"[0-9]")}),
                        ],
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
                          builder: (BuildContext context, String value, _) {
                            return DropdownButtonFormField<String>(
                              hint: const Text("Sexo"),
                              value: (value.isEmpty) ? null : value,
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
                        controller: emailForm,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: "E-mail",
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Preencha o e-mail';
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
                        controller: foneForm,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: false),
                            inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                          LengthLimitingTextInputFormatter(12),
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
                          } else if (value.length < 14) {
                            return 'Insira o número com DDD';
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
                        controller: senhaForm,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: "Senha",
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Preencha a senha';
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
                        controller: confirmaSenha,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: "Confirmar senha",
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Preencha o login';
                          } else if (value.length < 6) {
                            return 'A senha deve conter no mínimo 6 caracteres!';
                          } else if (senhaForm.text.compareTo(value) != 0) {
                            return 'As senhas devem ser iguais';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
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
                                        labelText: "Instituição de Ensino"),
                                    value: institutoForm,
                                    onChanged: (institutoSelecionado) {
                                      setState(() {
                                        institutoForm = institutoSelecionado!;
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
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 1.5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Informações do veículo (opcional)",
                              style:
                                  TextStyle(fontFamily: "Inter", fontSize: 18),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            TextFormField(
                              onTapOutside: (event) =>
                                  FocusScope.of(context).unfocus(),
                              controller: tipoVeiculo,
                              decoration: const InputDecoration(
                                labelText: "Tipo de veículo",
                              ),
                              validator: (value) {
                                if (tipoVeiculo.text.isNotEmpty) {
                                  if (modeloVeiculo.text.isEmpty) {
                                    return 'Informe o modelo de veículo';
                                  } else if (placaVeiculo.text.isEmpty) {
                                    return 'Informe a placa do veículo';
                                  } else if (corVeiculo.text.isEmpty) {
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
                              controller: modeloVeiculo,
                              decoration: const InputDecoration(
                                labelText: "Modelo",
                              ),
                              validator: (value) {
                                if (modeloVeiculo.text.isNotEmpty) {
                                  if (tipoVeiculo.text.isEmpty) {
                                    return 'Informe o tipo de veículo';
                                  } else if (placaVeiculo.text.isEmpty) {
                                    return 'Informe a placa do veículo';
                                  } else if (corVeiculo.text.isEmpty) {
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
                              controller: placaVeiculo,
                              decoration: const InputDecoration(
                                labelText: "Placa",
                              ),
                              validator: (value) {
                                if (placaVeiculo.text.isNotEmpty) {
                                  if (modeloVeiculo.text.isEmpty) {
                                    return 'Informe o modelo de veículo';
                                  } else if (tipoVeiculo.text.isEmpty) {
                                    return 'Informe o tipo de veículo';
                                  } else if (corVeiculo.text.isEmpty) {
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
                              controller: corVeiculo,
                              decoration: const InputDecoration(
                                labelText: "Cor",
                              ),
                              validator: (value) {
                                if (corVeiculo.text.isNotEmpty) {
                                  if (modeloVeiculo.text.isEmpty) {
                                    return 'Informe o modelo de veículo';
                                  } else if (placaVeiculo.text.isEmpty) {
                                    return 'Informe a placa do veículo';
                                  } else if (tipoVeiculo.text.isEmpty) {
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
                            Veiculo veiculo = Veiculo.empty();

                            InstituicaoDAO instituicaoDAO = InstituicaoDAO();
                            Instituicao? instituicao = await instituicaoDAO
                                .retrieveDescricao(institutoForm);

                            veiculo.tipoVeiculo = tipoVeiculo.text;
                            veiculo.modelo = modeloVeiculo.text;
                            veiculo.placa = placaVeiculo.text;
                            veiculo.cor = corVeiculo.text;

                            List<String> caronas = [];

                            List<Avaliacao> avaliacoes = [];

                            Aluno aluno = Aluno(
                                id: "id",
                                nome: nomeForm.text,
                                senha: senhaForm.text,
                                email: emailForm.text,
                                sexo: sexoForm,
                                dataNascimento: dataForm.text,
                                numeroMatricula: matriculaForm.text,
                                numeroTelefone: foneForm.text,
                                somaAvaliacoes: 0,
                                instituicao: instituicao!,
                                caronas: caronas,
                                avaliacoes: avaliacoes,
                                novoUsuario: true);

                            try {
                              await registrar(aluno, auth, veiculo, db);

                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (_) => const AuthCheck(),
                                ),
                                (Route<dynamic> route) => false,
                              );
                            } catch (e) {
                              erro(context);
                            }
                          } else {
                            preencher(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(140, 50),
                          backgroundColor: const Color(0xFF186A11),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        child: (loading)
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Criar conta',
                                style: TextStyle(
                                    fontSize: 20, fontFamily: 'Inter'),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width / 1.25,
                child: Column(
                  children: [
                    const SizedBox(
                      height: 45,
                    ),
                    const Text(
                      'Não encontrou sua instituição? Envie a instituição e a cidade no formulário abaixo',
                      style: TextStyle(
                        fontFamily: 'InterLight',
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        var link =
                            Uri.parse("https://forms.gle/jMq3SYg9qPzv3aV37");
                        await launchUrl(link);
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(140, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Responder formulário',
                          style: TextStyle(
                            fontFamily: 'InterLight',
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void preencher(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Preencha os campos obrigatórios")));
}

void erro(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("Erro ao cadastrar, tente novamente mais tarde")));
}
