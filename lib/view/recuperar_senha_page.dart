import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uniride/services/auth_service.dart';
import 'package:uniride/widgets/auth_check.dart';

class RecuperarSenhaPage extends StatefulWidget {
  const RecuperarSenhaPage({Key? key}) : super(key: key);

  @override
  State<RecuperarSenhaPage> createState() => _RecuperarSenhaPageState();
}

class _RecuperarSenhaPageState extends State<RecuperarSenhaPage> {
  final formKey = GlobalKey<FormState>();
  var emailForm = TextEditingController();
  bool loading = false;

  void esqueciSenha(String email) async {
    setState(() => loading = true);
    try {
      await context.read<AuthService>().recuperarSenha(email);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("E-mail enviado")));
      setState(() => loading = false);
    } on AuthException catch (e) {
      if (mounted) {
        setState(() => loading = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  bool _isButtonEnabled() {
    return emailForm.text.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Redefinir senha"),
        backgroundColor: const Color(0xFF186A11),
      ),
      body: Center(
          child: SizedBox(
        width: MediaQuery.of(context).size.width / 1.25,
        child: Form(
          key: formKey,
          child: Column(
            children: [
              const SizedBox(height: 30),
              TextFormField(
                onTapOutside: (event) => FocusScope.of(context).unfocus(),
                controller: emailForm,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: "Digite seu e-mail",
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Preencha o e-mail';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () async {
                  if (formKey.currentState!.validate() &&
                      emailForm.text.contains("@")) {
                    esqueciSenha(emailForm.text);
                    await showConfirmationDialog(context);
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const AuthCheck()),
                        (route) => false);
                  } else if (!emailForm.text.contains("@")) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Preencha o e-mail corretamente"),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isButtonEnabled()
                      ? const Color(0xFF186A11)
                      : Colors.grey,
                  minimumSize: const Size(100, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
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
                        "Recuperar senha",
                        style: TextStyle(
                          fontFamily: 'InterLight',
                          fontSize: 18,
                        ),
                      ),
              ),
            ],
          ),
        ),
      )),
    );
  }

  Future<bool?> showConfirmationDialog(
      BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("E-mail enviado",
            style: TextStyle(
              fontFamily: "Inter",
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),),
          content: const Text("Enviamos uma solicitação para trocar sua senha. Verifique sua caixa de e-mail.",
            style: TextStyle(
              fontFamily: "Inter",
              fontSize: 16,
            ),),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Ok",
                style: TextStyle(
                  fontFamily: "Inter",
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),),
            ),
            
          ],
        );
      },
    );
  }
}
