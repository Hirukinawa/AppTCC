import 'package:uniride/model/uf.dart';

class Cidade {
  late String id;
  late String descricao;
  late UF uf;

  Cidade.empty();

  Cidade({
    required this.id,
    required this.descricao,
    required this.uf,
  });
}
