import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uniride/DAO/aluno_dao.dart';
import 'package:uniride/DAO/veiculo_dao.dart';
import 'package:uniride/model/aluno.dart';
import 'package:uniride/model/veiculo.dart';

class AuthException implements Exception {
  String message;
  AuthException(this.message);
}

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? usuario;
  bool isLoading = true;

  AuthService() {
    _authCheck();
  }

  _authCheck() {
    _auth.authStateChanges().listen((User? user) {
      if (user == null) {
        usuario = null;
      } else {
        usuario = user;
      }
      isLoading = false;
      notifyListeners();
    });
  }

  _getUser() {
    usuario = _auth.currentUser;
    notifyListeners();
  }

  registrar(Aluno aluno, AuthService auth, Veiculo veiculo) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: aluno.email, password: aluno.senha);
      _getUser();
      if (veiculo.tipoVeiculo.isNotEmpty) {
        VeiculoDAO veiculoDAO = VeiculoDAO();
        await veiculoDAO.create(veiculo, aluno, auth.usuario!.uid);
        aluno.veiculo = veiculo;
      }
      AlunoDAO alunoDAO = AlunoDAO();
      await alunoDAO.create(aluno, auth.usuario!.uid);
      await _auth.signOut();
      throw AuthException("Conta criada");
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw AuthException('A senha é muito fraca');
      } else if (e.code == 'email-already-in-use') {
        throw AuthException('E-mail já cadastrado');
      }
    }
  }

  login(String login, String senha) async {
    try {
      await _auth.signInWithEmailAndPassword(email: login, password: senha);
      _getUser();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw AuthException('E-mail ou senha incorretos');
      } else if (e.code == 'wrong-password') {
        throw AuthException('E-mail ou senha incorretos');
      }
    }
  }

  recuperarSenha(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      
    } on FirebaseAuthException catch (e) {
      print(e);
    }
  }

  logout() async {
    await _auth.signOut();
    _getUser();
  }
}
