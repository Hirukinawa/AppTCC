import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uniride/model/db_firestore.dart';
import 'package:uniride/model/uf.dart';
import 'package:uniride/services/auth_service.dart';

class UFDAO {
  late FirebaseFirestore db;
  late AuthService auth;

  UFDAO() {
    _startRepository();
  }

  _startRepository() async {
    await _startFirestore();
  }

  _startFirestore() {
    db = DBFirestore.get();
  }

  create(UF uf) async {
    await db.collection('uf').doc().set({
      'sigla': uf.sigla,
    });
  }

  Future<UF?> retrieve(String id) async {
    try {
      final docSnapshot = await db.collection('uf').doc(id).get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;

        final uf = UF(id: data['id'], sigla: data['sigla']);

        return uf;
      } else {
        return null;
      }
    } catch (e) {
      print('Erro ao obter dados da UF: $e');
      return null;
    }
  }

  update(UF uf) async {
    await db.collection('uf').doc(uf.id).update({
      'sigla': uf.sigla,
    });
  }

  delete(UF uf) async {
    await db.collection('uf').doc(uf.id).delete();
  }
}
