import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uniride/model/endereco.dart';

class Instituicao {
  late String id;
  late String descricao;
  late Endereco endereco;
  late LatLng localizacao;

  Instituicao.empty();

  Instituicao({
    required this.id,
    required this.descricao,
    required this.endereco,
    required this.localizacao,
  });


}
