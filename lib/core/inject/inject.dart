import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import '../../data/repositories/deputado_repository_impl.dart';
import '../../domain/repositories/deputado_repository.dart';

// getIt é a nossa "caixa de ferramentas" global
final getIt = GetIt.instance;

/// Função que vai iniciar e guardar todas as nossas dependências
void setupInject() {
  // 1. Registramos o Dio (ferramenta de internet)
  getIt.registerLazySingleton<Dio>(() => Dio());

  // 2. Registramos o nosso Repositório.
  // Ele pede um Dio, então nós pegamos o Dio que acabamos de registrar acima!
  getIt.registerLazySingleton<IDeputadoRepository>(
    () => DeputadoRepositoryImpl(getIt<Dio>()),
  );
}
