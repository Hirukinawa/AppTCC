import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:uniride/DAO/aluno_dao.dart';
import 'package:uniride/model/aluno.dart';
import 'package:uniride/model/db_firestore.dart';
import 'package:uniride/model/passageiro.dart';
import 'package:uniride/services/auth_service.dart';

class PassageiroDAO {
  late FirebaseFirestore db;
  late AuthService auth;
  late Passageiro passageiro;

  PassageiroDAO() {
    _startRepository();
  }

  _startRepository() async {
    await _startFirestore();
  }

  _startFirestore() {
    db = DBFirestore.get();
  }

  create(Passageiro passageiro, Aluno aluno) async {
    await db.collection('passageiro').doc(passageiro.id).set(
      {
        "id": passageiro.id,
        "passageiro": aluno.id,
        "carona": passageiro.carona,
        "horaSaida": passageiro.horaToString(passageiro.horaSaida),
        "origem": passageiro.origem,
        "diasCarona": {
          "segunda": passageiro.diasCarona[0],
          "terca": passageiro.diasCarona[1],
          "quarta": passageiro.diasCarona[2],
          "quinta": passageiro.diasCarona[3],
          "sexta": passageiro.diasCarona[4],
          "sabado": passageiro.diasCarona[5],
        },
        "latitude": passageiro.localizacao.latitude,
        "longitude": passageiro.localizacao.longitude
      },
    );
  }

  Future<Passageiro?> retrieve(String id) async {
    try {
      final docSnapshot = await db.collection('passageiro').doc(id).get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;

        TimeOfDay horaSaida = TimeOfDay.fromDateTime(
          DateFormat("HH:mm").parse(
            data['horaSaida'],
          ),
        );

        List<String> diasFirebase = [
          'segunda',
          'terca',
          'quarta',
          'quinta',
          'sexta',
          'sabado',
        ];

        List<bool>? diasSemanaFirebase = diasFirebase
            .map((dia) => (data['diasCarona'][dia] as bool?) ?? false)
            .toList();

        AlunoDAO alunoDAO = AlunoDAO();

        Aluno? aluno = await alunoDAO.retrieve(data['passageiro']);

        final passageiro = Passageiro(
            id: data['id'],
            carona: data['carona'],
            passageiro: aluno!,
            horaSaida: horaSaida,
            origem: data['origem'],
            diasCarona: diasSemanaFirebase,
            localizacao: LatLng(data['latitude'], data['longitude']));
        return passageiro;
      } else {
        return null;
      }
    } catch (e) {
      print('Erro ao obter dados do passageiro: $e');
      return null;
    }
  }

  Future<List<Passageiro>> retrieveAll(String id) async {
    List<Passageiro> passageiros = [];
    try {
      final docSnapshot = await db
          .collection('passageiro')
          .where('passageiro', isEqualTo: id)
          .get();

      for (var passageiroDoc in docSnapshot.docs) {
        Map<String, dynamic> data = passageiroDoc.data();

        TimeOfDay horaSaida = TimeOfDay.fromDateTime(
          DateFormat("HH:mm").parse(
            data['horaSaida'],
          ),
        );

        List<String> diasFirebase = [
          'segunda',
          'terca',
          'quarta',
          'quinta',
          'sexta',
          'sabado',
        ];

        List<bool>? diasSemanaFirebase = diasFirebase
            .map((dia) => (data['diasCarona'][dia] as bool?) ?? false)
            .toList();

        AlunoDAO alunoDAO = AlunoDAO();

        Aluno? aluno = await alunoDAO.retrieve(data['passageiro']);

        final passageiro = Passageiro(
          id: data['id'],
          carona: data['carona'],
          passageiro: aluno!,
          horaSaida: horaSaida,
          origem: data['origem'],
          diasCarona: diasSemanaFirebase,
          localizacao: LatLng(data['latitude'], data['longitude']),
        );

        passageiros.add(passageiro);
      }
    } catch (e) {
      print('Erro ao obter dados da lista de passageiros: $e');
    }

    return passageiros;
  }

  update(Passageiro passageiro) async {
    await db.collection('passageiro').doc(passageiro.id).update(
      {
        'horaSaida': passageiro.horaToString(passageiro.horaSaida),
        'origem': passageiro.origem,
        "diasCarona": {
          "segunda": passageiro.diasCarona[0],
          "terca": passageiro.diasCarona[1],
          "quarta": passageiro.diasCarona[2],
          "quinta": passageiro.diasCarona[3],
          "sexta": passageiro.diasCarona[4],
          "sabado": passageiro.diasCarona[5],
        },
      },
    );
  }

  delete(Passageiro passageiro) async {
    await db.collection('passageiro').doc(passageiro.id).delete();
  }
}
