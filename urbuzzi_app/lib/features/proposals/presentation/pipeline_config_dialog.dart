import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'pipeline_provider.dart';
import '../domain/models/pipeline_stage.dart';
import '../../../core/theme/app_colors.dart';

class PipelineConfigDialog extends ConsumerStatefulWidget {
  const PipelineConfigDialog({super.key});

  @override
  ConsumerState<PipelineConfigDialog> createState() => _PipelineConfigDialogState();
}

class _PipelineConfigDialogState extends ConsumerState<PipelineConfigDialog> {
  final _nameCtrl = TextEditingController();
  final _colorCtrl = TextEditingController(text: '#C2650A');

  static const _presetColors = [
    '#C2650A', '#1B7A3D', '#9A6B28', '#2952A3', '#C62828',
    '#6B6B73', '#7B1FA2', '#00838F', '#E65100', '#2E7D32',
  ];

  void _addStage() async {
    if (_nameCtrl.text.isEmpty) return;
    try {
      await ref.read(pipelineProvider.notifier).addStage(
        name: _nameCtrl.text,
        color: _colorCtrl.text,
      );
      _nameCtrl.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Etapa adicionada!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _colorCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stagesAsync = ref.watch(pipelineProvider);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 520,
        constraints: const BoxConstraints(maxHeight: 600),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.view_kanban_outlined, color: AppColors.primary),
                const SizedBox(width: 12),
                const Text('Configurar Funil de Vendas', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Formulário para nova etapa
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.muted,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Nova Etapa', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _nameCtrl,
                          decoration: InputDecoration(
                            labelText: 'Nome da Etapa',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        height: 40,
                        child: ElevatedButton.icon(
                          onPressed: _addStage,
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Adicionar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _presetColors.map((hex) {
                      final color = PipelineStage.fromJson({'id': '', 'name': '', 'color': hex}).color;
                      final isSelected = _colorCtrl.text == hex;
                      return GestureDetector(
                        onTap: () => setState(() => _colorCtrl.text = hex),
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
                            boxShadow: isSelected
                                ? [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 8)]
                                : null,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Text('Etapas Atuais', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 8),

            Flexible(
              child: stagesAsync.when(
                data: (stages) {
                  if (stages.isEmpty) return const Center(child: Text('Nenhuma etapa configurada.'));
                  return ReorderableListView.builder(
                    shrinkWrap: true,
                    itemCount: stages.length,
                    onReorderItem: (oldIndex, newIndex) {
                      final reordered = List<PipelineStage>.from(stages);
                      final item = reordered.removeAt(oldIndex);
                      reordered.insert(newIndex, item);
                      ref.read(pipelineProvider.notifier).reorderStages(reordered);
                    },
                    itemBuilder: (context, index) {
                      final stage = stages[index];
                      return ListTile(
                        key: ValueKey(stage.id),
                        leading: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(color: stage.color, shape: BoxShape.circle),
                        ),
                        title: Text(stage.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                        subtitle: Text(
                          stage.isFinal ? 'Etapa Final' : stage.isCancellation ? 'Cancelamento' : 'Ordem: ${stage.order}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.drag_handle, color: AppColors.textMuted),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.cancelado),
                              onPressed: () => ref.read(pipelineProvider.notifier).removeStage(stage.id),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Erro: $e'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
