import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import '../../lots/presentation/lots_provider.dart';
import '../../lots/domain/models/lot.dart';
import 'map_data.dart';
import '../../reservations/presentation/reservation_dialog.dart';

class MapPainter extends CustomPainter {
  final List<Lot> lotsFromApi;
  final LotPolygon? selectedPolygon;

  MapPainter({required this.lotsFromApi, this.selectedPolygon});

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Disponível':
        return Colors.green;
      case 'Reservado':
        return Colors.orange;
      case 'Em aprovação':
        return Colors.yellow.shade700;
      case 'Bloqueado':
        return Colors.grey;
      case 'Vendido':
        return Colors.red;
      case 'Cancelado':
        return Colors.white;
      default:
        return Colors.grey.shade300;
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

      // Encontrar lote na API
      String blockStr = poly.block.replaceFirst(RegExp(r'^0+'), ''); // "01" -> "1"
      String numberStr = poly.number.replaceFirst(RegExp(r'^0+'), ''); // "01" -> "1"

      String blockLetter = String.fromCharCode(64 + int.parse(poly.block)); // Q01 -> A, Q02 -> B
      
      Lot? matchingLot;
      try {
        matchingLot = lotsFromApi.firstWhere(
            (l) => l.block == blockLetter && l.number == numberStr);
      } catch (_) {}

      final baseColor = matchingLot != null ? _getStatusColor(matchingLot.status) : Colors.grey.shade300;
      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = baseColor.withOpacity(0.6); // Semi-transparente para ver o SVG de fundo

      // Desenha o fundo do lote
      canvas.drawPath(path, paint);

      // Desenha a borda
      final borderPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..color = selectedPolygon == poly ? Colors.blue : Colors.black45;
      
      if (selectedPolygon == poly) {
        borderPaint.strokeWidth = 3.0;
        borderPaint.color = Colors.blue;
      }

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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Disponível':
        return Colors.green;
      case 'Reservado':
        return Colors.orange;
      case 'Em aprovação':
        return Colors.yellow.shade700;
      case 'Bloqueado':
        return Colors.grey;
      case 'Vendido':
        return Colors.red;
      case 'Cancelado':
        return Colors.white;
      default:
        return Colors.grey.shade300;
    }
  }

  void _handleTapDown(TapDownDetails details, List<Lot> lots) {
    final RenderBox referenceBox = context.findRenderObject() as RenderBox;
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
        setState(() {
          _selectedPolygon = poly;
        });
        _showLotDetails(poly, lots);
        return;
      }
    }

    setState(() {
      _selectedPolygon = null;
    });
  }

  void _showLotDetails(LotPolygon poly, List<Lot> lots) {
    final currencyFormatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    
    String blockLetter = String.fromCharCode(64 + int.parse(poly.block));
    String numberStr = poly.number.replaceFirst(RegExp(r'^0+'), '');
    
    Lot? lot;
    try {
      lot = lots.firstWhere((l) => l.block == blockLetter && l.number == numberStr);
    } catch (_) {}

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Quadra ${blockLetter} - Lote ${poly.number}',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  if (lot != null)
                    Chip(
                      backgroundColor: _getStatusColor(lot.status).withOpacity(0.2),
                      label: Text(lot.status),
                      labelStyle: TextStyle(
                        color: _getStatusColor(lot.status),
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  else
                    const Chip(label: Text('Não Mapeado no BD')),
                ],
              ),
              const SizedBox(height: 16),
              if (lot != null) ...[
                Text('Área: ${lot.area} m²'),
                const SizedBox(height: 8),
                Text(
                  'Valor: ${currencyFormatter.format(lot.price)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 24),
                const Text('Alterar Status do Lote:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: lot.status,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  items: ['Disponível', 'Reservado', 'Em aprovação', 'Bloqueado', 'Vendido', 'Cancelado']
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (newStatus) {
                    if (newStatus != null && newStatus != lot!.status) {
                      ref.read(lotsControllerProvider.notifier).updateLotStatus(lot.id, newStatus);
                      Navigator.pop(context);
                    }
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final lotsState = ref.watch(lotsControllerProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.9),
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text('Mapa Interativo', style: TextStyle(fontWeight: FontWeight.bold)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(24),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Text(
              'Loteamento Morada do Sol · 15 quadras · 192 lotes',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ),
      ),
      body: lotsState.when(
        data: (lots) {
          final Map<String, int> counts = {
            'Disponível': 0,
            'Reservado': 0,
            'Em aprovação': 0,
            'Bloqueado': 0,
            'Vendido': 0,
            'Cancelado': 0,
          };
          for (var lot in lots) {
            counts[lot.status] = (counts[lot.status] ?? 0) + 1;
          }

          return Stack(
            children: [
              Positioned.fill(
                child: InteractiveViewer(
                  transformationController: _transformationController,
                  minScale: 0.1,
                  maxScale: 4.0,
                  constrained: false,
                  boundaryMargin: const EdgeInsets.all(500),
                  child: Stack(
                    children: [
                      SizedBox(
                        width: 1200,
                        height: 860,
                        child: SvgPicture.asset('assets/mapa.svg', fit: BoxFit.fill),
                      ),
                      GestureDetector(
                        onTapDown: (details) => _handleTapDown(details, lots),
                        child: CustomPaint(
                          size: const Size(1200, 860),
                          painter: MapPainter(
                            lotsFromApi: lots,
                            selectedPolygon: _selectedPolygon,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 24,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Resumo do loteamento',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 16,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: counts.keys.map((status) {
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(status),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text('$status (${counts[status]})', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                              ],
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Erro: $error')),
      ),
    );
  }
}

