import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'core/inject/inject.dart';
import 'domain/entities/deputado.dart';
import 'domain/repositories/deputado_repository.dart';

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
  final repository = getIt<IDeputadoRepository>();

  late Future<List<Deputado>> futureDeputados;

  @override
  void initState() {
    super.initState();

    futureDeputados = repository.getDeputados();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teste: Lista de Deputados'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),

      body: FutureBuilder<List<Deputado>>(
        future: futureDeputados,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Ops! Erro: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhum deputado encontrado.'));
          }

          final listaDeputados = snapshot.data!;

          return ListView.builder(
            itemCount: listaDeputados.length,
            itemBuilder: (context, index) {
              final deputado = listaDeputados[index];
              return ListTile(
                leading: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: deputado.urlFoto,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const SizedBox(
                      width: 50,
                      height: 50,
                      child: Padding(
                        padding: EdgeInsets.all(12.0),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    errorWidget: (context, url, error) => const SizedBox(
                      width: 50,
                      height: 50,
                      child: Icon(Icons.person, color: Colors.grey),
                    ),
                  ),
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
