import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uniride/services/auth_service.dart';
import 'package:uniride/view/tela_inicial_page.dart';
import 'package:uniride/view/login_page.dart';

class AuthCheck extends StatefulWidget {
  const AuthCheck({Key? key}) : super(key: key);

  @override
  _AuthCheckState createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  @override
  Widget build(BuildContext context) {
    AuthService auth = Provider.of<AuthService>(context);

    if (auth.isLoading) {
      return loading();
    } else if (auth.usuario != null) {
      return const TelaInicialPage();
    } else {
      return const LoginPage();
    }
  }

  loading() {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
