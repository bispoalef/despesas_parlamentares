import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'core/inject/inject.dart';
import 'core/theme/app_theme.dart';
import 'presentation/blocs/deputados/deputados_cubit.dart';
import 'presentation/blocs/deputados/deputados_state.dart';
import 'presentation/pages/tela_detalhes.dart';

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
  String _textoBuscaAtual = '';
  String? _ufSelecionada;

  final List<String> _estados = [
    'AC',
    'AL',
    'BA',
    'CE',
    'DF',
    'MG',
    'PE',
    'RJ',
    'SP',
    'RS',
  ];

  void _realizarBusca(String textoBusca) {
    _textoBuscaAtual = textoBusca;
    context.read<DeputadosCubit>().realizarBuscaLocal(
      buscaNome: _textoBuscaAtual,
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
                Autocomplete<String>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text.isEmpty) {
                      return const Iterable<String>.empty();
                    }
                    final cubit = context.read<DeputadosCubit>();
                    final nomes = cubit.todosDeputadosCache
                        .map((d) => d.nome)
                        .toSet()
                        .toList();
                    return nomes.where(
                      (nome) => nome.toLowerCase().contains(
                        textEditingValue.text.toLowerCase(),
                      ),
                    );
                  },
                  onSelected: (String selecao) {
                    _realizarBusca(selecao);
                  },
                  fieldViewBuilder:
                      (context, controller, focusNode, onFieldSubmitted) {
                        return TextField(
                          controller: controller,
                          focusNode: focusNode,
                          decoration: InputDecoration(
                            hintText: 'Buscar deputado por nome...',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                controller.clear();
                                _realizarBusca('');
                              },
                            ),
                          ),
                          onChanged: (texto) => _realizarBusca(texto),
                        );
                      },
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
                            _realizarBusca(_textoBuscaAtual);
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
                  return Center(
                    child: Text(
                      state.mensagem,
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                } else if (state is DeputadosSuccess) {
                  final lista = state.deputados;
                  if (lista.isEmpty)
                    return const Center(
                      child: Text('Nenhum deputado encontrado.'),
                    );

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
                        child: ListTile(
                          leading: ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: deputado.urlFoto,
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.person),
                            ),
                          ),
                          title: Text(
                            deputado.nome,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${deputado.siglaPartido} - ${deputado.siglaUf}',
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
