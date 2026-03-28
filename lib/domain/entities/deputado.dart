// Importamos o equatable para ajudar o Dart a comparar se dois deputados são iguais
import 'package:equatable/equatable.dart';

/// [Deputado] é a entidade principal que representa um parlamentar no nosso domínio.
/// Note que usamos apenas os dados que importam para o nosso aplicativo.
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

  /// O [props] é exigido pelo Equatable para saber quais campos usar na hora de
  /// comparar dois objetos (ex: Deputado A == Deputado B?)
  @override
  List<Object?> get props => [id, nome, siglaPartido, siglaUf, urlFoto];
}
