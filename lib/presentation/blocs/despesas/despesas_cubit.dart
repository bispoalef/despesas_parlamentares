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

      // Ordenação de data (Mais recente para a mais antiga)
      despesas.sort((a, b) {
        DateTime dataA =
            DateTime.tryParse(a.dataDocumento) ??
            DateTime.fromMillisecondsSinceEpoch(0);
        DateTime dataB =
            DateTime.tryParse(b.dataDocumento) ??
            DateTime.fromMillisecondsSinceEpoch(0);
        return dataB.compareTo(dataA);
      });

      // Extrai os filtros únicos deste deputado
      final tiposUnicos = despesas.map((d) => d.tipoDespesa).toSet().toList();
      tiposUnicos.sort();

      double somaTotal = 0;
      for (var despesa in despesas) {
        somaTotal += despesa.valorLiquido;
      }

      emit(
        DespesasSuccess(
          despesas: despesas,
          valorTotal: somaTotal,
          tiposDisponiveis: tiposUnicos,
        ),
      );
    } catch (e) {
      emit(const DespesasError('Não foi possível carregar as despesas.'));
    }
  }
}
