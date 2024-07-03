import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uniride/DAO/aluno_dao.dart';
import 'package:uniride/model/aluno.dart';
import 'package:uniride/services/auth_service.dart';
import 'package:uniride/view/caronas_page.dart';
import 'package:uniride/view/perfil_page.dart';
import 'package:uniride/view/solicitacoes_page.dart';
import 'package:uniride/widgets/auth_check.dart';

class TelaInicialPage extends StatefulWidget {
  const TelaInicialPage({Key? key}) : super(key: key);

  @override
  _TelaInicialPageState createState() => _TelaInicialPageState();
}

class _TelaInicialPageState extends State<TelaInicialPage> {
  int _indexBottomBar = 0;

  @override
  Widget build(BuildContext context) {
    final AuthService auth = Provider.of<AuthService>(context);
    final AlunoDAO alunoDAO = AlunoDAO();
    return Scaffold(
      body: Center(
        child: FutureBuilder<Aluno?>(
          future: alunoDAO.retrieve(auth.usuario!.uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Erro ao obter informações da conta.",
                      style: TextStyle(
                        fontFamily: "Inter",
                        fontSize: 16,
                      ),
                    ),
                    TextButton(
                      child: const Text(
                        "Faça login novamente",
                        style: TextStyle(
                          fontFamily: "Inter",
                          fontSize: 16,
                        ),
                      ),
                      onPressed: () {
                        context.read<AuthService>().logout();
                      },
                    ),
                    Text("Erro: ${snapshot.error}")
                  ],
                ),
              );
            } else if (!snapshot.hasData || snapshot.data == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Erro ao obter informações da conta.",
                      style: TextStyle(
                        fontFamily: "Inter",
                        fontSize: 16,
                      ),
                    ),
                    TextButton(
                      child: const Text(
                        "Faça login novamente",
                        style: TextStyle(
                          fontFamily: "Inter",
                          fontSize: 16,
                        ),
                      ),
                      onPressed: () {
                        context.read<AuthService>().logout();
                      },
                    ),
                  ],
                ),
              );
            } else {
              final Aluno aluno = snapshot.data!;
              if (aluno.novoUsuario == true) {
                Future.delayed(Duration.zero, () {
                  tutorial(context, aluno);
                });
              }
              return IndexedStack(
                index: _indexBottomBar,
                children: <Widget>[
                  CaronasPage(aluno: aluno, auth: auth),
                  SolicitacoesPage(aluno: aluno, auth: auth),
                  PerfilPage(aluno: aluno, auth: auth),
                ],
              );
            }
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _indexBottomBar,
        onTap: (opcao) {
          setState(() {
            _indexBottomBar = opcao;
          });
        },
        iconSize: 32,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.car_repair),
            label: "Caronas",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_search),
            label: "Solicitações",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Perfil",
          ),
        ],
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(fontSize: 18.0),
        unselectedLabelStyle: const TextStyle(fontSize: 16.0),
      ),
    );
  }

  Future<void> tutorial(BuildContext context, Aluno aluno) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Antes de usar...",
            style: TextStyle(
              fontFamily: "Inter",
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const SingleChildScrollView(
            child: Text(
              " - Esse é um aplicativo feito para estudantes de universidades dividerem custos de locomoção para suas instituições. \n\n"
              " - O preço das caronas é dividido entre os passageiros e o motorista.\n\n"
              " - Faça upload de seu comprovante de matrícula para comprovar sua identidade.\n\n"
              " - Para oferecer uma carona você deve ir na opção ''Oferecer carona'', colocar o horário que você irá começar o trajeto, horário de sua aula, seu local de partida e os dias que você irá para a instituição.\n\n"
              " - Para pedir uma carona, você deve ir na opção ''Solicitar carona'', colocar o local que você deseja pegar a carona, horário de aula e então escolher a melhor carona para você.",
              style: TextStyle(
                fontFamily: "Inter",
                fontSize: 16,
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                AlunoDAO alunoDAO = AlunoDAO();
                await alunoDAO.updateStatus(aluno);
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (_) => const AuthCheck(),
                  ),
                  (Route<dynamic> route) => false,
                );
              },
              child: const Text(
                "Entendi",
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
