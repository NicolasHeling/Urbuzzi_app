import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import '../../lots/domain/models/lot.dart';
import '../../lots/presentation/lots_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/status_badge.dart';
import '../../reservations/presentation/reservation_dialog.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../audit/presentation/audit_provider.dart';
import 'map_data.dart';
import 'financing_simulator.dart';

class LotDetailsModal extends ConsumerStatefulWidget {
  final Lot lot;
  final LotPolygon poly;

  const LotDetailsModal({super.key, required this.lot, required this.poly});

  @override
  ConsumerState<LotDetailsModal> createState() => _LotDetailsModalState();
}

class _LotDetailsModalState extends ConsumerState<LotDetailsModal> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadDocument() async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        withData: true,
      );

      if (result != null) {
        setState(() => _isUploading = true);
        
        // Chamar repository para enviar multipart pro endpoint /lots/:id/documents criado no backend
        final bytes = result.files.first.bytes;
        final filename = result.files.first.name;
        
        if (bytes != null) {
          await ref.read(lotsControllerProvider.notifier).uploadDocument(widget.lot.id, bytes, filename);
        } else {
          throw Exception('Não foi possível ler os dados do arquivo selecionado.');
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Documento anexado com sucesso!')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao anexar documento: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isAuthenticated = authState.value != null;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 40,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // Modal wraps content
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          
          // Header: Título e Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quadra ${widget.poly.block} - Lote ${widget.poly.number}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                        color: AppColors.textPrimary,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.lot.landName ?? 'Loteamento',
                      style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              StatusBadge(status: widget.lot.status),
            ],
          ),
          const SizedBox(height: 16),

          TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            tabs: const [
              Tab(text: 'Geral'),
              Tab(text: 'Documentos'),
              Tab(text: 'Simulador'),
              Tab(text: 'Histórico'),
            ],
          ),
          const SizedBox(height: 24),

          // Content Wrapper
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _tabController.index == 0
                ? _buildGeneralTab(isAuthenticated)
                : _tabController.index == 1
                    ? _buildDocumentsTab()
                    : _tabController.index == 2
                        ? FinancingSimulator(lotValue: widget.lot.price)
                        : _buildAuditTab(),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralTab(bool isAuthenticated) {
    final currencyFormatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final isAvailable = widget.lot.status == 'Disponível';
    final hasClient = widget.lot.clientName != null && widget.lot.clientName!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isAuthenticated && !isAvailable && hasClient) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.muted.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.person_outline, color: AppColors.textSecondary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Cliente', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                      Text(widget.lot.clientName!, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      if (widget.lot.clientDocument != null)
                        Text('Doc: ${widget.lot.clientDocument}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],

        Text('Especificações', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary)),
        const SizedBox(height: 12),
        Row(
          children: [
            _InfoCard(label: 'Área Total', value: '${NumberFormat.decimalPattern('pt_BR').format(widget.lot.area)} m²'),
            const SizedBox(width: 12),
            _InfoCard(label: 'Valor de Tabela', value: currencyFormatter.format(widget.lot.price)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _InfoCard(label: 'Frente', value: widget.lot.frontMeasure != null ? '${NumberFormat.decimalPattern('pt_BR').format(widget.lot.frontMeasure)} m' : 'N/A'),
            const SizedBox(width: 12),
            _InfoCard(label: 'Fundo', value: widget.lot.backMeasure != null ? '${NumberFormat.decimalPattern('pt_BR').format(widget.lot.backMeasure)} m' : 'N/A'),
          ],
        ),
        if (widget.lot.registration != null) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              _InfoCard(label: 'Matrícula', value: widget.lot.registration!),
            ],
          ),
        ],
        
        const SizedBox(height: 32),

        if (isAuthenticated) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isAvailable ? AppColors.primary : AppColors.surface,
                foregroundColor: isAvailable ? Colors.white : AppColors.primary,
                side: BorderSide(color: isAvailable ? AppColors.primary : AppColors.border),
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              onPressed: () {
                if (isAvailable) {
                  Navigator.pop(context);
                  showReservationDialog(context, widget.lot);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Visualização de contratos em breve.')),
                  );
                }
              },
              child: Text(
                isAvailable ? 'Fazer Reserva' : 'Ver Contrato/Proposta',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ] else ...[
          if (isAvailable)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Fale com o comercial pelo WhatsApp.')),
                  );
                },
                icon: const Icon(Icons.chat, size: 18),
                label: const Text('Falar com o Comercial', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
        ],
      ],
    );
  }

  Widget _buildDocumentsTab() {
    final docs = widget.lot.documents ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Anexos',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
            ),
            if (_isUploading)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              TextButton.icon(
                onPressed: _pickAndUploadDocument,
                icon: const Icon(Icons.upload_file, size: 18),
                label: const Text('Anexar'),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (docs.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border, style: BorderStyle.solid),
            ),
            child: const Column(
              children: [
                Icon(Icons.folder_open, size: 32, color: AppColors.textMuted),
                SizedBox(height: 8),
                Text('Nenhum documento anexado.', style: TextStyle(color: AppColors.textSecondary)),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: docs.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final url = docs[index];
              final uri = Uri.tryParse(url);
              final filename = uri?.pathSegments.last ?? 'Documento ${index + 1}';
              final isPdf = filename.toLowerCase().endsWith('.pdf');
              return Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  leading: Icon(
                    isPdf ? Icons.picture_as_pdf : Icons.image,
                    color: isPdf ? Colors.red.shade400 : Colors.blue.shade400,
                  ),
                  title: Text(filename, maxLines: 1, overflow: TextOverflow.ellipsis),
                  trailing: const Icon(Icons.open_in_new, size: 18, color: AppColors.textSecondary),
                  onTap: () {
                    // Abrir URL do documento
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Abrindo: $filename...')),
                    );
                  },
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildAuditTab() {
    final auditAsync = ref.watch(lotAuditProvider(widget.lot.id));

    return auditAsync.when(
      data: (entries) {
        if (entries.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: Text(
                'Nenhum histórico registrado para este lote.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          );
        }

        final dateFormatter = DateFormat('dd/MM/yyyy HH:mm');

        return Container(
          constraints: const BoxConstraints(maxHeight: 400),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              final isLast = index == entries.length - 1;

              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Linha do tempo visual
                    SizedBox(
                      width: 32,
                      child: Column(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            margin: const EdgeInsets.only(top: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.primary, width: 2),
                            ),
                          ),
                          if (!isLast)
                            Expanded(
                              child: Container(
                                width: 2,
                                color: AppColors.border,
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Conteúdo do log
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _formatActionName(entry.action),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              dateFormatter.format(entry.createdAt),
                              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                            ),
                            if (entry.userId.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.person_outline, size: 14, color: AppColors.textSecondary),
                                  const SizedBox(width: 4),
                                  Text(
                                    entry.userId,
                                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ]
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, st) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Center(child: Text('Erro ao carregar histórico: $e')),
      ),
    );
  }

  String _formatActionName(String action) {
    switch (action) {
      case 'CREATE_LOT': return 'Lote Cadastrado';
      case 'UPDATE_LOT_STATUS': return 'Status Atualizado';
      case 'UPLOAD_DOCUMENT': return 'Documento Anexado';
      case 'LOT_SOLD': return 'Venda Concluída';
      default: return action.replaceAll('_', ' ');
    }
  }
}

class _InfoCard extends StatelessWidget {
  final String label;
  final String value;

  const _InfoCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }
}
