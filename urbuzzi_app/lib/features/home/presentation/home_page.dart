import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import '../../lots/presentation/lots_provider.dart';
import '../../lots/domain/models/lot.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/status_badge.dart';
import 'map_data.dart';
import '../../reservations/presentation/reservation_dialog.dart';

const double _mapWidth = 1200;
const double _mapHeight = 860;

class MapPainter extends CustomPainter {
  final List<Lot> lotsFromApi;
  final LotPolygon? selectedPolygon;

  MapPainter({required this.lotsFromApi, this.selectedPolygon});

  Lot? _matchLot(LotPolygon poly) {
    final blockLetter = String.fromCharCode(64 + int.parse(poly.block));
    final numberStr = poly.number.replaceFirst(RegExp(r'^0+'), '');
    try {
      return lotsFromApi.firstWhere((l) => l.block == blockLetter && l.number == numberStr);
    } catch (_) {
      return null;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (var poly in MapData.lots) {
      final path = Path();
      if (poly.points.isNotEmpty) {
        path.moveTo(poly.points.first.dx, poly.points.first.dy);
        for (int i = 1; i < poly.points.length; i++) {
          path.lineTo(poly.points[i].dx, poly.points[i].dy);
        }
        path.close();
      }

      final matchingLot = _matchLot(poly);
      final baseColor = matchingLot != null
          ? AppColors.statusColor(matchingLot.status)
          : AppColors.textMuted.withValues(alpha: 0.3);

      final isSelected = selectedPolygon == poly;

      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = baseColor.withValues(alpha: isSelected ? 0.75 : 0.55);
      canvas.drawPath(path, paint);

      final borderPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = isSelected ? 2.5 : 1.0
        ..color = isSelected ? AppColors.primary : Colors.black38;
      canvas.drawPath(path, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant MapPainter oldDelegate) {
    return oldDelegate.lotsFromApi != lotsFromApi || oldDelegate.selectedPolygon != selectedPolygon;
  }
}

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  LotPolygon? _selectedPolygon;
  final TransformationController _transformationController = TransformationController();
  double _zoom = 1.0;

  @override
  void initState() {
    super.initState();
    _transformationController.addListener(_onTransformChanged);
  }

  @override
  void dispose() {
    _transformationController.removeListener(_onTransformChanged);
    _transformationController.dispose();
    super.dispose();
  }

  void _onTransformChanged() {
    final scale = _transformationController.value.getMaxScaleOnAxis();
    if ((scale - _zoom).abs() > 0.001) {
      setState(() => _zoom = scale);
    }
  }

  void _zoomBy(double factor) {
    final matrix = _transformationController.value.clone();
    final double newScale = (_zoom * factor).clamp(0.1, 4.0);
    final double currentScale = _zoom == 0 ? 1.0 : _zoom;
    final double ratio = newScale / currentScale;
    matrix.scaleByDouble(ratio, ratio, ratio, 1.0);
    _transformationController.value = matrix;
  }

  Lot? _lotForPolygon(LotPolygon? poly, List<Lot> lots) {
    if (poly == null) return null;
    final blockLetter = String.fromCharCode(64 + int.parse(poly.block));
    final numberStr = poly.number.replaceFirst(RegExp(r'^0+'), '');
    try {
      return lots.firstWhere((l) => l.block == blockLetter && l.number == numberStr);
    } catch (_) {
      return null;
    }
  }

  void _handleTapDown(TapDownDetails details, List<Lot> lots, bool isWide) {
    final Offset localPosition = _transformationController.toScene(details.localPosition);

    for (var poly in MapData.lots) {
      final path = Path();
      if (poly.points.isNotEmpty) {
        path.moveTo(poly.points.first.dx, poly.points.first.dy);
        for (int i = 1; i < poly.points.length; i++) {
          path.lineTo(poly.points[i].dx, poly.points[i].dy);
        }
        path.close();
      }

      if (path.contains(localPosition)) {
        setState(() => _selectedPolygon = poly);
        if (!isWide) {
          _showLotDetailsSheet(poly, lots);
        }
        return;
      }
    }

    setState(() => _selectedPolygon = null);
  }

  void _showLotDetailsSheet(LotPolygon poly, List<Lot> lots) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: _SelectedLotPanel(
            poly: poly,
            lot: _lotForPolygon(poly, lots),
            onClose: () => Navigator.pop(context),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final lotsState = ref.watch(lotsControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: lotsState.when(
          data: (lots) => _buildContent(context, lots),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Erro: $error')),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<Lot> lots) {
    final Map<String, int> counts = {for (final s in AppColors.statusOrder) s: 0};
    for (var lot in lots) {
      counts[lot.status] = (counts[lot.status] ?? 0) + 1;
    }

    return LayoutBuilder(builder: (context, constraints) {
      final isWide = constraints.maxWidth > 900;

      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(lotCount: lots.length),
            const SizedBox(height: 14),
            StatusLegend(),
            const SizedBox(height: 16),
            Expanded(
              child: isWide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: 3,
                          child: _MapCard(
                            zoom: _zoom,
                            transformationController: _transformationController,
                            selectedPolygon: _selectedPolygon,
                            lots: lots,
                            onTapDown: (d) => _handleTapDown(d, lots, true),
                            onZoomIn: () => _zoomBy(1.25),
                            onZoomOut: () => _zoomBy(0.8),
                          ),
                        ),
                        const SizedBox(width: 16),
                        SizedBox(
                          width: 320,
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                _SelectedLotPanel(
                                  poly: _selectedPolygon,
                                  lot: _lotForPolygon(_selectedPolygon, lots),
                                ),
                                const SizedBox(height: 16),
                                _SummaryCard(counts: counts),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: _MapCard(
                            zoom: _zoom,
                            transformationController: _transformationController,
                            selectedPolygon: _selectedPolygon,
                            lots: lots,
                            onTapDown: (d) => _handleTapDown(d, lots, false),
                            onZoomIn: () => _zoomBy(1.25),
                            onZoomOut: () => _zoomBy(0.8),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _SummaryCard(counts: counts),
                      ],
                    ),
            ),
          ],
        ),
      );
    });
  }
}

