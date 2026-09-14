import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';

class Commission {
  final String id;
  final String brokerName;
  final String lot;
  final double saleValue;
  final double commissionValue;
  final String status;

  Commission({
    required this.id,
    required this.brokerName,
    required this.lot,
    required this.saleValue,
    required this.commissionValue,
    required this.status,
  });
}

class CommissionsPage extends ConsumerStatefulWidget {
  const CommissionsPage({super.key});

  @override
  ConsumerState<CommissionsPage> createState() => _CommissionsPageState();
}

class _CommissionsPageState extends ConsumerState<CommissionsPage> {
  List<Commission> _commissions = [
    Commission(id: '1', brokerName: 'João Silva', lot: 'Quadra A · Lote 01', saleValue: 150000, commissionValue: 7500, status: 'Pendente'),
    Commission(id: '2', brokerName: 'Maria Souza', lot: 'Quadra B · Lote 05', saleValue: 180000, commissionValue: 9000, status: 'Pago'),
  ];

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'pt_BR', symbol: r'R$');
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Comissões',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppColors.border),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Corretor')),
                        DataColumn(label: Text('Lote')),
                        DataColumn(label: Text('Valor da Venda')),
                        DataColumn(label: Text('Comissão')),
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Ação')),
                      ],
                      rows: _commissions.map((c) {
                        return DataRow(
                          cells: [
                            DataCell(Text(c.brokerName)),
                            DataCell(Text(c.lot)),
                            DataCell(Text(currencyFormatter.format(c.saleValue))),
                            DataCell(Text(currencyFormatter.format(c.commissionValue))),
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: c.status == 'Pago' ? AppColors.disponivel.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  c.status,
                                  style: TextStyle(
                                    color: c.status == 'Pago' ? AppColors.disponivel : Colors.orange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              c.status == 'Pendente'
                                  ? ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          _commissions = _commissions.map((com) {
                                            if (com.id == c.id) {
                                              return Commission(
                                                id: com.id,
                                                brokerName: com.brokerName,
                                                lot: com.lot,
                                                saleValue: com.saleValue,
                                                commissionValue: com.commissionValue,
                                                status: 'Pago',
                                              );
                                            }
                                            return com;
                                          }).toList();
                                        });
                                      },
                                      child: const Text('Pagar'),
                                    )
                                  : const SizedBox.shrink(),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
