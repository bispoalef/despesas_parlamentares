import '../entities/deputado.dart';
import '../entities/despesa.dart';

/// [IDeputadoRepository] é um contrato. Ele diz à nossa aplicação:
/// "Em algum lugar, existirá um código capaz de listar deputados e suas despesas."
abstract class IDeputadoRepository {
  /// Busca uma lista de deputados. Pode receber parâmetros opcionais para busca.
  Future<List<Deputado>> getDeputados({String? buscaNome, String? siglaUf});

  /// Busca as despesas de um deputado específico através do seu [id].
  Future<List<Despesa>> getDespesasDeputado(int id);
}
