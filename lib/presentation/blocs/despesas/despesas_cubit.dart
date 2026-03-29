import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/deputado_repository.dart';
import 'despesas_state.dart';

class DespesasCubit extends Cubit<DespesasState> {
  final IDeputadoRepository repository;

  DespesasCubit(this.repository) : super(DespesasInitial());

  Future<void> carregarDespesas(int idDeputado) async {
    emit(DespesasLoading());

    try {
      final despesas = await repository.getDespesasDeputado(idDeputado);

      double somaTotal = 0;
      for (var despesa in despesas) {
        somaTotal += despesa.valorLiquido;
      }

      emit(DespesasSuccess(despesas: despesas, valorTotal: somaTotal));
    } catch (e) {
      emit(const DespesasError('Não foi possível carregar as despesas.'));
    }
  }
}
