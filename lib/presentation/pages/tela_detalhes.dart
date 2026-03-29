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
    final listaFiltrada = _tipoDespesaSelecionado == 'Todos'
        ? lista
        : lista.where((d) => d.tipoDespesa == _tipoDespesaSelecionado).toList();

    if (listaFiltrada.isEmpty) {
      return const Center(
        child: Text(
          'Nenhuma despesa para este filtro.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8),
      itemCount: listaFiltrada.length,
      itemBuilder: (context, index) {
        final despesa = listaFiltrada[index];
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
                          : Colors.grey,
                    ),
                  ),
                  if (despesa.valorLiquido > 0)
                    const Text(
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
                    Text(
                      '${widget.deputado.siglaPartido} - ${widget.deputado.siglaUf}',
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
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text(
                              'Analisando notas fiscais...',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      );
                    } else if (state is DespesasSuccess) {
                      final comReembolso = state.despesas
                          .where((d) => d.valorLiquido > 0)
                          .toList();
                      final semReembolso = state.despesas
                          .where((d) => d.valorLiquido <= 0)
                          .toList();

                      return Column(
                        children: [
                          // Card do Total
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

                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            child: DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: 'Filtrar por tipo de gasto',
                                prefixIcon: Icon(Icons.filter_list),
                              ),
                              isExpanded: true,
                              initialValue: _tipoDespesaSelecionado,
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
                              onChanged: (novoValor) {
                                setState(() {
                                  _tipoDespesaSelecionado = novoValor;
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 8),

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
