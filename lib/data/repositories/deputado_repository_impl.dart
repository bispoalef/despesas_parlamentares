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
    List<Deputado> todosDeputados = [];
    int paginaAtual = 1;
    bool temMaisPaginas = true;

    try {
      while (temMaisPaginas) {
        final response = await dio.get(
          'https://dadosabertos.camara.leg.br/api/v2/deputados',
          queryParameters: {
            'itens': 100,
            'pagina': paginaAtual,
            'ordem': 'ASC',
            'ordenarPor': 'nome',
            if (nome != null && nome.isNotEmpty) 'nome': nome,
            if (siglaUf != null && siglaUf.isNotEmpty) 'siglaUf': siglaUf,
            if (siglaPartido != null && siglaPartido.isNotEmpty)
              'siglaPartido': siglaPartido,
          },
          options: Options(headers: {'Accept': 'application/json'}),
        );

        final List<dynamic> dadosJson = response.data['dados'];

        todosDeputados.addAll(
          dadosJson.map((json) {
            return Deputado(
              id: json['id'],
              nome: json['nome'],
              siglaPartido: json['siglaPartido'],
              siglaUf: json['siglaUf'],
              urlFoto: json['urlFoto'],
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

      return todosDeputados;
    } catch (e) {
      throw Exception('Erro ao buscar todos os deputados: $e');
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

        final List<dynamic> links = response.data['links'];
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
