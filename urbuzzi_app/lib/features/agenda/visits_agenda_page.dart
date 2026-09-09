import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'visits_provider.dart';
import '../../../core/theme/app_colors.dart';

class VisitsAgendaPage extends ConsumerStatefulWidget {
  const VisitsAgendaPage({super.key});

  @override
  ConsumerState<VisitsAgendaPage> createState() => _VisitsAgendaPageState();
}

class _VisitsAgendaPageState extends ConsumerState<VisitsAgendaPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  void _showCreateVisitDialog(BuildContext context) {
    final customerNameController = TextEditingController();
    final responsibleUserNameController = TextEditingController();
    final lotIdController = TextEditingController();
    DateTime selectedDialogDate = _selectedDay ?? DateTime.now();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Nova Visita'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: customerNameController,
                      decoration: const InputDecoration(labelText: 'Nome do Cliente'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: responsibleUserNameController,
                      decoration: const InputDecoration(labelText: 'Nome do Responsável'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: lotIdController,
                      decoration: const InputDecoration(labelText: 'ID do Lote'),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text('Data: ${DateFormat('dd/MM/yyyy').format(selectedDialogDate)}'),
                        const Spacer(),
                        TextButton(
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: selectedDialogDate,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (date != null) {
                              setStateDialog(() {
                                selectedDialogDate = date;
                              });
                            }
                          },
                          child: const Text('Alterar'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () async {
                    if (customerNameController.text.isEmpty) return;
                    try {
                      await ref.read(visitsProvider.notifier).createVisit(
                        customerName: customerNameController.text,
                        date: selectedDialogDate.toIso8601String(),
                        responsibleUserName: responsibleUserNameController.text,
                        lotId: lotIdController.text,
                      );
                      if (context.mounted) Navigator.pop(context);
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Erro: $e')),
                        );
                      }
                    }
                  },
                  child: const Text('Salvar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final visitsAsync = ref.watch(visitsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateVisitDialog(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: visitsAsync.when(
        data: (visits) {
          final visitsForSelectedDay = visits.where((v) {
            if (_selectedDay == null) return false;
            try {
              final visitDate = DateTime.parse(v.date);
              return isSameDay(visitDate, _selectedDay);
            } catch (_) {
              return false;
            }
          }).toList();

          return Column(
            children: [
              Container(
                color: AppColors.surface,
                child: TableCalendar(
                  firstDay: DateTime.utc(2020, 10, 16),
                  lastDay: DateTime.utc(2030, 3, 14),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDay, day);
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  eventLoader: (day) {
                    return visits.where((v) {
                      try {
                        return isSameDay(DateTime.parse(v.date), day);
                      } catch (_) {
                        return false;
                      }
                    }).toList();
                  },
                  calendarStyle: const CalendarStyle(
                    selectedDecoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    todayDecoration: BoxDecoration(
                      color: Colors.black26,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: visitsForSelectedDay.isEmpty
                    ? const Center(child: Text('Nenhuma visita neste dia.'))
                    : ListView.builder(
                        itemCount: visitsForSelectedDay.length,
                        itemBuilder: (context, index) {
                          final visit = visitsForSelectedDay[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: ListTile(
                              title: Text(visit.customerName, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('Corretor: ${visit.responsibleUserName}\nLote: ${visit.lotId}'),
                              isThreeLine: true,
                              leading: const CircleAvatar(
                                backgroundColor: AppColors.primary,
                                child: Icon(Icons.person, color: Colors.white),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Erro: $e')),
      ),
    );
  }
}
