import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uniride/model/aluno.dart';
import 'package:uniride/model/db_firestore.dart';
import 'package:uniride/model/veiculo.dart';
import 'package:uniride/services/auth_service.dart';

class VeiculoDAO {
  late FirebaseFirestore db;
  late AuthService auth;

  VeiculoDAO() {
    _startRepository();
  }

  _startRepository() async {
    await _startFirestore();
  }

  _startFirestore() {
    db = DBFirestore.get();
  }

  create(Veiculo veiculo, Aluno aluno, String id) async {
    await db.collection('veiculo').doc(id).set({
      'id': id,
      'tipoVeiculo': veiculo.tipoVeiculo,
      'modelo': veiculo.modelo,
      'placa': veiculo.placa,
      'cor': veiculo.cor,
    });
  }

  Future<Veiculo?> retrieve(String id) async {
    try {
      final docSnapshot = await db.collection('veiculo').doc(id).get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;

        final veiculo = Veiculo(
          id: data['id'],
          tipoVeiculo: data['tipoVeiculo'],
          modelo: data['modelo'],
          placa: data['placa'],
          cor: data['cor'],
        );

        return veiculo;
      } else {
        return null;
      }
    } catch (e) {
      print('Erro ao obter dados do veículo: $e');
      return null;
    }
  }

  update(Veiculo veiculo) async {
    await db.collection('veiculo').doc(veiculo.id).update({
      'tipoVeiculo': veiculo.tipoVeiculo,
      'modelo': veiculo.modelo,
      'placa': veiculo.placa,
      'cor': veiculo.cor,
    });
  }

  delete(Veiculo veiculo) async {
    await db.collection('veiculo').doc(veiculo.id).delete();
  }
}
