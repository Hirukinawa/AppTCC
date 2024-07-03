import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uniride/DAO/uf_dao.dart';
import 'package:uniride/model/cidade.dart';
import 'package:uniride/model/db_firestore.dart';
import 'package:uniride/model/uf.dart';
import 'package:uniride/services/auth_service.dart';

class CidadeDAO {
  late FirebaseFirestore db;
  late AuthService auth;

  CidadeDAO() {
    _startRepository();
  }

  _startRepository() async {
    await _startFirestore();
  }

  _startFirestore() {
    db = DBFirestore.get();
  }

  create(Cidade cidade) async {
    await db.collection('cidade').doc().set({
      'descricao': cidade.descricao,
      'uf': cidade.uf.id
    });
  }

  Future<Cidade?> retrieve(String id) async {
    try {
      final docSnapshot = await db.collection('cidade').doc(id).get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;

        UFDAO ufDAO = UFDAO();
        UF? uf = await ufDAO.retrieve(data['uf']);

        final cidade = Cidade(
          id: data['id'],
          descricao: data['descricao'],
          uf: uf!,
        );

        return cidade;
      } else {
        return null;
      }
    } catch (e) {
      print('Erro ao obter dados da cidade: $e');
      return null;
    }
  }

  update(Cidade cidade) async {
    await db.collection('cidade').doc(cidade.id).update({
      'descricao': cidade.descricao,
      'uf': cidade.uf,
    });
  }

  delete(Cidade cidade) async {
    await db.collection('cidade').doc(cidade.id).delete();
  }
}
