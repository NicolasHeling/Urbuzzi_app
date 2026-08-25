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

// ─── Painter ───────────────────────────────────────────────────────────────

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
        ..color = baseColor.withValues(alpha: isSelected ? 0.78 : 0.58);
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

// ─── Page ──────────────────────────────────────────────────────────────────

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

  void _resetZoom() {
    _transformationController.value = Matrix4.identity();
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
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: _SelectedLotPanel(
            poly: poly,
            lot: _lotForPolygon(poly, lots),
            onClose: () => Navigator.pop(context),
            isBottomSheet: true,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final lotsState = ref.watch(lotsControllerProvider);

    return lotsState.when(
      data: (lots) => _buildContent(context, lots),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Erro: $error')),
    );
  }

  Widget _buildContent(BuildContext context, List<Lot> lots) {
    final Map<String, int> counts = {for (final s in AppColors.statusOrder) s: 0};
    for (var lot in lots) {
      counts[lot.status] = (counts[lot.status] ?? 0) + 1;
    }

    return LayoutBuilder(builder: (context, constraints) {
      final isWide = constraints.maxWidth > 900;

      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: _OverviewDashboard(counts: counts, total: lots.length),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: isWide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ── Mapa (flex 3) ──
                        Expanded(
                          flex: 3,
                          child: _MapCard(
                            zoom: _zoom,
                            lotCount: lots.length,
                            transformationController: _transformationController,
                            selectedPolygon: _selectedPolygon,
                            lots: lots,
                            onTapDown: (d) => _handleTapDown(d, lots, true),
                            onZoomIn: () => _zoomBy(1.25),
                            onZoomOut: () => _zoomBy(0.8),
                            onReset: _resetZoom,
                          ),
                        ),
                        const SizedBox(width: 16),
                        // ── Painel lateral ──
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
                            lotCount: lots.length,
                            transformationController: _transformationController,
                            selectedPolygon: _selectedPolygon,
                            lots: lots,
                            onTapDown: (d) => _handleTapDown(d, lots, false),
                            onZoomIn: () => _zoomBy(1.25),
                            onZoomOut: () => _zoomBy(0.8),
                            onReset: _resetZoom,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _SummaryCard(counts: counts),
                      ],
                    ),
            ),
          ),
        ],
      );
    });
  }
}

// ─── Overview Dashboard ────────────────────────────────────────────────────

class _OverviewDashboard extends StatelessWidget {
  final Map<String, int> counts;
  final int total;

  const _OverviewDashboard({required this.counts, required this.total});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _OverviewCard(
          title: 'Total de Lotes',
          value: total.toString(),
          icon: Icons.landscape_outlined,
          color: AppColors.primary,
        ),
        _OverviewCard(
          title: 'Lotes Disponíveis',
          value: (counts['Disponível'] ?? 0).toString(),
          icon: Icons.check_circle_outline,
          color: AppColors.disponivel,
        ),
        _OverviewCard(
          title: 'Reservas Ativas',
          value: (counts['Reservado'] ?? 0).toString(),
          icon: Icons.bookmark_outline,
          color: AppColors.reservado,
        ),
        _OverviewCard(
          title: 'Em Aprovação',
          value: (counts['Em Aprovação'] ?? 0).toString(),
          icon: Icons.pending_actions_outlined,
          color: AppColors.emAprovacao,
        ),
      ],
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _OverviewCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Icon(icon, size: 28, color: color.withValues(alpha: 0.2)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  color: AppColors.textPrimary, // Changed to textPrimary per instructions, could be primary or textPrimary
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Map Card ──────────────────────────────────────────────────────────────

class _MapCard extends StatelessWidget {
  final double zoom;
  final int lotCount;
  final TransformationController transformationController;
  final LotPolygon? selectedPolygon;
  final List<Lot> lots;
  final void Function(TapDownDetails) onTapDown;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onReset;

  const _MapCard({
    required this.zoom,
    required this.lotCount,
    required this.transformationController,
    required this.selectedPolygon,
    required this.lots,
    required this.onTapDown,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final blockCenters = MapData.blockCenters;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Toolbar do mapa ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
            ),
            child: Row(
              children: [
                // Legenda de status (igual ao protótipo)
                Expanded(
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: AppColors.statusOrder.map((status) {
                      final color = AppColors.statusColor(status);
                      final bg = AppColors.statusBgColor(status);
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: bg,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              status,
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: color,
                                height: 1,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(width: 12),
                // Rótulo "Planta de parcelamento"
                Text(
                  'Planta de parcelamento · Gleba 1',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          // ── Canvas do mapa ──
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
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

                // Dica + zoom %
                Positioned(
                  left: 12,
                  bottom: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.surface.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      'Arraste para mover · role para dar zoom · ${(zoom * 100).round()}%',
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ),
                ),

                // Controles de zoom (direita-baixo)
                Positioned(
                  right: 12,
                  bottom: 12,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 6)],
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Column(
                      children: [
                        _ZoomButton(icon: Icons.add_rounded, onTap: onZoomIn, tooltip: 'Aproximar'),
                        _ZoomButton(icon: Icons.remove_rounded, onTap: onZoomOut, tooltip: 'Afastar'),
                        _ZoomButton(icon: Icons.my_location_rounded, onTap: onReset, tooltip: 'Centralizar'),
                      ],
                    ),
                  ),
                ),

                // Bússola (direita-topo)
                Positioned(
                  right: 12,
                  top: 12,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.border),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 4)],
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'N',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
                    ),
                  ),
                ),
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
  final String tooltip;
  const _ZoomButton({required this.icon, required this.onTap, required this.tooltip});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 32,
          height: 32,
          child: Icon(icon, size: 16, color: AppColors.textSecondary),
        ),
      ),
    );
  }
}

