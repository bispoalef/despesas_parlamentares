import 'package:despesas_parlamentares/presentation/blocs/deputados/deputados_cubit.dart';
import 'package:despesas_parlamentares/presentation/blocs/despesas/despesas_cubit.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import '../../data/repositories/deputado_repository_impl.dart';
import '../../domain/repositories/deputado_repository.dart';

final getIt = GetIt.instance;

void setupInject() {
  getIt.registerLazySingleton<Dio>(() => Dio());

  getIt.registerLazySingleton<IDeputadoRepository>(
    () => DeputadoRepositoryImpl(getIt<Dio>()),
  );

  getIt.registerFactory<DeputadosCubit>(
    () => DeputadosCubit(getIt<IDeputadoRepository>()),
  );
  getIt.registerFactory<DespesasCubit>(
    () => DespesasCubit(getIt<IDeputadoRepository>()),
  );
}
