import 'package:dio/dio.dart';
import '../../domain/entities/deputado.dart';
import '../../domain/entities/despesa.dart';
import '../../domain/repositories/deputado_repository.dart';

class DeputadoRepositoryImpl implements IDeputadoRepository {
  final Dio dio;

  DeputadoRepositoryImpl(this.dio);

  @override
  Future<List<Deputado>> getDeputados({
    String? buscaNome,
    String? siglaUf,
  }) async {
    try {
      final response = await dio.get(
        'https://dadosabertos.camara.leg.br/api/v2/deputados',
        queryParameters: {
          'itens': 50,
          'ordem': 'ASC',
          'ordenarPor': 'nome',

          if (buscaNome != null && buscaNome.isNotEmpty) 'nome': buscaNome,
          if (siglaUf != null && siglaUf.isNotEmpty) 'siglaUf': siglaUf,
        },
      );

      final List<dynamic> dadosJson = response.data['dados'];

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
      throw Exception('Erro ao buscar deputados: $e');
    }
  }

  @override
  Future<List<Despesa>> getDespesasDeputado(int id) async {
    return [];
  }
}
