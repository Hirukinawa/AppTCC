import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uniride/DAO/endereco_dao.dart';
import 'package:uniride/model/db_firestore.dart';
import 'package:uniride/model/endereco.dart';
import 'package:uniride/model/instituicao.dart';
import 'package:uniride/services/auth_service.dart';

class InstituicaoDAO {
  late FirebaseFirestore db;
  late AuthService auth;

  InstituicaoDAO() {
    _startRepository();
  }

  _startRepository() async {
    await _startFirestore();
  }

  _startFirestore() {
    db = DBFirestore.get();
  }

  create(Instituicao instituicao) async {
    await db.collection('instituicao').doc().set({
      'descricao': instituicao.descricao,
      'endereco': instituicao.endereco.id,
      'latitude': instituicao.localizacao.latitude,
      'longitude': instituicao.localizacao.longitude
    });
  }

  Future<Instituicao?> retrieve(String id) async {
    try {
      final docSnapshot = await db.collection('instituicao').doc(id).get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;

        EnderecoDAO enderecoDAO = EnderecoDAO();

        Endereco? endereco = await enderecoDAO.retrieve(data['endereco']);

        final instituicao = Instituicao(
          id: data['id'],
          descricao: data['descricao'],
          endereco: endereco!,
          localizacao: LatLng(data['latitude'], data['longitude']),
        );

        return instituicao;
      } else {
        return null;
      }
    } catch (e) {
      print('Erro ao obter dados da instituicao: $e');
      return null;
    }
  }

  Future<Instituicao?> retrieveDescricao(String descricao) async {
  try {
    final querySnapshot = await db
        .collection('instituicao')
        .where('descricao', isEqualTo: descricao)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final docSnapshot = querySnapshot.docs.first;
      final data = docSnapshot.data();

      EnderecoDAO enderecoDAO = EnderecoDAO();

      Endereco? endereco = await enderecoDAO.retrieve(data['endereco']);

      final instituicao = Instituicao(
        id: docSnapshot.id,
        descricao: data['descricao'],
        endereco: endereco!,
        localizacao: LatLng(data['latitude'], data['longitude']),
      );

      return instituicao;
    } else {
      return null;
    }
  } catch (e) {
    print('Erro ao obter dados da instituição: $e');
    return null;
  }
}


  update(Instituicao instituicao) async {
    await db.collection('instituicao').doc(instituicao.id).update(
      {
        'descricao': instituicao.descricao,
        'endereco': instituicao.endereco.id,
      },
    );
  }

  delete(Instituicao instituicao) async {
    await db.collection('instituicao').doc(instituicao.id).delete();
  }
}