class _Header extends StatelessWidget {
  final int lotCount;
  const _Header({required this.lotCount});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mapa Interativo',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 4),
        Text(
          'Loteamento Morada do Sol · 15 quadras · $lotCount lotes',
          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _MapCard extends StatelessWidget {
  final double zoom;
  final TransformationController transformationController;
  final LotPolygon? selectedPolygon;
  final List<Lot> lots;
  final void Function(TapDownDetails) onTapDown;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;

  const _MapCard({
    required this.zoom,
    required this.transformationController,
    required this.selectedPolygon,
    required this.lots,
    required this.onTapDown,
    required this.onZoomIn,
    required this.onZoomOut,
  });

  @override
  Widget build(BuildContext context) {
    final blockCenters = MapData.blockCenters;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            top: 14,
            left: 16,
            child: Text(
              'Planta de parcelamento · Gleba 1',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Positioned.fill(
            top: 44,
            child: InteractiveViewer(
              transformationController: transformationController,
              minScale: 0.1,
              maxScale: 4.0,
              constrained: false,
              boundaryMargin: const EdgeInsets.all(500),
              child: GestureDetector(
                onTapDown: onTapDown,
                child: SizedBox(
                  width: _mapWidth,
                  height: _mapHeight,
                  child: Stack(
                    children: [
                      SvgPicture.asset('assets/mapa.svg', fit: BoxFit.fill),
                      CustomPaint(
                        size: const Size(_mapWidth, _mapHeight),
                        painter: MapPainter(lotsFromApi: lots, selectedPolygon: selectedPolygon),
                      ),
                      ...blockCenters.entries.map((entry) {
                        return Positioned(
                          left: entry.value.dx - 18,
                          top: entry.value.dy - 10,
                          child: IgnorePointer(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.85),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Q${entry.key}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Bússola
          Positioned(
            top: 14,
            right: 16,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 4)],
              ),
              alignment: Alignment.center,
              child: const Text(
                'N',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textPrimary),
              ),
            ),
          ),
          // Escala
          Positioned(
            left: 16,
            bottom: 14,
            child: Text(
              '0     50     100 m',
              style: TextStyle(fontSize: 11, color: AppColors.textMuted, fontFeatures: const [FontFeature.tabularFigures()]),
            ),
          ),
          // Dica de interação + zoom %
          Positioned(
            bottom: 14,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  'Arraste para mover · role para dar zoom · ${(zoom * 100).round()}%',
                  style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                ),
              ),
            ),
          ),
          // Controles de zoom
          Positioned(
            right: 16,
            bottom: 14,
            child: Column(
              children: [
                _ZoomButton(icon: Icons.add, onTap: onZoomIn),
                const SizedBox(height: 6),
                _ZoomButton(icon: Icons.remove, onTap: onZoomOut),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ZoomButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _ZoomButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: SizedBox(
          width: 32,
          height: 32,
          child: Icon(icon, size: 18, color: AppColors.textSecondary),
        ),
      ),
    );
  }
}

class _SelectedLotPanel extends StatelessWidget {
  final LotPolygon? poly;
  final Lot? lot;
  final VoidCallback? onClose;

  const _SelectedLotPanel({required this.poly, required this.lot, this.onClose});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Lote selecionado',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary),
              ),
              if (onClose != null)
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: onClose,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          const SizedBox(height: 14),
          if (poly == null)
            const Text(
              'Toque em um lote na planta para ver os detalhes.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            )
          else ...[
            Text(
              'Lote ${poly!.number} · Quadra ${poly!.block}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 2),
            Text(
              lot?.landName ?? 'Loteamento Morada do Sol',
              style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            if (lot == null)
              const StatusBadge(status: 'Não mapeado no BD')
            else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    currencyFormatter.format(lot!.price),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textPrimary),
                  ),
                  StatusBadge(status: lot!.status),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _MeasureStat(label: 'Área', value: '${lot!.area.toStringAsFixed(0)} m²'),
                  _MeasureStat(label: 'Frente', value: lot!.frontMeasure != null ? '${lot!.frontMeasure} m' : '—'),
                  _MeasureStat(label: 'Fundo', value: lot!.backMeasure != null ? '${lot!.backMeasure} m' : '—'),
                ],
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => showReservationDialog(context, lot!),
                  child: const Text('Nova Reserva'),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _MeasureStat extends StatelessWidget {
  final String label;
  final String value;
  const _MeasureStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final Map<String, int> counts;
  const _SummaryCard({required this.counts});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumo do loteamento',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          ...AppColors.statusOrder.map((status) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(color: AppColors.statusColor(status), shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(status, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
                  ),
                  Text(
                    '${counts[status] ?? 0}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
