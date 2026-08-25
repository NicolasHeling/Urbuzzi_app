import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../crm/presentation/clients_provider.dart';
import '../../lots/domain/models/lot.dart';
import 'reservations_provider.dart';

class ReservationDialog extends ConsumerStatefulWidget {
  final Lot lot;
  const ReservationDialog({super.key, required this.lot});

  @override
  ConsumerState<ReservationDialog> createState() => _ReservationDialogState();
}

class _ReservationDialogState extends ConsumerState<ReservationDialog> {
  String? _selectedClientId;
  bool _isLoading = false;

  void _submit() async {
    if (_selectedClientId == null) return;
    setState(() => _isLoading = true);

    try {
      await ref.read(createReservationProvider({
        'clientId': _selectedClientId!,
        'lotId': widget.lot.id,
      }).future);

      if (mounted) {
        Navigator.pop(context, true); // Retorna sucesso
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reserva criada com sucesso para o Lote ${widget.lot.number}!'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            backgroundColor: Colors.green.shade800,
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
            backgroundColor: Colors.red.shade800,
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
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Selecione o cliente para a reserva (válida por 48h):'),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                hint: const Text('Escolha o Cliente'),
                value: _selectedClientId,
                items: clients.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                onChanged: (val) {
                  setState(() => _selectedClientId = val);
                },
              ),
            ],
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
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
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
