import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class BulkActionBar extends StatelessWidget {
  final int selectedCount;
  final bool isBusy;
  final VoidCallback onChangeStatus;
  final VoidCallback onClear;

  const BulkActionBar({
    required this.selectedCount,
    required this.isBusy,
    required this.onChangeStatus,
    required this.onClear,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        border: const Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$selectedCount selecionados',
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12),
            ),
          ),
          const Spacer(),
          if (isBusy)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: AppColors.primary),
            )
          else ...[
            TextButton.icon(
              onPressed: onChangeStatus,
              icon: const Icon(Icons.edit, size: 16),
              label: const Text('Alterar Status'),
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: onClear,
              style: TextButton.styleFrom(
                  foregroundColor: AppColors.textSecondary),
              child: const Text('Cancelar'),
            ),
          ],
        ],
      ),
    );
  }
}
