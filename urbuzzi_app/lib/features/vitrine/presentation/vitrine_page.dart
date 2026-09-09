import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../lots/presentation/lots_provider.dart';
import '../../lots/domain/models/lot.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/network/dio_client.dart';
import '../../home/presentation/map_data.dart';

const double _mapWidth = 1200;
const double _mapHeight = 860;

final visitorMatchedLotsProvider = Provider<Map<LotPolygon, Lot>>((ref) {
  final lotsAsync = ref.watch(publicLotsProvider);
  final lots = lotsAsync.valueOrNull ?? [];
  final map = <LotPolygon, Lot>{};
  for (var poly in MapData.lots) {
    // O MapData usa blocos numéricos ('01','02'...) e a API usa letras ('A','B'...).
    final blockLetter = String.fromCharCode(64 + int.parse(poly.block));
    final numberStr = poly.number;
    final numberStrTrimmed = poly.number.replaceFirst(RegExp(r'^0+'), '');
    for (var l in lots) {
      // Aceita o block como letra (A, B...) ou como o número zerado (01, 02...) como fallback
      final blockMatch = l.block == blockLetter ||
          l.block.toUpperCase() == poly.block;
      final numberMatch = l.number == numberStr || l.number == numberStrTrimmed;
      if (blockMatch && numberMatch) {
        map[poly] = l;
        break;
      }
    }
  }
  return map;
});

class VitrineMapPainter extends CustomPainter {
  final Map<LotPolygon, Lot> matchedLots;
  final LotPolygon? hoveredPolygon;

  VitrineMapPainter({required this.matchedLots, this.hoveredPolygon});

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

      final matchingLot = matchedLots[poly];
      final isAvailable = matchingLot?.status == 'Disponível';
      
      Color baseColor = AppColors.border; // Cinza para os indisponíveis (Vendidos/Reservados/Bloqueados)
      if (isAvailable) {
        baseColor = AppColors.disponivel; // Verde para os disponíveis
      }

      final isHovered = hoveredPolygon == poly;

      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = baseColor.withValues(alpha: isAvailable ? (isHovered ? 0.8 : 0.5) : 0.3);
      canvas.drawPath(path, paint);

      final borderPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = isHovered && isAvailable ? 2.5 : 1.0
        ..color = isHovered && isAvailable ? AppColors.disponivel : Colors.black26;
      canvas.drawPath(path, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant VitrineMapPainter oldDelegate) {
    return oldDelegate.matchedLots != matchedLots || oldDelegate.hoveredPolygon != hoveredPolygon;
  }
}

class VitrinePage extends ConsumerStatefulWidget {
  const VitrinePage({super.key});

  @override
  ConsumerState<VitrinePage> createState() => _VitrinePageState();
}

class _VitrinePageState extends ConsumerState<VitrinePage> {
  final TransformationController _transformationController = TransformationController();
  LotPolygon? _hoveredPolygon;

  void _handleTapDown(TapDownDetails details, Map<LotPolygon, Lot> matchedLots) {
    // details.localPosition já está nas coordenadas do SizedBox(1200×860)
    // porque o GestureDetector envolve o conteúdo DENTRO do InteractiveViewer.
    // Chamar toScene() aqui aplicaria uma dupla transformação e quebraria o hit-test.
    final Offset localPosition = details.localPosition;

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
        final lot = matchedLots[poly];
        if (lot != null && lot.status == 'Disponível') {
          _showLeadModal(lot);
        }
        return;
      }
    }
  }

  void _showLeadModal(Lot lot) {
    showDialog(
      context: context,
      builder: (context) => _LeadCaptureModal(lot: lot),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lotsState = ref.watch(publicLotsProvider);
    final matchedLots = ref.watch(visitorMatchedLotsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text('U', style: TextStyle(color: AppColors.primaryForeground, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 8),
            const Text('Urbizzi', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.of(context).pushReplacementNamed('/login'),
            icon: const Icon(Icons.login, size: 18),
            label: const Text('Área do corretor', style: TextStyle(fontWeight: FontWeight.w600)),
            style: TextButton.styleFrom(foregroundColor: AppColors.textPrimary),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.accent.withValues(alpha: 0.4),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            width: double.infinity,
            child: const Column(
              children: [
                Text(
                  'Escolha o lote ideal para o seu projeto',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  'Navegue pelo mapa interativo abaixo. Lotes em verde estão disponíveis para negociação.',
                  style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Expanded(
            child: lotsState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Erro: $e')),
              data: (lots) {
                return Container(
                  margin: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 4)),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: InteractiveViewer(
                          transformationController: _transformationController,
                          minScale: 0.1,
                          maxScale: 5.0,
                          constrained: false,
                          boundaryMargin: const EdgeInsets.all(double.infinity),
                          child: Center(
                            child: GestureDetector(
                              onTapDown: (d) => _handleTapDown(d, matchedLots),
                            child: SizedBox(
                              width: _mapWidth,
                              height: _mapHeight,
                              child: Stack(
                                children: [
                                  CustomPaint(
                                    size: const Size(_mapWidth, _mapHeight),
                                    painter: VitrineMapPainter(
                                      matchedLots: matchedLots,
                                      hoveredPolygon: _hoveredPolygon,
                                    ),
                                  ),
                                  ...MapData.blockCenters.entries.map((entry) {
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
                                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
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
                      ),
                      Positioned(
                        left: 16,
                        bottom: 16,
                        child: Row(
                          children: [
                            _buildLegendItem(AppColors.disponivel, 'Disponível'),
                            const SizedBox(width: 16),
                            _buildLegendItem(AppColors.border, 'Indisponível (Reservado/Vendido)'),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.5),
              border: Border.all(color: color, width: 2),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _LeadCaptureModal extends StatefulWidget {
  final Lot lot;
  const _LeadCaptureModal({required this.lot});

  @override
  State<_LeadCaptureModal> createState() => _LeadCaptureModalState();
}

class _LeadCaptureModalState extends State<_LeadCaptureModal> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _email = '';
  String _phone = '';
  bool _isLoading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    
    setState(() => _isLoading = true);
    
    try {
      final dio = DioClient().dio;
      
      await dio.post('/clients', data: {
        'name': _name,
        'email': _email,
        'phone': _phone,
        'cpfOrCnpj': 'LEAD-${DateTime.now().millisecondsSinceEpoch}',
      });

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Interesse registrado com sucesso! A equipe entrará em contato.'),
            backgroundColor: AppColors.disponivel,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao registrar interesse. Tente novamente.'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    
    return AlertDialog(
      title: Text('Tenho interesse no Lote ${widget.lot.number}'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Valor à vista: ${currencyFormatter.format(widget.lot.price)}',
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
              const SizedBox(height: 12),
              const Text('Deixe seus dados e nossa equipe comercial entrará em contato para apresentar as condições de financiamento.', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Nome Completo', border: OutlineInputBorder()),
                validator: (val) => val == null || val.isEmpty ? 'Campo obrigatório' : null,
                onSaved: (val) => _name = val!,
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Telefone (WhatsApp)', border: OutlineInputBorder()),
                keyboardType: TextInputType.phone,
                validator: (val) => val == null || val.isEmpty ? 'Campo obrigatório' : null,
                onSaved: (val) => _phone = val!,
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(labelText: 'E-mail', border: OutlineInputBorder()),
                keyboardType: TextInputType.emailAddress,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Campo obrigatório';
                  if (!val.contains('@')) return 'E-mail inválido';
                  return null;
                },
                onSaved: (val) => _email = val!,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading 
            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
            : const Text('Enviar Interesse'),
        ),
      ],
    );
  }
}
