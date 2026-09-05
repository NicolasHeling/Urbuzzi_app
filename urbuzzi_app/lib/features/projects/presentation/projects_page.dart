import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'projects_provider.dart';

class ProjectsPage extends ConsumerStatefulWidget {
  const ProjectsPage({super.key});

  @override
  ConsumerState<ProjectsPage> createState() => _ProjectsPageState();
}

class _ProjectsPageState extends ConsumerState<ProjectsPage> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _svgCtrl = TextEditingController();

  void _createProject() async {
    if (_nameCtrl.text.isEmpty) return;
    try {
      await ref.read(projectsProvider.notifier).createProject(
        name: _nameCtrl.text,
        description: _descCtrl.text,
        address: _addressCtrl.text,
        svgMap: _svgCtrl.text,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Empreendimento salvo!')));
        _nameCtrl.clear();
        _descCtrl.clear();
        _addressCtrl.clear();
        _svgCtrl.clear();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncProjects = ref.watch(projectsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Gerenciar Empreendimentos', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Expanded(
                    child: asyncProjects.when(
                      data: (projects) {
                        if (projects.isEmpty) return const Text('Nenhum empreendimento cadastrado.');
                        return ListView.builder(
                          itemCount: projects.length,
                          itemBuilder: (context, index) {
                            final p = projects[index];
                            return Card(
                              child: ListTile(
                                leading: const Icon(Icons.business),
                                title: Text(p.name),
                                subtitle: Text(p.address ?? 'Sem endereço'),
                              ),
                            );
                          },
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (err, st) => Text('Erro: $err'),
                    ),
                  )
                ],
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Novo Empreendimento', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Nome do Loteamento')),
                  const SizedBox(height: 12),
                  TextField(controller: _addressCtrl, decoration: const InputDecoration(labelText: 'Endereço')),
                  const SizedBox(height: 12),
                  TextField(controller: _descCtrl, decoration: const InputDecoration(labelText: 'Descrição')),
                  const SizedBox(height: 12),
                  TextField(controller: _svgCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'Código do Mapa SVG')),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _createProject,
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                      child: const Text('Salvar Empreendimento'),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
