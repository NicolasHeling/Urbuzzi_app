import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'kanban_provider.dart';
import '../../../core/theme/app_colors.dart';

class KanbanSettingsPage extends ConsumerStatefulWidget {
  const KanbanSettingsPage({super.key});

  @override
  ConsumerState<KanbanSettingsPage> createState() => _KanbanSettingsPageState();
}

class _KanbanSettingsPageState extends ConsumerState<KanbanSettingsPage> {
  final _nameCtrl = TextEditingController();
  final _colorCtrl = TextEditingController(text: '#C2650A');

  static const _presetColors = [
    '#C2650A', '#1B7A3D', '#9A6B28', '#2952A3', '#C62828',
    '#6B6B73', '#7B1FA2', '#00838F', '#E65100', '#2E7D32',
  ];

  Color _hexToColor(String hex) {
    hex = hex.toUpperCase().replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }

  void _addColumn() async {
    if (_nameCtrl.text.isEmpty) return;
    try {
      await ref.read(kanbanProvider.notifier).addColumn(
        name: _nameCtrl.text,
        color: _colorCtrl.text,
      );
      _nameCtrl.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Coluna adicionada!')),
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
    final asyncColumns = ref.watch(kanbanProvider);

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
                const Icon(Icons.view_column_outlined, color: AppColors.primary),
                const SizedBox(width: 12),
                const Text('Configurar Quadro Kanban', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Formulário
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.muted,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Nova Coluna', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _nameCtrl,
                          decoration: InputDecoration(
                            labelText: 'Nome da Coluna',
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
                          onPressed: _addColumn,
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
                      final isSelected = _colorCtrl.text == hex;
                      final c = _hexToColor(hex);
                      return GestureDetector(
                        onTap: () => setState(() => _colorCtrl.text = hex),
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                            border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
                            boxShadow: isSelected ? [BoxShadow(color: c.withValues(alpha: 0.5), blurRadius: 8)] : null,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Text('Colunas Atuais (Arraste para reordenar)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 8),

            Flexible(
              child: asyncColumns.when(
                data: (columns) {
                  if (columns.isEmpty) return const Center(child: Text('Nenhuma coluna configurada.'));
                  return ReorderableListView.builder(
                    shrinkWrap: true,
                    itemCount: columns.length,
                    onReorderItem: (oldIndex, newIndex) {
                      final reordered = List<KanbanColumnModel>.from(columns);
                      final item = reordered.removeAt(oldIndex);
                      reordered.insert(newIndex, item);
                      ref.read(kanbanProvider.notifier).reorderColumns(reordered);
                    },
                    itemBuilder: (context, index) {
                      final col = columns[index];
                      return ListTile(
                        key: ValueKey(col.id),
                        leading: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(color: _hexToColor(col.color), shape: BoxShape.circle),
                        ),
                        title: Text(col.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                        subtitle: Text(
                          col.isFinal ? 'Coluna Final' : col.isCancellation ? 'Cancelamento' : 'Ordem: ${col.order}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.drag_handle, color: AppColors.textMuted),
                            const SizedBox(width: 8),
                            if (!col.isFinal && !col.isCancellation)
                              IconButton(
                                icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.cancelado),
                                onPressed: () => ref.read(kanbanProvider.notifier).removeColumn(col.id),
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
