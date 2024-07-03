import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uniride/DAO/aluno_dao.dart';
import 'package:uniride/DAO/veiculo_dao.dart';
import 'package:uniride/model/aluno.dart';
import 'package:uniride/model/veiculo.dart';
import 'package:uniride/services/auth_service.dart';
import 'package:uniride/widgets/auth_check.dart';

class CadastroVeiculoPage extends StatefulWidget {
  final AuthService auth;
  final Aluno aluno;
  const CadastroVeiculoPage({Key? key, required this.aluno, required this.auth})
      : super(key: key);

  @override
  State<CadastroVeiculoPage> createState() => _CadastroVeiculoPageState();
}

class _CadastroVeiculoPageState extends State<CadastroVeiculoPage> {
  final db = FirebaseFirestore.instance;
  final formKey = GlobalKey<FormState>();
  final tipoVeiculo = TextEditingController();
  final modeloVeiculo = TextEditingController();
  final placaVeiculo = TextEditingController();
  final corVeiculo = TextEditingController();

  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Cadastro de Veículo",
          style: TextStyle(fontSize: 23),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF186A11),
      ),
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
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 1.5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Informações do veículo",
                          style: TextStyle(fontFamily: "Inter", fontSize: 18),
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
                            if (tipoVeiculo.text.isEmpty) {
                              return "Informe o tipo de veículo";
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
                            if (modeloVeiculo.text.isEmpty) {
                              return "Informe o modelo do veículo";
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
                            if (placaVeiculo.text.isEmpty) {
                              return "Informe a placa do veículo";
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
                            if (corVeiculo.text.isEmpty) {
                              return "Informe a cor do veículo";
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
                        VeiculoDAO veiculoDAO = VeiculoDAO();
                        AlunoDAO alunoDAO = AlunoDAO();

                        Veiculo veiculo = Veiculo(
                          id: widget.aluno.id,
                          tipoVeiculo: tipoVeiculo.text,
                          modelo: modeloVeiculo.text,
                          placa: placaVeiculo.text,
                          cor: corVeiculo.text,
                        );

                        widget.aluno.veiculo = veiculo;

                        try {
                          await veiculoDAO.create(
                              veiculo, widget.aluno, veiculo.id);
                          await alunoDAO.update(widget.aluno);
                          Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                      builder: (_) => const AuthCheck()),
                                  (route) => false);
                        } catch (e) {
                          erro(context);
                        }
                      } else {
                        preencher(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(120, 60),
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
                            'Cadastrar veículo',
                            style: TextStyle(fontSize: 20, fontFamily: 'Inter'),
                          ),
                  ),
                  const SizedBox(height: 45),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

void preencher(BuildContext context) {
  final snackBar = SnackBar(content: Text('Preencha os campo obrigatórios'));
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

void erro(BuildContext context) {
  final snackBar = SnackBar(content: Text('Erro ao cadastrar'));
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
