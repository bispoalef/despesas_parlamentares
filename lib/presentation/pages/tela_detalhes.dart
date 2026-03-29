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

class TelaDetalhes extends StatefulWidget {
  final Deputado deputado;
  const TelaDetalhes({super.key, required this.deputado});

  @override
  State<TelaDetalhes> createState() => _TelaDetalhesState();
}

class _TelaDetalhesState extends State<TelaDetalhes> {
  String? _tipoDespesaSelecionado = 'Todos';

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
      await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
    }
  }

  Widget _construirListaDespesas(List<Despesa> lista) {
    if (lista.isEmpty) {
      return const Center(
        child: Text('Nenhuma despesa.', style: TextStyle(color: Colors.grey)),
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
            backgroundColor: AppTheme.corPrimaria.withOpacity(0.1),
            child: const Icon(Icons.receipt_long, color: AppTheme.corPrimaria),
          ),
          title: Text(
            despesa.tipoDespesa,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14),
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
                          : Colors.redAccent,
                    ),
                  ),
                ],
              ),
              if (temComprovante) ...[
                const SizedBox(width: 8),
                const Icon(
                  Icons.open_in_browser,
                  color: AppTheme.corSecundaria,
                  size: 24,
                ),
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
          getIt<DespesasCubit>()..carregarDespesas(widget.deputado.id),
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
                      tag: 'foto_${widget.deputado.id}',
                      child: ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: widget.deputado.urlFoto,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.deputado.nome,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: BlocBuilder<DespesasCubit, DespesasState>(
                  builder: (context, state) {
                    if (state is DespesasLoading || state is DespesasInitial) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is DespesasSuccess) {
                      final listaFiltrada = _tipoDespesaSelecionado == 'Todos'
                          ? state.despesas
                          : state.despesas
                                .where(
                                  (d) =>
                                      d.tipoDespesa == _tipoDespesaSelecionado,
                                )
                                .toList();

                      final comReembolso = listaFiltrada
                          .where((d) => d.valorLiquido > 0)
                          .toList();
                      final semReembolso = listaFiltrada
                          .where((d) => d.valorLiquido <= 0)
                          .toList();

                      final totalReembolsado = comReembolso.fold<double>(
                        0,
                        (sum, item) => sum + item.valorLiquido,
                      );
                      final totalSemReembolso = semReembolso.fold<double>(
                        0,
                        (sum, item) => sum + item.valorDocumento,
                      );
                      final totalGastoFiltro =
                          totalReembolsado + totalSemReembolso;

                      String periodo = 'Período não disponível';
                      if (listaFiltrada.isNotEmpty) {
                        String dataMaisAntiga = _formatarData(
                          listaFiltrada.last.dataDocumento,
                        );
                        String dataMaisNova = _formatarData(
                          listaFiltrada.first.dataDocumento,
                        );
                        periodo = '$dataMaisAntiga a $dataMaisNova';
                      }

                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Card(
                              color: Colors.white,
                              elevation: 3,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.date_range),
                                        const SizedBox(width: 8),
                                        Text('Período: $periodo'),
                                      ],
                                    ),
                                    const Divider(height: 24),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text('Total Reembolsado:'),
                                        Text(
                                          _formatarMoeda(totalReembolsado),
                                          style: const TextStyle(
                                            color: AppTheme.corSucesso,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text('Sem Reembolso/Diretos:'),
                                        Text(
                                          _formatarMoeda(totalSemReembolso),
                                          style: const TextStyle(
                                            color: Colors.redAccent,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Gasto Total:',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          _formatarMoeda(totalGastoFiltro),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.corPrimaria,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            child: DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: 'Filtrar por tipo de gasto',
                              ),
                              isExpanded: true,
                              value: _tipoDespesaSelecionado,
                              items: [
                                const DropdownMenuItem(
                                  value: 'Todos',
                                  child: Text('Todos os gastos'),
                                ),
                                ...state.tiposDisponiveis.map(
                                  (tipo) => DropdownMenuItem(
                                    value: tipo,
                                    child: Text(
                                      tipo,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                              onChanged: (novoValor) => setState(
                                () => _tipoDespesaSelecionado = novoValor,
                              ),
                            ),
                          ),
                          const TabBar(
                            labelColor: AppTheme.corPrimaria,
                            tabs: [
                              Tab(text: 'Com Reembolso'),
                              Tab(text: 'Sem Reembolso'),
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
