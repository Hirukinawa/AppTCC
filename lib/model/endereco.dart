import 'package:uniride/model/bairro.dart';

class Endereco {

  late String id;
  late String logradouro;
  late int numero;
  late String? complemento;
  late Bairro bairro;

  Endereco.empty();

  Endereco ({
    required this.id,
    required this.logradouro,
    required this.numero,
    required this.bairro,
  });

}