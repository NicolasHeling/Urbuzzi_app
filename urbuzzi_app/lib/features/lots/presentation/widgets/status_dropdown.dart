import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../domain/models/lot.dart';
import '../lots_provider.dart';

class StatusDropdown extends ConsumerStatefulWidget {
  final Lot lot;
  const StatusDropdown({required this.lot, super.key});

  @override
  ConsumerState<StatusDropdown> createState() => _StatusDropdownState();
}

class _StatusDropdownState extends ConsumerState<StatusDropdown> {
  bool _isLoading = false;

  Future<void> _changeStatus(String newStatus) async {
    if (newStatus == widget.lot.status) return;
    setState(() => _isLoading = true);
    try {
      await ref
          .read(lotsControllerProvider.notifier)
          .updateLotStatus(widget.lot.id, newStatus);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Status do Lote ${widget.lot.number} alterado para "$newStatus".',
            ),
            backgroundColor: AppColors.statusColor(newStatus),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Falha ao alterar status: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return SizedBox(
        width: 110,
        child: Row(
          children: [
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.statusColor(widget.lot.status),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                widget.lot.status,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.statusColor(widget.lot.status),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return PopupMenuButton<String>(
      tooltip: 'Alterar status',
      offset: const Offset(0, 32),
      onSelected: _changeStatus,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          StatusBadge(status: widget.lot.status, dense: true),
          const SizedBox(width: 2),
          Icon(
            Icons.expand_more_rounded,
            size: 14,
            color: AppColors.statusColor(widget.lot.status)
                .withValues(alpha: 0.7),
          ),
        ],
      ),
      itemBuilder: (context) => AppColors.statusOrder.map((status) {
        final isCurrent = status == widget.lot.status;
        final color = AppColors.statusColor(status);
        final bg = AppColors.statusBgColor(status);
        return PopupMenuItem<String>(
          value: status,
          enabled: !isCurrent,
          padding: EdgeInsets.zero,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: isCurrent
                ? BoxDecoration(color: bg.withValues(alpha: 0.45))
                : null,
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          isCurrent ? FontWeight.w700 : FontWeight.w500,
                      color: isCurrent ? color : AppColors.textPrimary,
                    ),
                  ),
                ),
                if (isCurrent)
                  Icon(Icons.check_rounded, size: 14, color: color),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
