import 'package:dio/dio.dart';
import '../../domain/entities/deputado.dart';
import '../../domain/entities/despesa.dart';
import '../../domain/repositories/deputado_repository.dart';

/// Aqui nós implementamos (implements) o contrato que criamos na camada de Domínio.
class DeputadoRepositoryImpl implements IDeputadoRepository {
  final Dio dio;

  // Recebemos o Dio via construtor para facilitar testes futuros
  DeputadoRepositoryImpl(this.dio);

  @override
  Future<List<Deputado>> getDeputados({
    String? buscaNome,
    String? siglaUf,
  }) async {
    try {
      // Fazemos a chamada HTTP para a API oficial da Câmara
      final response = await dio.get(
        'https://dadosabertos.camara.leg.br/api/v2/deputados',
        queryParameters: {
          // A API pede 'itens' para paginação, vamos pedir 50 por enquanto para o teste
          'itens': 50,
          'ordem': 'ASC',
          'ordenarPor': 'nome',
          // Se passarmos um nome, a API filtra automaticamente
          if (buscaNome != null && buscaNome.isNotEmpty) 'nome': buscaNome,
          if (siglaUf != null && siglaUf.isNotEmpty) 'siglaUf': siglaUf,
        },
      );

      // A API devolve um JSON onde os deputados ficam dentro de uma lista chamada "dados"
      final List<dynamic> dadosJson = response.data['dados'];

      // Transformamos a lista de JSON (texto da internet) na nossa Entidade limpa (Deputado)
      return dadosJson.map((json) {
        return Deputado(
          id: json['id'],
          nome: json['nome'],
          siglaPartido: json['siglaPartido'],
          siglaUf: json['siglaUf'],
          urlFoto: json['urlFoto'],
        );
      }).toList();
    } catch (e) {
      // Se der erro (sem internet, API fora do ar), capturamos aqui
      throw Exception('Erro ao buscar deputados: $e');
    }
  }

  @override
  Future<List<Despesa>> getDespesasDeputado(int id) async {
    // Vamos deixar vazio APENAS POR ENQUANTO, para focarmos no teste de hoje
    // que é listar os deputados.
    return [];
  }
}
