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
}
