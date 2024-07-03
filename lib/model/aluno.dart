import "package:cloud_firestore/cloud_firestore.dart";
import "package:uniride/DAO/aluno_dao.dart";
import "package:uniride/DAO/avaliacao_dao.dart";
import "package:uniride/DAO/carona_dao.dart";
import "package:uniride/DAO/passageiro_dao.dart";
import "package:uniride/model/avaliacao.dart";
import "package:uniride/model/carona.dart";
import "package:uniride/model/instituicao.dart";
import "package:uniride/model/passageiro.dart";
import "package:uniride/model/veiculo.dart";
import "package:uniride/services/auth_service.dart";

class Aluno {
  late String id;
  late String nome;
  late String email;
  late String senha;
  late String sexo;
  late String dataNascimento;
  late String numeroMatricula;
  late String numeroTelefone;
  late List<Avaliacao> avaliacoes;
  late double somaAvaliacoes;
  late Instituicao instituicao;
  late Veiculo? veiculo;
  late List<String> caronas;
  late bool novoUsuario;

  late FirebaseFirestore db;
  late AuthService auth;

  Aluno.empty();

  Aluno(
      {required this.id,
      required this.nome,
      required this.senha,
      required this.email,
      required this.sexo,
      required this.dataNascimento,
      required this.numeroMatricula,
      required this.numeroTelefone,
      required this.avaliacoes,
      required this.somaAvaliacoes,
      required this.instituicao,
      this.veiculo,
      required this.caronas,
      required this.novoUsuario});

  void avaliaAluno(Aluno alunoAvaliado, {required Avaliacao avaliacao}) {
    AlunoDAO alunoDAO = AlunoDAO();
    alunoAvaliado.somaAvaliacoes += avaliacao.nota;
    alunoAvaliado.avaliacoes.add(avaliacao);
    alunoDAO.update(alunoAvaliado);
  }

  void editaAvaliacao(Aluno alunoAvaliado, Avaliacao avaliacao) {
    AlunoDAO alunoDAO = AlunoDAO();
    AvaliacaoDAO avaliacaoDAO = AvaliacaoDAO();
    alunoAvaliado.somaAvaliacoes += avaliacao.nota;
    avaliacaoDAO.update(avaliacao);
    alunoDAO.update(alunoAvaliado);
  }

  Future<void> solicitaCarona(Carona carona, Passageiro interessado) async {
    CaronaDAO caronaDAO = CaronaDAO();
    AlunoDAO alunoDAO = AlunoDAO();
    carona.interessados.add(interessado);
    interessado.passageiro.caronas.add(interessado.id);
    caronaDAO.update(carona);
    alunoDAO.update(interessado.passageiro);
  }

  Future<void> removeInteressado(Carona carona, String id) async {
    CaronaDAO caronaDAO = CaronaDAO();
    AlunoDAO alunoDAO = AlunoDAO();
    PassageiroDAO passageiroDAO = PassageiroDAO();
    Passageiro interessado = Passageiro.empty();
    for (var inte in carona.interessados) {
      if (inte.id == id) {
        interessado = inte;
      }
    }
    carona.interessados.remove(interessado);
    interessado.passageiro.caronas.remove(interessado.id);
    caronaDAO.update(carona);
    passageiroDAO.delete(interessado);
    alunoDAO.update(interessado.passageiro);
  }

  Future<void> ofereceCarona(Carona carona) async {
    CaronaDAO caronaDAO = CaronaDAO();
    caronaDAO.create(carona);
  }

  Future<void> cancelaCarona(Carona carona) async {
    AlunoDAO alunoDAO = AlunoDAO();
    CaronaDAO caronaDAO = CaronaDAO();
    PassageiroDAO passageiroDAO = PassageiroDAO();
    for (var interessado in carona.interessados) {
      interessado.passageiro.caronas.remove(interessado.id);
      alunoDAO.update(interessado.passageiro);
      passageiroDAO.delete(interessado);
    }
    for (var passageiro in carona.passageiros) {
      passageiro.passageiro.caronas.remove(passageiro.id);
      alunoDAO.update(passageiro.passageiro);
      passageiroDAO.delete(passageiro);
    }
    caronaDAO.delete(carona);
  }

  Future<void> aceitaPedido(Carona carona, Passageiro passageiro) async {
    CaronaDAO caronaDAO = CaronaDAO();
    carona.passageiros.add(passageiro);
    carona.interessados.remove(passageiro);
    carona.vagasRestantes -= 1;
    caronaDAO.update(carona);
  }

  Future<void> removePassageiro(Carona carona, String id) async {
    CaronaDAO caronaDAO = CaronaDAO();
    AlunoDAO alunoDAO = AlunoDAO();
    PassageiroDAO passageiroDAO = PassageiroDAO();
    Passageiro passageiro = Passageiro.empty();
    for (var inte in carona.passageiros) {
      if (inte.passageiro.id == id) {
        passageiro = inte;
      }
    }
    carona.passageiros.remove(passageiro);
    passageiro.passageiro.caronas.remove(passageiro.id);
    carona.vagasRestantes += 1;
    caronaDAO.update(carona);
    passageiroDAO.delete(passageiro);
    alunoDAO.update(passageiro.passageiro);
  }
  
}
