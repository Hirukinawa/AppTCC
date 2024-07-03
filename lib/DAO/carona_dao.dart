import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:uniride/DAO/instituicao_dao.dart';
import 'package:uniride/DAO/passageiro_dao.dart';
import 'package:uniride/DAO/aluno_dao.dart';
import 'package:uniride/model/aluno.dart';
import 'package:uniride/model/carona.dart';
import 'package:uniride/model/db_firestore.dart';
import 'package:uniride/model/instituicao.dart';
import 'package:uniride/model/passageiro.dart';
import 'package:uniride/services/auth_service.dart';

class CaronaDAO {
  late FirebaseFirestore db;
  late AuthService auth;

  CaronaDAO() {
    _startRepository();
  }

  _startRepository() async {
    await _startFirestore();
  }

  _startFirestore() {
    db = DBFirestore.get();
  }

  create(Carona carona) async {
    List<String> listaPassageiros = [];
    List<String> listaInteressados = [];
    await db.collection('carona').doc(carona.id).set(
      {
        "id": carona.id,
        "motorista": carona.motorista.id,
        "horaSaida": carona.horaToString(carona.horaSaida),
        "horaChegada": carona.horaToString(carona.horaChegada),
        "origem": carona.origem,
        "destino": carona.motorista.instituicao.id,
        "diasCarona": {
          "segunda": carona.diasCarona[0],
          "terca": carona.diasCarona[1],
          "quarta": carona.diasCarona[2],
          "quinta": carona.diasCarona[3],
          "sexta": carona.diasCarona[4],
          "sabado": carona.diasCarona[5],
        },
        "vagasRestantes": carona.vagasRestantes,
        "passageiros": listaPassageiros,
        "interessados": listaInteressados,
        "preco": carona.preco,
        "latitude": carona.localizacao.latitude,
        "longitude": carona.localizacao.longitude
      },
    );
  }

