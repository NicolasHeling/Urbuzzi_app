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
      backgroundColor: const Color(0xFFF8FAFC), // Modern slate-50
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
              // MAPA INTERATIVO NO FUNDO
              Positioned.fill(
                child: InteractiveViewer(
                  transformationController: _transformationController,
                  minScale: 0.1,
                  maxScale: 4.0,
                  constrained: false,
                  boundaryMargin: const EdgeInsets.all(1000),
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

              // HEADER FLOATING (Top Left)
              Positioned(
                top: 24,
                left: 24,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Mapa Interativo',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Loteamento Morada do Sol · 15 quadras · 192 lotes',
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Planta de parcelamento · Gleba 1',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ),
              ),

              // LEGENDA FLOATING (Bottom Left)
              Positioned(
                bottom: 24,
                left: 24,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Resumo do loteamento',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A)),
                      ),
                      const SizedBox(height: 16),
                      ...counts.entries.map((e) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: _getStatusColor(e.key),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 12),
                              SizedBox(
                                width: 100,
                                child: Text(e.key, style: const TextStyle(fontSize: 13)),
                              ),
                              Text('${e.value}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),

              // LOTE SELECIONADO FLOATING PANEL (Right Side)
              if (_selectedPolygon != null)
                Positioned(
                  top: 24,
                  right: 24,
                  child: _buildSelectedLotPanel(lots),
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Erro: $error')),
      ),
    );
  }

  Widget _buildSelectedLotPanel(List<Lot> lots) {
    final poly = _selectedPolygon!;
    final currencyFormatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    String blockLetter = String.fromCharCode(64 + int.parse(poly.block));
    String numberStr = poly.number.replaceFirst(RegExp(r'^0+'), '');
    
    Lot? lot;
    try {
      lot = lots.firstWhere((l) => l.block == blockLetter && l.number == numberStr);
    } catch (_) {}

    return Container(
      width: 320,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Lote selecionado',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => setState(() => _selectedPolygon = null),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Lote $numberStr · Quadra $blockLetter',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
          ),
          Text(
            'Loteamento Morada do Sol',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          if (lot != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getStatusColor(lot.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _getStatusColor(lot.status).withOpacity(0.3)),
              ),
              child: Text(
                lot.status,
                style: TextStyle(
                  color: _getStatusColor(lot.status),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Área', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                    Text('${lot.area} m²', style: const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Valor', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                    Text(currencyFormatter.format(lot.price), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue)),
                  ],
                ),
              ],
            ),
            const Divider(height: 32),
            const Text('Alterar Status', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: lot.status,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              items: ['Disponível', 'Reservado', 'Em aprovação', 'Bloqueado', 'Vendido', 'Cancelado']
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (newStatus) {
                if (newStatus != null && newStatus != lot!.status) {
                  ref.read(lotsControllerProvider.notifier).updateLotStatus(lot.id, newStatus);
                }
              },
            ),
          ] else ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(8)),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
                  SizedBox(width: 8),
                  Expanded(child: Text('Lote não mapeado no BD.', style: TextStyle(color: Colors.orange, fontSize: 13))),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

