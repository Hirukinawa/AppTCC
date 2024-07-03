class Avaliacao {

  late String id;
  late String avaliadoId;
  late String avaliadorId;
  late double nota;
  late String comentario;
  late bool anonimo;

  Avaliacao.empty();

  Avaliacao({
    required this.id,
    required this.avaliadoId,
    required this.avaliadorId,
    required this.nota,
    required this.comentario,
    required this.anonimo,
  });

}