  Future<Carona?> retrieve(String id) async {
    try {
      final docSnapshot = await db.collection('carona').doc(id).get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;

        AlunoDAO alunoDAO = AlunoDAO();

        TimeOfDay horaSaida = TimeOfDay.fromDateTime(
          DateFormat("HH:mm").parse(
            data['horaSaida'],
          ),
        );

        TimeOfDay horaChegada = TimeOfDay.fromDateTime(
          DateFormat("HH:mm").parse(
            data['horaChegada'],
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

        InstituicaoDAO instituicaoDAO = InstituicaoDAO();
        Instituicao? destino = await instituicaoDAO.retrieve(data['destino']);

        List<Passageiro> interessados = [];
        List<Passageiro> passageiros = [];

        List<String>? interessadosIDs = (data['interessados'] as List<dynamic>?)
                ?.map((item) => item.toString())
                .toList() ??
            [];

        PassageiroDAO passageiroDAO = PassageiroDAO();

        for (var userID in interessadosIDs) {
          var userSnapshot =
              await db.collection('passageiro').doc(userID).get();
          if (userSnapshot.exists) {
            Passageiro? aluno = await passageiroDAO.retrieve(userID);

            if (aluno != null) {
              interessados.add(aluno);
            }
          }
        }

        List<String>? passageirosIDS = (data['passageiros'] as List<dynamic>?)
                ?.map((item) => item.toString())
                .toList() ??
            [];

        for (var userID in passageirosIDS) {
          var userSnapshot =
              await db.collection('passageiro').doc(userID).get();
          if (userSnapshot.exists) {
            Passageiro? passageiro = await passageiroDAO.retrieve(userID);

            if (passageiro != null) {
              passageiros.add(passageiro);
            }
          }
        }

        final Aluno? motorista = await alunoDAO.retrieve(data['motorista']);

        final carona = Carona(
            id: data['id'],
            motorista: motorista!,
            horaSaida: horaSaida,
            horaChegada: horaChegada,
            origem: data['origem'],
            destino: destino!,
            diasCarona: diasSemanaFirebase,
            vagasRestantes: data['vagasRestantes'],
            passageiros: passageiros,
            interessados: interessados,
            preco: data['preco'],
            localizacao: LatLng(data['latitude'], data['longitude']));

        return carona;
      } else {
        return null;
      }
    } catch (e) {
      print('Erro ao obter dados da carona: $e');
      return null;
    }
  }

  Future<List<Carona>> retrieveCaronasDisponiveis(
      Instituicao destino, String id, Passageiro passageiroAluno) async {
    List<Carona> caronasDisponiveis = [];

    try {
      final caronasSnapshot = await db.collection('carona').get();

      for (var caronaDoc in caronasSnapshot.docs) {
        Map<String, dynamic> data = caronaDoc.data();
        if (data["destino"] == destino.id) {
          int vagasRestantes = data['vagasRestantes'] ?? 0;
          if (id != data["id"]) {
            if (vagasRestantes > 0) {
              Carona? caronas = await retrieve(data['id']);

              caronasDisponiveis.add(caronas!);
            }
          }
        }
      }
    } catch (e) {
      print('Erro ao obter caronas disponíveis: $e');
    }

    List<Carona> caronasAux = List<Carona>.from(caronasDisponiveis);

    if (caronasDisponiveis.isNotEmpty) {
      for (var caronaPass in passageiroAluno.passageiro.caronas) {
        bool inCarona = false;

        for (int i = 0; i < caronasAux.length; i++) {
          Carona carona = caronasAux[i];
          for (var passageiro in carona.passageiros) {
            if (caronaPass == passageiro.id) {
              caronasAux.remove(carona);
              inCarona = true;
            }
          }
          if (!inCarona) {
            for (var interessado in carona.interessados) {
              if (caronaPass == interessado.id) {
                caronasAux.remove(carona);
              }
            }
          }
        }
      }

      caronasDisponiveis = caronasAux;
    }

    return caronasDisponiveis;
  }

  Future<List<Carona>> retrieveAllCaronasDisponiveis(
      Instituicao destino, String id, Passageiro passageiroAluno) async {
    List<Carona> caronasDisponiveis = [];

    try {
      final caronasSnapshot = await db.collection('carona').get();

      for (var caronaDoc in caronasSnapshot.docs) {
        Map<String, dynamic> data = caronaDoc.data();
        int vagasRestantes = data['vagasRestantes'] ?? 0;
        if (id != data["id"]) {
          if (vagasRestantes > 0) {
            Carona? caronas = await retrieve(data['id']);

            caronasDisponiveis.add(caronas!);
          }
        }
      }
    } catch (e) {
      print('Erro ao obter caronas disponíveis: $e');
    }

    List<Carona> caronasAux = List<Carona>.from(caronasDisponiveis);

    if (caronasDisponiveis.isNotEmpty) {
      for (var caronaPass in passageiroAluno.passageiro.caronas) {
        bool inCarona = false;

        for (int i = 0; i < caronasAux.length; i++) {
          Carona carona = caronasAux[i];
          for (var passageiro in carona.passageiros) {
            if (caronaPass == passageiro.id) {
              caronasAux.remove(carona);
              inCarona = true;
            }
          }
          if (!inCarona) {
            for (var interessado in carona.interessados) {
              if (caronaPass == interessado.id) {
                caronasAux.remove(carona);
              }
            }
          }
        }
      }

      caronasDisponiveis = caronasAux;
    }

    return caronasDisponiveis;
  }

  Future<List<Carona>> retrieveAll(String id) async {
    List<Carona> caronasFiltradas = [];

    try {
      final caronasSnapshot = await db.collection('carona').get();

      for (var caronaDoc in caronasSnapshot.docs) {
        Map<String, dynamic> data = caronaDoc.data();
        List<String> passageirosIDs = (data['passageiros'] as List<dynamic>?)
                ?.map((item) => item.toString())
                .toList() ??
            [];
        List<String> interessadosIDs = (data['interessados'] as List<dynamic>?)
                ?.map((item) => item.toString())
                .toList() ??
            [];

        if (passageirosIDs.contains(id) || interessadosIDs.contains(id)) {
          Carona? carona = await retrieve(data['id']);
          if (carona != null) {
            caronasFiltradas.add(carona);
          }
        }
      }
    } catch (e) {
      print('Erro ao obter caronas do aluno: $e');
    }

    return caronasFiltradas;
  }

  Future<void> update(Carona carona) async {
    List<String> interessadosIDs =
        carona.interessados.map((passageiro) => passageiro.id).toList();
    List<String> passageirosIDs =
        carona.passageiros.map((passageiro) => passageiro.id).toList();

    await db.collection('carona').doc(carona.id).update(
      {
        "vagasRestantes": carona.vagasRestantes,
        "preco": carona.preco,
        "interessados": interessadosIDs,
        "passageiros": passageirosIDs,
        "origem": carona.origem,
        "destino": carona.destino.id,
        "horaSaida": carona.horaToString(carona.horaSaida),
        "horaChegada": carona.horaToString(carona.horaChegada),
      },
    );
  }

  Future<void> delete(Carona carona) async {
    await db.collection('carona').doc(carona.id).delete();
  }
}
