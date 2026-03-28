import 'package:flutter/material.dart';
import 'core/inject/inject.dart';
import 'domain/entities/deputado.dart';
import 'domain/repositories/deputado_repository.dart';

void main() {
  // Inicializamos a injeção de dependências antes de rodar o app!
  setupInject();
  runApp(const MeuApp());
}

class MeuApp extends StatelessWidget {
  const MeuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gastos Parlamentares',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const TelaTeste(),
    );
  }
}

class TelaTeste extends StatefulWidget {
  const TelaTeste({super.key});

  @override
  State<TelaTeste> createState() => _TelaTesteState();
}

class _TelaTesteState extends State<TelaTeste> {
  // Aqui pegamos a nossa ferramenta de busca na "caixa de ferramentas" (getIt)
  final repository = getIt<IDeputadoRepository>();

  // Esta variável vai guardar a promessa da nossa lista de deputados
  late Future<List<Deputado>> futureDeputados;

  @override
  void initState() {
    super.initState();
    // Assim que a tela carregar, pedimos para buscar os deputados
    futureDeputados = repository.getDeputados();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teste: Lista de Deputados'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      // O FutureBuilder "escuta" o carregamento da API e constrói a tela de acordo
      body: FutureBuilder<List<Deputado>>(
        future: futureDeputados,
        builder: (context, snapshot) {
          // Se estiver carregando, mostra a bolinha girando
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // Se der erro, mostra uma mensagem de erro
          else if (snapshot.hasError) {
            return Center(child: Text('Ops! Erro: ${snapshot.error}'));
          }
          // Se não tem dados, avisa
          else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhum deputado encontrado.'));
          }

          // Se deu tudo certo, pegamos a lista
          final listaDeputados = snapshot.data!;

          // E construímos uma lista visual (ListView)
          return ListView.builder(
            itemCount: listaDeputados.length,
            itemBuilder: (context, index) {
              final deputado = listaDeputados[index];
              return ListTile(
                // Mostra a foto do deputado arredondada
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(deputado.urlFoto),
                ),
                title: Text(deputado.nome),
                subtitle: Text(
                  '${deputado.siglaPartido} - ${deputado.siglaUf}',
                ),
              );
            },
          );
        },
      ),
    );
  }
}
