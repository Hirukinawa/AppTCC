import "package:flutter/material.dart";
import "package:google_maps_flutter/google_maps_flutter.dart";
import "package:uniride/model/aluno.dart";
import "package:uniride/model/instituicao.dart";
import "package:uniride/model/passageiro.dart";

class Carona {
  late String id;
  late Aluno motorista;
  late TimeOfDay horaSaida;
  late TimeOfDay horaChegada;
  late String origem;
  late LatLng localizacao;
  late Instituicao destino;
  late List<bool> diasCarona = [];
  late int vagasRestantes;
  late List<Passageiro> passageiros = [];
  late List<Passageiro> interessados = [];
  late double preco;

  Carona({
    required this.id,
    required this.motorista,
    required this.horaSaida,
    required this.horaChegada,
    required this.origem,
    required this.localizacao,
    required this.destino,
    required this.diasCarona,
    required this.vagasRestantes,
    required this.passageiros,
    required this.interessados,
    required this.preco,
  });

  String horaToString(TimeOfDay hora) {
    return '${hora.hour}:${hora.minute.toString().padLeft(2, '0')}';
  }
}