// ─── Selected Lot Panel ────────────────────────────────────────────────────

class _SelectedLotPanel extends StatelessWidget {
  final LotPolygon? poly;
  final Lot? lot;
  final VoidCallback? onClose;
  final bool isBottomSheet;

  const _SelectedLotPanel({required this.poly, required this.lot, this.onClose, this.isBottomSheet = false});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Container(
      width: double.infinity,
      padding: isBottomSheet ? const EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 40) : const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: isBottomSheet ? const BorderRadius.vertical(top: Radius.circular(24)) : BorderRadius.circular(16),
        border: isBottomSheet ? null : Border.all(color: AppColors.border),
        boxShadow: isBottomSheet ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'LOTE SELECIONADO',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMuted,
                  letterSpacing: 1.2,
                ),
              ),
              if (onClose != null)
                GestureDetector(
                  onTap: onClose,
                  child: const Icon(Icons.close_rounded, size: 16, color: AppColors.textMuted),
                ),
            ],
          ),
          const SizedBox(height: 10),
          if (poly == null)
            const Text(
              'Toque em um lote na planta para ver os detalhes.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            )
          else ...[
            Text(
              'Lote ${poly!.number} · Quadra ${poly!.block}',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: AppColors.textPrimary, height: 1.1),
            ),
            const SizedBox(height: 2),
            Text(
              lot?.landName ?? 'Loteamento Morada do Sol',
              style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            if (lot == null)
              const StatusBadge(status: 'Não mapeado')
            else ...[
              // Preço em destaque
              Text(
                currencyFormatter.format(lot!.price),
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 22, color: AppColors.primary, height: 1.1),
              ),
              const SizedBox(height: 10),
              StatusBadge(status: lot!.status),
              const SizedBox(height: 14),

              // Medidas em grid de 3
              Row(
                children: [
                  _MeasureTile(label: 'Área', value: '${lot!.area.toStringAsFixed(0)} m²'),
                  const SizedBox(width: 6),
                  _MeasureTile(label: 'Frente', value: lot!.frontMeasure != null ? '${lot!.frontMeasure} m' : '—'),
                  const SizedBox(width: 6),
                  _MeasureTile(label: 'Fundo', value: lot!.backMeasure != null ? '${lot!.backMeasure} m' : '—'),
                ],
              ),
              const SizedBox(height: 16),

              // Botão de reserva
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: lot!.status == 'Disponível' ? AppColors.primary : AppColors.border,
                    foregroundColor: lot!.status == 'Disponível' ? Colors.white : AppColors.textMuted,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  onPressed: lot!.status == 'Disponível' ? () => showReservationDialog(context, lot!) : null,
                  child: const Text('Fazer Reserva', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _MeasureTile extends StatelessWidget {
  final String label;
  final String value;
  const _MeasureTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(label.toUpperCase(),
                style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600, color: AppColors.textMuted, letterSpacing: 0.8)),
            const SizedBox(height: 3),
            Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }
}

// ─── Summary Card ──────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final Map<String, int> counts;
  const _SummaryCard({required this.counts});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'RESUMO DO LOTEAMENTO',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textMuted,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          ...AppColors.statusOrder.map((status) {
            final color = AppColors.statusColor(status);
            final bg = AppColors.statusBgColor(status);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                        const SizedBox(width: 5),
                        Text(status, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: color, height: 1)),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${counts[status] ?? 0}',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
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
