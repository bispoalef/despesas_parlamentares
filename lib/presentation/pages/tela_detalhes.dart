import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/inject/inject.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/deputado.dart';
import '../../domain/entities/despesa.dart';
import '../blocs/despesas/despesas_cubit.dart';
import '../blocs/despesas/despesas_state.dart';

class TelaDetalhes extends StatelessWidget {
  final Deputado deputado;

  const TelaDetalhes({super.key, required this.deputado});

  String _formatarMoeda(double valor) {
    return NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(valor);
  }

  String _formatarData(String dataIso) {
    if (dataIso == 'Data não informada' || dataIso.isEmpty) return dataIso;
    try {
      final dataParsed = DateTime.parse(dataIso);
      return DateFormat('dd/MM/yyyy').format(dataParsed);
    } catch (e) {
      return dataIso;
    }
  }

  Future<void> _abrirDocumento(String? url) async {
    if (url == null || url.isEmpty) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _construirListaDespesas(List<Despesa> lista) {
    if (lista.isEmpty) {
      return const Center(
        child: Text(
          'Nenhuma despesa encontrada nesta categoria.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8),
      itemCount: lista.length,
      itemBuilder: (context, index) {
        final despesa = lista[index];
        final temComprovante =
            despesa.urlDocumento != null && despesa.urlDocumento!.isNotEmpty;

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: AppTheme.corPrimaria.withValues(alpha: 0.1),
            child: const Icon(Icons.receipt_long, color: AppTheme.corPrimaria),
          ),
          title: Text(
            despesa.tipoDespesa,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text('Data: ${_formatarData(despesa.dataDocumento)}'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatarMoeda(despesa.valorDocumento),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: despesa.valorLiquido > 0
                          ? AppTheme.corSucesso
                          : Colors.grey,
                    ),
                  ),
                  if (despesa.valorLiquido > 0)
                    Text(
                      'Reembolsado',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppTheme.corSucesso,
                      ),
                    ),
                ],
              ),
              if (temComprovante) ...[
                const SizedBox(width: 8),
                const Icon(Icons.picture_as_pdf, color: Colors.grey, size: 20),
              ],
            ],
          ),
          onTap: temComprovante
              ? () => _abrirDocumento(despesa.urlDocumento)
              : null,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          getIt<DespesasCubit>()..carregarDespesas(deputado.id),
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text(
              'Visão Geral',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          body: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24.0),
                decoration: const BoxDecoration(
                  color: AppTheme.corPrimaria,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                child: Column(
                  children: [
                    Hero(
                      tag: 'foto_${deputado.id}',
                      child: ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: deputado.urlFoto,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      deputado.nome,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '${deputado.siglaPartido} - ${deputado.siglaUf}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppTheme.corSecundaria,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: BlocBuilder<DespesasCubit, DespesasState>(
                  builder: (context, state) {
                    if (state is DespesasLoading || state is DespesasInitial) {
                      return const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: AppTheme.corPrimaria,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Analisando notas fiscais...',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      );
                    } else if (state is DespesasError) {
                      return Center(child: Text(state.mensagem));
                    } else if (state is DespesasSuccess) {
                      final comReembolso = state.despesas
                          .where((d) => d.valorLiquido > 0)
                          .toList();
                      final semReembolso = state.despesas
                          .where((d) => d.valorLiquido <= 0)
                          .toList();

                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Card(
                              color: AppTheme.corSecundaria,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0,
                                  vertical: 16.0,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Total Reembolsado:',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      _formatarMoeda(state.valorTotal),
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.corPrimaria,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const TabBar(
                            labelColor: AppTheme.corPrimaria,
                            unselectedLabelColor: Colors.grey,
                            indicatorColor: AppTheme.corPrimaria,
                            indicatorWeight: 3,
                            tabs: [
                              Tab(
                                text: 'Com Reembolso',
                                icon: Icon(Icons.attach_money),
                              ),
                              Tab(
                                text: 'Sem Reembolso/Diretos',
                                icon: Icon(Icons.money_off),
                              ),
                            ],
                          ),

                          Expanded(
                            child: TabBarView(
                              children: [
                                _construirListaDespesas(comReembolso),
                                _construirListaDespesas(semReembolso),
                              ],
                            ),
                          ),
                        ],
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
