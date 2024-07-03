import "package:flutter/material.dart";
import "package:google_maps_flutter/google_maps_flutter.dart";
import "package:uniride/model/aluno.dart";

class Passageiro {
  late String id;
  late Aluno passageiro;
  late String carona;
  late TimeOfDay horaSaida;
  late String origem;
  late List<bool> diasCarona = [];
  late LatLng localizacao;

  Passageiro.empty();

  Passageiro({
    required this.id,
    required this.passageiro,
    required this.carona,
    required this.horaSaida,
    required this.origem,
    required this.diasCarona,
    required this.localizacao,
  });

  String horaToString(TimeOfDay hora) {
    return '${hora.hour}:${hora.minute.toString().padLeft(2, '0')}';
  }
}
