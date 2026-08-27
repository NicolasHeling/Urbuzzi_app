import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../lots/domain/models/lot.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/status_badge.dart';
import '../../reservations/presentation/reservation_dialog.dart';
import 'map_data.dart';

class LotDetailsModal extends StatelessWidget {
  final Lot lot;
  final LotPolygon poly;

  const LotDetailsModal({super.key, required this.lot, required this.poly});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final isAvailable = lot.status == 'Disponível';
    final hasClient = lot.clientName != null && lot.clientName!.isNotEmpty;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 40,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // Modal wraps content
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          
          // Header: Título e Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quadra ${poly.block} - Lote ${poly.number}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                        color: AppColors.textPrimary,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lot.landName ?? 'Loteamento',
                      style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              StatusBadge(status: lot.status),
            ],
          ),
          const SizedBox(height: 24),

          // Informações de Cliente (Se reservado/vendido)
          if (!isAvailable && hasClient) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.muted.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.person_outline, color: AppColors.textSecondary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Cliente', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                        Text(lot.clientName!, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        if (lot.clientDocument != null)
                          Text('Doc: ${lot.clientDocument}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Grid de Especificações
          Text('Especificações', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          Row(
            children: [
              _InfoCard(label: 'Área Total', value: '${NumberFormat.decimalPattern('pt_BR').format(lot.area)} m²'),
              const SizedBox(width: 12),
              _InfoCard(label: 'Valor de Tabela', value: currencyFormatter.format(lot.price)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _InfoCard(label: 'Frente', value: lot.frontMeasure != null ? '${NumberFormat.decimalPattern('pt_BR').format(lot.frontMeasure)} m' : 'N/A'),
              const SizedBox(width: 12),
              _InfoCard(label: 'Fundo', value: lot.backMeasure != null ? '${NumberFormat.decimalPattern('pt_BR').format(lot.backMeasure)} m' : 'N/A'),
            ],
          ),
          if (lot.registration != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                _InfoCard(label: 'Matrícula', value: lot.registration!),
              ],
            ),
          ],
          
          const SizedBox(height: 32),

          // Botões Contextuais
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isAvailable ? AppColors.primary : AppColors.surface,
                foregroundColor: isAvailable ? Colors.white : AppColors.primary,
                side: BorderSide(color: isAvailable ? AppColors.primary : AppColors.border),
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              onPressed: () {
                if (isAvailable) {
                  Navigator.pop(context);
                  showReservationDialog(context, lot);
                } else {
                  // Ação para ver contrato/proposta
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Visualização de contratos em breve.')),
                  );
                }
              },
              child: Text(
                isAvailable ? 'Fazer Reserva' : 'Ver Contrato/Proposta',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String label;
  final String value;

  const _InfoCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }
}
