import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/deputado_repository.dart';
import '../../../domain/entities/deputado.dart';
import 'deputados_state.dart';

class DeputadosCubit extends Cubit<DeputadosState> {
  final IDeputadoRepository repository;

  // Guarda todos os deputados para busca instantânea local
  List<Deputado> todosDeputadosCache = [];

  DeputadosCubit(this.repository) : super(DeputadosInitial());

  Future<void> carregarDeputados() async {
    emit(DeputadosLoading());
    try {
      todosDeputadosCache = await repository.getDeputados();
      emit(DeputadosSuccess(todosDeputadosCache));
    } catch (e) {
      emit(DeputadosError('Erro ao carregar: $e'));
    }
  }

  void realizarBuscaLocal({String? buscaNome, String? siglaUf}) {
    if (todosDeputadosCache.isEmpty) return;

    List<Deputado> filtrados = List.from(todosDeputadosCache);

    if (buscaNome != null && buscaNome.isNotEmpty) {
      filtrados = filtrados
          .where((d) => d.nome.toLowerCase().contains(buscaNome.toLowerCase()))
          .toList();
    }

    if (siglaUf != null && siglaUf.isNotEmpty) {
      filtrados = filtrados.where((d) => d.siglaUf == siglaUf).toList();
    }

    emit(DeputadosSuccess(filtrados));
  }
}
