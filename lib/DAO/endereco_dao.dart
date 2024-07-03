import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uniride/DAO/bairro_dao.dart';
import 'package:uniride/model/bairro.dart';
import 'package:uniride/model/db_firestore.dart';
import 'package:uniride/model/endereco.dart';
import 'package:uniride/services/auth_service.dart';

class EnderecoDAO {
  late FirebaseFirestore db;
  late AuthService auth;

  EnderecoDAO() {
    _startRepository();
  }

  _startRepository() async {
    await _startFirestore();
  }

  _startFirestore() {
    db = DBFirestore.get();
  }

  create(Endereco endereco) async {
    await db.collection('endereco').doc().set({
      'logradouro': endereco.logradouro,
      'numero': endereco.numero,
      'complemento': endereco.complemento,
      'bairro': endereco.bairro.id,
    });
  }

  Future<Endereco?> retrieve(String id) async {
    try {
      final docSnapshot = await db.collection('endereco').doc(id).get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;

        BairroDAO bairroDAO = BairroDAO();
        Bairro? bairro = await bairroDAO.retrieve(data['bairro']);

        final endereco = Endereco(
          id: data['id'],
          logradouro: data['logradouro'],
          numero: data['numero'],
          bairro: bairro!,
        );

        return endereco;
      } else {
        return null;
      }
    } catch (e) {
      print('Erro ao obter dados do endereço: $e');
      return null;
    }
  }

  update(Endereco endereco) async {
    await db.collection('endereco').doc(endereco.id).update({
      'logradouro': endereco.logradouro,
      'numero': endereco.numero,
      'complemento': endereco.complemento,
      'bairro': endereco.bairro.id
    });
  }

  delete(Endereco endereco) async {
    await db.collection('endereco').doc(endereco.id).delete();
  }
}
