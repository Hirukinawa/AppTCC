import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uniride/DAO/avaliacao_dao.dart';
import 'package:uniride/DAO/instituicao_dao.dart';
import 'package:uniride/DAO/veiculo_dao.dart';
import 'package:uniride/model/aluno.dart';
import 'package:uniride/model/avaliacao.dart';
import 'package:uniride/model/db_firestore.dart';
import 'package:uniride/model/instituicao.dart';
import 'package:uniride/model/veiculo.dart';
import 'package:uniride/services/auth_service.dart';

class AlunoDAO {
  late FirebaseFirestore db;
  late AuthService auth;

  AlunoDAO() {
    _startRepository();
  }

  _startRepository() async {
    await _startFirestore();
  }

  _startFirestore() {
    db = DBFirestore.get();
  }

  create(Aluno aluno, String id) async {
    List<String> avaliacoes = [];
    VeiculoDAO veiculoDAO = VeiculoDAO();
    Veiculo? veiculo = await veiculoDAO.retrieve(id);
    if (veiculo != null) {
      aluno.veiculo = veiculo;
    }
    await db.collection('aluno').doc(id).set({
      'id': id,
      'nome': aluno.nome,
      'email': aluno.email,
      'senha': aluno.senha,
      'sexo': aluno.sexo,
      'dataNascimento': aluno.dataNascimento,
      'numeroMatricula': aluno.numeroMatricula,
      'numeroTelefone': aluno.numeroTelefone,
      'avaliacoes': avaliacoes,
      'somaAvaliacoes': 0.0,
      'instituicao': aluno.instituicao.id,
      'veiculo': (veiculo == null) ? null : aluno.veiculo?.id,
      'caronas': aluno.caronas,
      'novoUsuario': true
    });
  }

  Future<Aluno?> retrieve(String id) async {
    try {
      final docSnapshot = await db.collection('aluno').doc(id).get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;

        List<String> caronas = (data['caronas'] as List<dynamic>?)
                ?.map((item) => item.toString())
                .toList() ??
            [];

        List<Avaliacao> avaliacoes = [];

        List<String?> avaliacoesIDs = (data['avaliacoes'] as List<dynamic>?)
                ?.map((item) => item.toString())
                .toList() ??
            [];

        for (var avaliacaoID in avaliacoesIDs) {
          var userSnapshot =
              await db.collection('avaliacao').doc(avaliacaoID).get();
          if (userSnapshot.exists) {
            AvaliacaoDAO avaliacaoDAO = AvaliacaoDAO();
            Avaliacao? avaliacao = await avaliacaoDAO.retrieve(avaliacaoID!);

            if (avaliacao != null) {
              avaliacoes.add(avaliacao);
            }
          }
        }

        InstituicaoDAO instituicaoDAO = InstituicaoDAO();
        VeiculoDAO veiculoDAO = VeiculoDAO();

        Instituicao? instituicao =
            await instituicaoDAO.retrieve(data['instituicao']);
        Veiculo? veiculo = await veiculoDAO.retrieve(data['id']);

        final aluno = Aluno(
          id: data['id'],
          nome: data['nome'],
          senha: data['senha'],
          email: data['email'],
          sexo: data['sexo'],
          dataNascimento: data['dataNascimento'],
          numeroMatricula: data['numeroMatricula'],
          numeroTelefone: data['numeroTelefone'],
          avaliacoes: avaliacoes,
          somaAvaliacoes: (data['somaAvaliacoes']).toDouble(),
          instituicao: instituicao!,
          veiculo: (veiculo == null) ? null : veiculo,
          caronas: caronas,
          novoUsuario: data['novoUsuario'],
        );

        return aluno;
      } else {
        return null;
      }
    } catch (e) {
      print('Erro ao obter dados do aluno: $e');
      return null;
    }
  }

  update(Aluno aluno) async {
    List<String> avaliacoesIDS =
        aluno.avaliacoes.map((avaliacao) => avaliacao.id).toList();
    await db.collection('aluno').doc(aluno.id).update(
      {
        'nome': aluno.nome,
        'sexo': aluno.sexo,
        'dataNascimento': aluno.dataNascimento,
        'numeroMatricula': aluno.numeroMatricula,
        'numeroTelefone': aluno.numeroTelefone,
        'avaliacoes': avaliacoesIDS,
        'instituicao': aluno.instituicao.id,
        'somaAvaliacoes': aluno.somaAvaliacoes,
        'veiculo': (aluno.veiculo == null) ? null : aluno.veiculo?.id,
        'caronas': aluno.caronas,
      },
    );
  }

  updateStatus(Aluno aluno) async {
    await db.collection('aluno').doc(aluno.id).update(
      {
        'novoUsuario': false
      }
    );
  }

  delete(Aluno aluno) async {
    await db.collection('aluno').doc(aluno.id).delete();
  }
}
