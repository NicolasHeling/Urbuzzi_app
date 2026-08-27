import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../lots/presentation/lots_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/status_badge.dart';

class VitrinePage extends ConsumerWidget {
  const VitrinePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lotsState = ref.watch(publicLotsProvider);
    final currencyFormatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              color: AppColors.surface,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(
                          child: Text(
                            'U',
                            style: TextStyle(color: AppColors.primaryForeground, fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Urbizzi',
                        style: TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: () => Navigator.of(context).pushReplacementNamed('/login'),
                    icon: const Icon(Icons.login, size: 18),
                    label: const Text('Área do corretor', style: TextStyle(fontWeight: FontWeight.w600)),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              color: AppColors.accent.withValues(alpha: 0.4),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
              child: Column(
                children: [
                  const Text(
                    'Lotes disponíveis para você construir',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Consulte área, valor e disponibilidade atualizados. Fale direto com nosso time comercial pelo WhatsApp e garanta a sua reserva.',
                    style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          lotsState.when(
            data: (lots) {
              if (lots.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(48.0),
                    child: Center(child: Text('Nenhum lote cadastrado no momento.', style: TextStyle(color: AppColors.textSecondary))),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.all(24),
                sliver: SliverLayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.crossAxisExtent > 800;
                    return SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isWide ? 3 : 2,
                        childAspectRatio: 0.8,
                        crossAxisSpacing: 24,
                        mainAxisSpacing: 24,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final lot = lots[index];
                          final isAvailable = lot.status == 'Disponível';
                          return Opacity(
                            opacity: isAvailable ? 1.0 : 0.6,
                            child: Container(
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppColors.border),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 32,
                                    offset: const Offset(0, 12),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Container(
                                    height: 128,
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [AppColors.accent, AppColors.muted],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                    ),
                                    child: Center(
                                      child: Icon(Icons.landscape, size: 64, color: AppColors.primary.withValues(alpha: 0.2)),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  const Icon(Icons.location_on, size: 14, color: AppColors.textSecondary),
                                                  const SizedBox(width: 4),
                                                  Expanded(
                                                    child: Text(
                                                      lot.landName ?? 'Loteamento',
                                                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                'Lote ${lot.number} · Qd ${lot.block}',
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: AppColors.textPrimary),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  const Icon(Icons.straighten, size: 14, color: AppColors.textSecondary),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    '${NumberFormat.decimalPattern('pt_BR').format(lot.area)} m²',
                                                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                currencyFormatter.format(lot.price),
                                                style: const TextStyle(
                                                  color: AppColors.primary,
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 24,
                                                ),
                                              ),
                                              const SizedBox(height: 12),
                                              StatusBadge(status: lot.status),
                                              const SizedBox(height: 16),
                                              SizedBox(
                                                width: double.infinity,
                                                height: 48,
                                                child: FilledButton.icon(
                                                  onPressed: isAvailable ? () async {
                                                    final uri = Uri.parse('https://wa.me/5545999990000');
                                                    if (await canLaunchUrl(uri)) {
                                                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                                                    }
                                                  } : null,
                                                  icon: Icon(isAvailable ? Icons.chat : Icons.block, size: 18),
                                                  label: Text(isAvailable ? 'Falar com o Comercial' : 'Indisponível no momento', style: const TextStyle(fontWeight: FontWeight.w600)),
                                                  style: FilledButton.styleFrom(
                                                    backgroundColor: isAvailable ? const Color(0xFF25D366) : AppColors.muted,
                                                    foregroundColor: isAvailable ? Colors.white : AppColors.textSecondary,
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        childCount: lots.length,
                      ),
                    );
                  },
                ),
              );
            },
            loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
            error: (error, stack) => SliverFillRemaining(child: Center(child: Text('Erro: $error'))),
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(24),
              child: const Center(
                child: Text(
                  'Urbizzi · Gestão e vendas de loteamentos · CRECI-PR 12.345-J',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
