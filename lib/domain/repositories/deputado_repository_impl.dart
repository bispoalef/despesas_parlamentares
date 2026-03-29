import 'package:dio/dio.dart';
import '../../domain/entities/deputado.dart';
import '../../domain/entities/despesa.dart';
import '../../domain/repositories/deputado_repository.dart';

class DeputadoRepositoryImpl implements IDeputadoRepository {
  final Dio dio;

  DeputadoRepositoryImpl(this.dio);

  @override
  Future<List<Deputado>> getDeputados({
    String? nome,
    String? siglaUf,
    String? siglaPartido,
  }) async {
    try {
      // Fazemos APENAS UMA chamada pedindo um limite de 1000 para trazer todos de uma vez
      final response = await dio.get(
        'https://dadosabertos.camara.leg.br/api/v2/deputados',
        queryParameters: {'itens': 600, 'ordem': 'ASC', 'ordenarPor': 'nome'},
        options: Options(headers: {'Accept': 'application/json'}),
      );

      final List<dynamic> dadosJson = response.data['dados'];

      return dadosJson.map((json) {
        return Deputado(
          id: json['id'] ?? 0,
          nome: json['nome'] ?? 'Nome não informado',
          siglaPartido: json['siglaPartido'] ?? 'Sem Partido',
          siglaUf: json['siglaUf'] ?? '-',
          urlFoto: json['urlFoto'] ?? '',
        );
      }).toList();
    } catch (e) {
      throw Exception('Erro ao buscar deputados: $e');
    }
  }

  @override
  Future<List<Despesa>> getDespesasDeputado(int id) async {
    List<Despesa> todasDespesas = [];
    int paginaAtual = 1;
    bool temMaisPaginas = true;

    try {
      while (temMaisPaginas) {
        final response = await dio.get(
          'https://dadosabertos.camara.leg.br/api/v2/deputados/$id/despesas',
          queryParameters: {
            'itens': 100,
            'pagina': paginaAtual,
            'ordem': 'DESC',
            'ordenarPor': 'ano',
          },
          options: Options(headers: {'Accept': 'application/json'}),
        );

        final List<dynamic> dadosJson = response.data['dados'];

        todasDespesas.addAll(
          dadosJson.map((json) {
            return Despesa(
              tipoDespesa: json['tipoDespesa'] ?? 'Não informado',
              dataDocumento: json['dataDocumento'] ?? 'Data não informada',
              valorDocumento:
                  (json['valorDocumento'] as num?)?.toDouble() ?? 0.0,
              valorLiquido: (json['valorLiquido'] as num?)?.toDouble() ?? 0.0,
              urlDocumento: json['urlDocumento'],
            );
          }).toList(),
        );

        final List<dynamic> links = response.data['links'] ?? [];
        final temNext = links.any((link) => link['rel'] == 'next');

        if (temNext) {
          paginaAtual++;
        } else {
          temMaisPaginas = false;
        }
      }
      return todasDespesas;
    } catch (e) {
      throw Exception('Erro ao buscar despesas: $e');
    }
  }
}
