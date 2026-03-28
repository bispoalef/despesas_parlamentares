import 'package:equatable/equatable.dart';

class Despesa extends Equatable {
  final String tipoDespesa;
  final String dataDocumento;
  final double valorDocumento;
  final double valorLiquido;
  final String? urlDocumento;

  const Despesa({
    required this.tipoDespesa,
    required this.dataDocumento,
    required this.valorDocumento,
    required this.valorLiquido,
    this.urlDocumento,
  });

  @override
  List<Object?> get props => [
    tipoDespesa,
    dataDocumento,
    valorDocumento,
    valorLiquido,
    urlDocumento,
  ];
}
