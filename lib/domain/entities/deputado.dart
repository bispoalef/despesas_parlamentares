import 'package:equatable/equatable.dart';

class Deputado extends Equatable {
  final int id;
  final String nome;
  final String siglaPartido;
  final String siglaUf;
  final String urlFoto;

  const Deputado({
    required this.id,
    required this.nome,
    required this.siglaPartido,
    required this.siglaUf,
    required this.urlFoto,
  });

  @override
  List<Object?> get props => [id, nome, siglaPartido, siglaUf, urlFoto];
}
