import 'package:uniride/model/cidade.dart';

class Bairro {
  late String id;
  late String descricao;
  late Cidade cidade;

  Bairro.empty();

  Bairro({required this.id, required this.descricao, required this.cidade});
}
