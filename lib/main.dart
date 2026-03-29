import 'package:despesas_parlamentares/lib/presentation/pages/tela_detalhes.dart';
import 'package:despesas_parlamentares/presentation/pages/tela_detalhes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'core/inject/inject.dart';
import 'core/theme/app_theme.dart';
import 'presentation/blocs/deputados/deputados_cubit.dart';
import 'presentation/blocs/deputados/deputados_state.dart';

void main() {
  setupInject();
  runApp(const MeuApp());
}

class MeuApp extends StatelessWidget {
  const MeuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gastos Parlamentares',
      theme: AppTheme.theme,
      debugShowCheckedModeBanner: false,
      home: BlocProvider(
        create: (context) => getIt<DeputadosCubit>()..carregarDeputados(),
        child: const TelaInicial(),
      ),
    );
  }
}

class TelaInicial extends StatefulWidget {
  const TelaInicial({super.key});

  @override
  State<TelaInicial> createState() => _TelaInicialState();
}

class _TelaInicialState extends State<TelaInicial> {
  final _buscaController = TextEditingController();
  String? _ufSelecionada;

  final List<String> _estados = [
    'AC',
    'AL',
    'AP',
    'AM',
    'BA',
    'CE',
    'DF',
    'ES',
    'GO',
    'MA',
    'MT',
    'MS',
    'MG',
    'PA',
    'PB',
    'PR',
    'PE',
    'PI',
    'RJ',
    'RN',
    'RS',
    'RO',
    'RR',
    'SC',
    'SP',
    'SE',
    'TO',
  ];

  void _realizarBusca() {
    context.read<DeputadosCubit>().carregarDeputados(
      buscaNome: _buscaController.text,
      siglaUf: _ufSelecionada,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Deputados Federais',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: AppTheme.corPrimaria,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: const BoxDecoration(
              color: AppTheme.corPrimaria,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                TextField(
                  controller: _buscaController,
                  decoration: InputDecoration(
                    hintText: 'Buscar por nome...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _buscaController.clear();
                        _realizarBusca();
                      },
                    ),
                  ),
                  onSubmitted: (_) => _realizarBusca(),
                ),
                const SizedBox(height: 16),

                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _estados.length,
                    itemBuilder: (context, index) {
                      final uf = _estados[index];
                      final isSelected = _ufSelecionada == uf;

                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(
                            uf,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: AppTheme.corSecundaria,
                          backgroundColor: Colors.white,
                          onSelected: (selected) {
                            setState(() {
                              _ufSelecionada = selected ? uf : null;
                            });
                            _realizarBusca();
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: BlocBuilder<DeputadosCubit, DeputadosState>(
              builder: (context, state) {
                if (state is DeputadosLoading || state is DeputadosInitial) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is DeputadosError) {
                  return Center(child: Text(state.mensagem));
                } else if (state is DeputadosSuccess) {
                  final lista = state.deputados;

                  if (lista.isEmpty) {
                    return const Center(
                      child: Text(
                        'Nenhum deputado encontrado com estes filtros.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: lista.length,
                    itemBuilder: (context, index) {
                      final deputado = lista[index];
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(8),
                          leading: ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: deputado.urlFoto,
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                              placeholder: (context, url) =>
                                  const CircularProgressIndicator(),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.person, size: 40),
                            ),
                          ),
                          title: Text(
                            deputado.nome,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${deputado.siglaPartido} - ${deputado.siglaUf}',
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.grey,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    TelaDetalhes(deputado: deputado),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
