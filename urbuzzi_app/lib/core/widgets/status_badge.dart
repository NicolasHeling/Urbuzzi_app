import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Badge padronizado de status com ponto colorido — idêntico ao protótipo Lovable.
/// Usado no Mapa, Lista de Lotes, Kanban de Propostas, Auditoria e Vitrine.
class StatusBadge extends StatelessWidget {
  final String status;
  final bool dense;

  const StatusBadge({super.key, required this.status, this.dense = false});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.statusColor(status);
    final bg = AppColors.statusBgColor(status);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 8 : 10,
        vertical: dense ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            status,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: dense ? 11 : 12,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

/// Legenda de status em forma de pílulas com ponto colorido,
/// usada no topo do Mapa Interativo e na Lista de Lotes.
class StatusLegend extends StatelessWidget {
  final Set<String>? highlight; // se null, todos "ativos"
  final void Function(String status)? onTap;

  const StatusLegend({super.key, this.highlight, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: AppColors.statusOrder.map((status) {
        final active = highlight == null || highlight!.contains(status);
        final color = AppColors.statusColor(status);
        final bg = AppColors.statusBgColor(status);
        return InkWell(
          onTap: onTap == null ? null : () => onTap!(status),
          borderRadius: BorderRadius.circular(999),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: active ? bg : Colors.transparent,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: active ? color.withValues(alpha: 0.25) : AppColors.border,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: active ? color : AppColors.textMuted,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  status,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: active ? color : AppColors.textMuted,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
