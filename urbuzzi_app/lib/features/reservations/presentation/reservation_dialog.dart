import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../crm/presentation/clients_provider.dart';
import '../../lots/domain/models/lot.dart';
import '../../lots/presentation/lots_provider.dart';
import 'reservations_provider.dart';
import '../../../core/theme/app_colors.dart';

class ReservationDialog extends ConsumerStatefulWidget {
  final Lot lot;
  const ReservationDialog({super.key, required this.lot});

  @override
  ConsumerState<ReservationDialog> createState() => _ReservationDialogState();
}

class _ReservationDialogState extends ConsumerState<ReservationDialog> {
  String? _selectedClientId;
  bool _isLoading = false;

  final _formKey = GlobalKey<FormState>();

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      await ref.read(createReservationProvider({
        'clientId': _selectedClientId!,
        'lotId': widget.lot.id,
      }).future);

      // Atualização Reativa Otimizada
      ref.read(lotsControllerProvider.notifier).updateLotInState(widget.lot.id, 'Reservado');

      if (mounted) {
        Navigator.pop(context, true); // Retorna sucesso
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reserva criada com sucesso para o Lote ${widget.lot.number}!'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            backgroundColor: AppColors.disponivel,
          ),
        );
      }
    } on DioException catch (e) {
      if (mounted) {
        final String errorMsg = e.response?.data['error'] ?? e.response?.data['message'] ?? 'Erro desconhecido na API';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao reservar lote: $errorMsg'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            backgroundColor: AppColors.vendido,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao reservar lote: $e'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            backgroundColor: AppColors.vendido,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final clientsAsync = ref.watch(clientsProvider);

    return AlertDialog(
      title: Text('Reservar Lote ${widget.lot.number}'),
      content: clientsAsync.when(
        data: (clients) {
          if (clients.isEmpty) {
            return const Text('Nenhum cliente cadastrado. Cadastre um cliente primeiro no CRM.');
          }
          return Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Selecione o cliente para a reserva (válida por 48h):'),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    filled: true,
                    fillColor: AppColors.muted,
                  ),
                  hint: const Text('Escolha o Cliente'),
                  initialValue: _selectedClientId,
                  items: clients.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                  onChanged: (val) {
                    setState(() => _selectedClientId = val);
                  },
                  validator: (val) => val == null || val.isEmpty ? 'Selecione um cliente' : null,
                ),
              ],
            ),
          );
        },
        loading: () => const SizedBox(height: 50, child: Center(child: CircularProgressIndicator())),
        error: (err, stack) => Text('Erro ao carregar clientes: $err'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: (_selectedClientId == null || _isLoading) ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary, 
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.6),
            disabledForegroundColor: Colors.white,
          ),
          child: _isLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Confirmar Reserva'),
        ),
      ],
    );
  }
}

Future<bool?> showReservationDialog(BuildContext context, Lot lot) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => ReservationDialog(lot: lot),
  );
}
