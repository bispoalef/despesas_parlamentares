import '../entities/deputado.dart';
import '../entities/despesa.dart';

abstract class IDeputadoRepository {
  Future<List<Deputado>> getDeputados({String? buscaNome, String? siglaUf});

  Future<List<Despesa>> getDespesasDeputado(int id);
}
