import '../entities/deputado.dart';
import '../entities/despesa.dart';

abstract class IDeputadoRepository {
  Future<List<Deputado>> getDeputados({
    String? nome,
    String? siglaUf,
    String? siglaPartido,
  });

  Future<List<Despesa>> getDespesasDeputado(int id);
}
