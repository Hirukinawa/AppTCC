import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uniride/model/avaliacao.dart';
import 'package:uniride/model/db_firestore.dart';
import 'package:uniride/services/auth_service.dart';

class AvaliacaoDAO {
  late FirebaseFirestore db;
  late AuthService auth;

  AvaliacaoDAO() {
    _startRepository();
  }

  _startRepository() async {
    await _startFirestore();
  }

  _startFirestore() {
    db = DBFirestore.get();
  }

  create(Avaliacao avaliacao) async {
    await db.collection('avaliacao').doc(avaliacao.id).set({
      'id': avaliacao.id,
      'avaliado': avaliacao.avaliadoId,
      'avaliador': avaliacao.avaliadorId,
      'nota': avaliacao.nota,
      'comentario': avaliacao.comentario,
      'anonimo': avaliacao.anonimo,
    });
  }

  Future<Avaliacao?> retrieve(String id) async {
    try {
      final docSnapshot = await db.collection('avaliacao').doc(id).get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;

        final avaliacao = Avaliacao(
          id: data['id'],
          avaliadoId: data['avaliado'],
          avaliadorId: data['avaliador'],
          nota: data['nota'],
          comentario: data['comentario'],
          anonimo: data['anonimo'],
        );

        return avaliacao;
      } else {
        return null;
      }
    } catch (e) {
      print('Erro ao obter dados da avaliacao: $e');
      return null;
    }
  }

  Future<Avaliacao?> retrieveByIDS(
      {required avaliadoId, required avaliadorId}) async {
    try {
      final querySnapshot = await db
          .collection('avaliacao')
          .where('avaliado', isEqualTo: avaliadoId)
          .where('avaliador', isEqualTo: avaliadorId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final data = querySnapshot.docs[0].data() as Map<String, dynamic>;

        final avaliacao = Avaliacao(
          id: data['id'],
          avaliadoId: data['avaliado'],
          avaliadorId: data['avaliador'],
          nota: data['nota'],
          comentario: data['comentario'],
          anonimo: data['anonimo'],
        );

        return avaliacao;
      } else {
        return null;
      }
    } catch (e) {
      print('Erro ao buscar avaliacao: $e');
      return null;
    }
  }

  Future<List<Avaliacao>?> retrieveAll(String alunoId) async {
    List<Avaliacao> avaliacoes = [];
    try {
      final querySnapshot = await db
          .collection('avaliacao')
          .where('avaliado', isEqualTo: alunoId)
          .get();
      for (var avaliacaoDoc in querySnapshot.docs) {
        Map<String, dynamic> data = avaliacaoDoc.data();

        final avaliacao = Avaliacao(
          id: data['id'],
          avaliadoId: data['avaliado'],
          avaliadorId: data['avaliador'],
          nota: data['nota'],
          comentario: data['comentario'],
          anonimo: data['anonimo'],
        );

        avaliacoes.add(avaliacao);
      }

      return avaliacoes;
    } catch (e) {
      print('Erro ao buscar avaliacoes: $e');
      return null;
    }
  }

  update(Avaliacao avaliacao) async {
    await db.collection('avaliacao').doc(avaliacao.id).update(
      {'nota': avaliacao.nota, 'comentario': avaliacao.comentario, 'anonimo': avaliacao.anonimo,},
    );
  }

  delete(Avaliacao avaliacao) async {
    await db.collection('avaliacao').doc(avaliacao.id).delete();
  }
}
