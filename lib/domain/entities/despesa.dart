import 'package:equatable/equatable.dart';

/// [Despesa] representa um gasto efetuado pelo parlamentar.
class Despesa extends Equatable {
  final String tipoDespesa;
  final String dataDocumento;
  final double valorDocumento; // O valor total do gasto
  final double valorLiquido; // O valor que foi efetivamente reembolsado
  final String?
  urlDocumento; // O link do comprovante (pode ser nulo se não houver)

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
