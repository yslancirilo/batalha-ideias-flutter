import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const BatalhaIdeiasApp());
}

class BatalhaIdeiasApp extends StatelessWidget {
  const BatalhaIdeiasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Batalha de Ideias',
      theme: ThemeData(colorSchemeSeed: Colors.deepPurple, useMaterial3: true),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Stream<QuerySnapshot> get _ideiasStream => FirebaseFirestore.instance
      .collection('ideias')
      .orderBy('votos', descending: true)
      .snapshots();

  Future<void> _votar(String id, int votosAtuais) {
    return FirebaseFirestore.instance
        .collection('ideias')
        .doc(id)
        .update({'votos': votosAtuais + 1});
  }

  Future<void> _excluir(String id) {
    return FirebaseFirestore.instance.collection('ideias').doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('💡 Batalha de Ideias'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _ideiasStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar ideias.'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text('Nenhuma ideia cadastrada ainda.'));
          }

          final maisVotada = docs.first;
          final maisVotadaData = maisVotada.data() as Map<String, dynamic>;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Card(
                  color: Colors.amber.shade100,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('🏆 IDEIA MAIS VOTADA',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 6),
                        Text(maisVotadaData['titulo'] ?? '',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('${maisVotadaData['votos'] ?? 0} votos',
                            style: const TextStyle(fontSize: 14)),
                      ],
                    ),
                  ),
                );
              }

              final doc = docs[index - 1];
              final data = doc.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text('🎮 ${data['titulo'] ?? ''}',
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () => _excluir(doc.id),
                          ),
                        ],
                      ),
                      Text(data['autor'] ?? '',
                          style: TextStyle(color: Colors.grey.shade600)),
                      const SizedBox(height: 6),
                      Text(data['descricao'] ?? ''),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('❤️ ${data['votos'] ?? 0} votos',
                              style: const TextStyle(fontWeight: FontWeight.w600)),
                          ElevatedButton(
                            onPressed: () => _votar(doc.id, (data['votos'] ?? 0) as int),
                            child: const Text('VOTAR'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NovaIdeiaScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Nova Ideia'),
      ),
    );
  }
}

class NovaIdeiaScreen extends StatefulWidget {
  const NovaIdeiaScreen({super.key});

  @override
  State<NovaIdeiaScreen> createState() => _NovaIdeiaScreenState();
}

class _NovaIdeiaScreenState extends State<NovaIdeiaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titulo = TextEditingController();
  final _descricao = TextEditingController();
  final _autor = TextEditingController();
  bool _salvando = false;

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _salvando = true);
    await FirebaseFirestore.instance.collection('ideias').add({
      'titulo': _titulo.text.trim(),
      'descricao': _descricao.text.trim(),
      'autor': _autor.text.trim(),
      'votos': 0,
    });
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _titulo.dispose();
    _descricao.dispose();
    _autor.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Ideia'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titulo,
                decoration: const InputDecoration(labelText: 'Título', border: OutlineInputBorder()),
                validator: (v) => v!.trim().isEmpty ? 'Informe o título' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _descricao,
                decoration: const InputDecoration(labelText: 'Descrição', border: OutlineInputBorder()),
                maxLines: 3,
                validator: (v) => v!.trim().isEmpty ? 'Informe a descrição' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _autor,
                decoration: const InputDecoration(labelText: 'Autor', border: OutlineInputBorder()),
                validator: (v) => v!.trim().isEmpty ? 'Informe o autor' : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _salvando ? null : _salvar,
                  child: _salvando
                      ? const CircularProgressIndicator()
                      : const Text('SALVAR IDEIA'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
