import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';

class FinancingSimulator extends StatefulWidget {
  final double lotValue;

  const FinancingSimulator({super.key, required this.lotValue});

  @override
  State<FinancingSimulator> createState() => _FinancingSimulatorState();
}

class _FinancingSimulatorState extends State<FinancingSimulator> {
  late TextEditingController _downPaymentController;
  late TextEditingController _installmentsController;
  late TextEditingController _interestRateController;

  double _installmentValue = 0.0;
  List<Map<String, dynamic>> _installmentList = [];

  @override
  void initState() {
    super.initState();
    _downPaymentController = TextEditingController(text: (widget.lotValue * 0.1).toStringAsFixed(2)); // Default 10% sinal
    _installmentsController = TextEditingController(text: '120'); // Default 120 meses
    _interestRateController = TextEditingController(text: '1.0'); // Default 1% ao mês
    _calculate();
  }

  @override
  void dispose() {
    _downPaymentController.dispose();
    _installmentsController.dispose();
    _interestRateController.dispose();
    super.dispose();
  }

  void _calculate() {
    final downPayment = double.tryParse(_downPaymentController.text) ?? 0.0;
    final n = int.tryParse(_installmentsController.text) ?? 1;
    final interestRateStr = _interestRateController.text.replaceAll(',', '.');
    final i = (double.tryParse(interestRateStr) ?? 0.0) / 100.0;

    final pv = widget.lotValue - downPayment;

    if (pv <= 0 || n <= 0) {
      setState(() {
        _installmentValue = 0.0;
        _installmentList = [];
      });
      return;
    }

    double pmt = 0.0;
    if (i == 0) {
      pmt = pv / n;
    } else {
      pmt = pv * (i * pow(1 + i, n)) / (pow(1 + i, n) - 1);
    }

    final list = <Map<String, dynamic>>[];
    final now = DateTime.now();
    for (int j = 1; j <= n; j++) {
      final dueDate = DateTime(now.year, now.month + j, now.day);
      list.add({
        'number': j,
        'dueDate': dueDate,
        'value': pmt,
      });
    }

    setState(() {
      _installmentValue = pmt;
      _installmentList = list;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final dateFormatter = DateFormat('dd/MM/yyyy');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Simulação (Tabela Price)',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTextField('Valor do Lote (R\$)', widget.lotValue.toStringAsFixed(2), readOnly: true),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField('Sinal (R\$)', null, controller: _downPaymentController, onChanged: (_) => _calculate()),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildTextField('Parcelas (Qtd)', null, controller: _installmentsController, onChanged: (_) => _calculate(), isInt: true),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField('Juros (a.m. %)', null, controller: _interestRateController, onChanged: (_) => _calculate()),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              const Text('Valor da Parcela Fixa', style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(
                currencyFormatter.format(_installmentValue),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.primary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        if (_installmentList.isNotEmpty) ...[
          const Text(
            'Cronograma de Pagamento',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Container(
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: _installmentList.length,
              separatorBuilder: (_, _) => const Divider(height: 1, color: AppColors.border),
              itemBuilder: (context, index) {
                final item = _installmentList[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${item['number']}ª Parcela - ${dateFormatter.format(item['dueDate'])}', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                      Text(currencyFormatter.format(item['value']), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textPrimary)),
                    ],
                  ),
                );
              },
            ),
          ),
        ]
      ],
    );
  }

  Widget _buildTextField(String label, String? initialValue, {TextEditingController? controller, bool readOnly = false, void Function(String)? onChanged, bool isInt = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        TextFormField(
          initialValue: initialValue,
          controller: controller,
          readOnly: readOnly,
          onChanged: onChanged,
          keyboardType: TextInputType.numberWithOptions(decimal: !isInt),
          style: TextStyle(
            fontSize: 14,
            fontWeight: readOnly ? FontWeight.w600 : FontWeight.normal,
            color: readOnly ? AppColors.textSecondary : AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            filled: readOnly,
            fillColor: readOnly ? AppColors.muted.withValues(alpha: 0.3) : AppColors.surface,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.primary)),
          ),
        ),
      ],
    );
  }
}
