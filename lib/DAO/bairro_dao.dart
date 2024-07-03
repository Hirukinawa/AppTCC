import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uniride/DAO/cidade_dao.dart';
import 'package:uniride/model/bairro.dart';
import 'package:uniride/model/cidade.dart';
import 'package:uniride/model/db_firestore.dart';
import 'package:uniride/services/auth_service.dart';

class BairroDAO {
  late FirebaseFirestore db;
  late AuthService auth;

  BairroDAO() {
    _startRepository();
  }

  _startRepository() async {
    await _startFirestore();
  }

  _startFirestore() {
    db = DBFirestore.get();
  }

  create(Bairro bairro) async {
    await db.collection('bairro').doc().set({
      'descricao': bairro.descricao,
      'cidade': bairro.cidade.id
    });
  }

  Future<Bairro?> retrieve(String id) async {
    try {
      final docSnapshot = await db.collection('bairro').doc(id).get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;

        final CidadeDAO cidadeDAO = CidadeDAO();

        final Cidade? cidade = await cidadeDAO.retrieve(data['cidade']);

        final bairro = Bairro(id: data['id'], descricao: data['descricao'], cidade: cidade!);

        return bairro;
      } else {
        return null;
      }
    } catch (e) {
      print('Erro ao obter dados do bairro: $e');
      return null;
    }
  }

  update(Bairro bairro) async {
    await db.collection('bairro').doc(bairro.id).update({
      'descricao': bairro.descricao,
      'cidade': bairro.cidade.id,
    });
  }

  delete(Bairro bairro) async {
    await db.collection('bairro').doc(bairro.id).delete();
  }
}
