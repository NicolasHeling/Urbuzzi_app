import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/auth/user_role.dart';
import '../../auth/presentation/auth_provider.dart';
import 'reservations_provider.dart';

class ReservationsPage extends ConsumerWidget {
  const ReservationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pendingReservationsProvider);
    final userRole = ref.watch(currentUserRoleProvider);
    final canApprove = userRole == UserRole.gestor || userRole == UserRole.administrador;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: state.when(
            data: (reservations) {
              if (reservations.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.inbox_outlined, size: 72, color: AppColors.border),
                      const SizedBox(height: 16),
                      const Text('Nenhuma reserva pendente', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('Todas as reservas já foram processadas.', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                    ],
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(24),
                itemCount: reservations.length,
                separatorBuilder: (context, index) => const Divider(color: AppColors.border),
                itemBuilder: (context, index) {
                  final res = reservations[index];
                  final dateFormat = DateFormat('dd/MM/yyyy');
                  final expDate = res.expirationDate != null ? dateFormat.format(res.expirationDate!) : 'N/A';
                  
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Reserva ${res.id.substring(0, 8)} - Lote ${res.lot?.block ?? ''} ${res.lot?.number ?? ''}',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    subtitle: Text(
                      'Cliente: ${res.client?.name ?? 'Desconhecido'}\nExpira em: $expDate',
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    trailing: canApprove
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              OutlinedButton.icon(
                                onPressed: () async {
                                  try {
                                    await ref.read(pendingReservationsProvider.notifier).cancel(res.id, res.lot!.id);
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Falha ao cancelar reserva: $e'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.cancelado,
                                  side: const BorderSide(color: AppColors.cancelado),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                icon: const Icon(Icons.close, size: 16),
                                label: const Text('Cancelar'),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton.icon(
                                onPressed: () async {
                                  try {
                                    await ref.read(pendingReservationsProvider.notifier).approve(res.id, res.lot!.id);
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Falha ao aprovar venda: $e'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                icon: const Icon(Icons.check, size: 16),
                                label: const Text('Aprovar Venda'),
                              ),
                            ],
                          )
                        : null,
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
            error: (err, st) => Center(child: Text('Erro ao carregar reservas: $err')),
          ),
        ),
      ),
    );
  }
}
