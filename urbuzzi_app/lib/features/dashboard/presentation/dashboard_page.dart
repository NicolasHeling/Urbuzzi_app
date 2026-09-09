import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_colors.dart';
import 'dashboard_provider.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metricsAsync = ref.watch(analyticsSummaryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: metricsAsync.when(
        data: (metrics) => _buildDashboard(context, metrics),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Erro ao carregar dashboard: $e')),
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, AnalyticsSummary metrics) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dashboard Analítico',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Resumo de lotes e propostas.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 48),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _buildPieChartCard(metrics.lotStatus),
                ),
                const SizedBox(width: 32),
                Expanded(
                  child: _buildBarChartCard(metrics.proposalsPerColumn),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChartCard(Map<String, dynamic> data) {
    return _ChartCard(
      title: 'Status dos Lotes',
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 60,
          sections: _buildPieSections(data),
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieSections(Map<String, dynamic> data) {
    return data.entries.map((entry) {
      final value = (entry.value as num).toDouble();
      return PieChartSectionData(
        value: value,
        title: '${entry.key}\n$value',
        radius: 80,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        color: AppColors.statusColor(entry.key),
      );
    }).toList();
  }

  Widget _buildBarChartCard(Map<String, dynamic> data) {
    final maxY = data.values.fold(0.0, (prev, e) => (e as num).toDouble() > prev ? (e as num).toDouble() : prev) * 1.2;
    
    final barGroups = <BarChartGroupData>[];
    int index = 0;
    final keys = data.keys.toList();
    for (var key in keys) {
      barGroups.add(
        BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: (data[key] as num).toDouble(),
              color: AppColors.primary,
              width: 32,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6)),
            ),
          ],
        ),
      );
      index++;
    }

    return _ChartCard(
      title: 'Propostas por Etapa',
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY.clamp(10.0, 999999.0),
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (group) => AppColors.surface,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '${keys[group.x]}\n${rod.toY.toInt()}',
                  const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  if (value >= 0 && value < keys.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(
                        _truncate(keys[value.toInt()]),
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11, color: AppColors.textPrimary),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  if (value % 1 == 0) {
                    return Text(
                      value.toInt().toString(),
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxY > 0 ? (maxY / 5).ceilToDouble().clamp(1.0, 99999.0) : 5.0,
            getDrawingHorizontalLine: (value) => FlLine(
              color: AppColors.border,
              strokeWidth: 1,
              dashArray: [4, 4],
            ),
          ),
          barGroups: barGroups,
        ),
      ),
    );
  }

  String _truncate(String text) {
    if (text.length > 10) {
      return '${text.substring(0, 8)}...';
    }
    return text;
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _ChartCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 32),
          Expanded(child: child),
        ],
      ),
    );
  }
}
