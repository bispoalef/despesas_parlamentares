import 'package:equatable/equatable.dart';
import '../../../domain/entities/deputado.dart';

abstract class DeputadosState extends Equatable {
  const DeputadosState();

  @override
  List<Object?> get props => [];
}

class DeputadosInitial extends DeputadosState {}

class DeputadosLoading extends DeputadosState {}

class DeputadosSuccess extends DeputadosState {
  final List<Deputado> deputados;

  const DeputadosSuccess(this.deputados);

  @override
  List<Object?> get props => [deputados];
}

class DeputadosError extends DeputadosState {
  final String mensagem;

  const DeputadosError(this.mensagem);

  @override
  List<Object?> get props => [mensagem];
}
