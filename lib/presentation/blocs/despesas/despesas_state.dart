import 'package:equatable/equatable.dart';
import '../../../domain/entities/despesa.dart';

abstract class DespesasState extends Equatable {
  const DespesasState();

  @override
  List<Object?> get props => [];
}

class DespesasInitial extends DespesasState {}

class DespesasLoading extends DespesasState {}

class DespesasSuccess extends DespesasState {
  final List<Despesa> despesas;
  final double valorTotal;
  final List<String> tiposDisponiveis;

  const DespesasSuccess({
    required this.despesas,
    required this.valorTotal,
    required this.tiposDisponiveis,
  });

  @override
  List<Object?> get props => [despesas, valorTotal, tiposDisponiveis];
}

class DespesasError extends DespesasState {
  final String mensagem;

  const DespesasError(this.mensagem);

  @override
  List<Object?> get props => [mensagem];
}
