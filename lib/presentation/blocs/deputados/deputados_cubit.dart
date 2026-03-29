import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/deputado_repository.dart';
import 'deputados_state.dart';

class DeputadosCubit extends Cubit<DeputadosState> {
  final IDeputadoRepository repository;

  DeputadosCubit(this.repository) : super(DeputadosInitial());

  Future<void> carregarDeputados({
    String? buscaNome,
    String? siglaUf,
    String? siglaPartido,
  }) async {
    emit(DeputadosLoading());

    try {
      final deputados = await repository.getDeputados(
        nome: buscaNome,
        siglaUf: siglaUf,
        siglaPartido: siglaPartido,
      );

      emit(DeputadosSuccess(deputados));
    } catch (e) {
      emit(
        const DeputadosError(
          'Não foi possível carregar os deputados. Tente novamente.',
        ),
      );
    }
  }
}
