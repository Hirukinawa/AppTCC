import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uniride/services/auth_service.dart';
import 'package:uniride/view/cadastro_page.dart';
import 'package:uniride/view/recuperar_senha_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  final loginForm = TextEditingController();
  final senhaForm = TextEditingController();

  bool loading = false;

  bool _isButtonEnabled() {
    return loginForm.text.isNotEmpty && senhaForm.text.isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
  }

  login() async {
    setState(() => loading = true);
    try {
      await context.read<AuthService>().login(loginForm.text, senhaForm.text);
    } on AuthException catch (e) {
      if (mounted) {
        setState(() => loading = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("UniRide"),
        centerTitle: true,
        backgroundColor: const Color(0xFF186A11),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Center(
            child: Column(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width / 1.5,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      imageCar,
                      Column(
                        children: [
                          TextFormField(
                            onTapOutside: (event) =>
                                FocusScope.of(context).unfocus(),
                            controller: loginForm,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: "E-mail",
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Preencha o login';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(
                            height: 30,
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
                                return 'Informe a senha';
                              } else if (value.length < 6) {
                                return 'A senha deve conter no mínimo 6 caracteres!';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 30),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (_) => const RecuperarSenhaPage()));
                            },
                            child: const Text(
                              "Esqueci minha senha",
                              style: TextStyle(
                                color: Color(0xFF186A11),
                                fontFamily: 'InterLight',
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 1.5,
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 30,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            login();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isButtonEnabled()
                              ? const Color(0xFF186A11)
                              : Colors.grey,
                          minimumSize: const Size(100, 50),
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
                                "Entrar",
                                style: TextStyle(
                                  fontFamily: 'InterLight',
                                  fontSize: 20,
                                ),
                              ),
                      ),
                      const SizedBox(
                        height: 45,
                      ),
                      const Text(
                        "Não tem uma conta?",
                        style: TextStyle(
                          fontFamily: 'InterLight',
                          fontSize: 20,
                          color: Colors.black,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const CadastroPage(),
                            ),
                          );
                        },
                        child: const Text(
                          'Faça seu cadastro',
                          style: TextStyle(
                            fontFamily: 'InterLight',
                            fontSize: 20,
                            color: Color(0xFF186A11),
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
      ),
    );
  }
}

AssetImage assetImageCar = const AssetImage('assets/images/green_car_logo.png');
Image imageCar =
    Image(image: assetImageCar, width: 200, height: 200, fit: BoxFit.cover);
