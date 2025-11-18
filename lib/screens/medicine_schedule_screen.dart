import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wellness_diary/providers/medicine_provider.dart';
import 'package:wellness_diary/models/medicine_model.dart';
import 'package:wellness_diary/utils/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

class MedicineScheduleScreen extends StatefulWidget {
  const MedicineScheduleScreen({super.key});

  @override
  State<MedicineScheduleScreen> createState() => _MedicineScheduleScreenState();
}

class _MedicineScheduleScreenState extends State<MedicineScheduleScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medicine Schedule'),
      ),
      body: Consumer<MedicineProvider>(
        builder: (context, provider, _) {
          final medicines = provider.activeMedicines;
          final todayMedicines = provider.getTodayMedicines();
          final upcomingMedicines = provider.getUpcomingMedicines();

          if (medicines.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.medication_rounded,
                    size: 64,
                    color: AppTheme.neutralGray.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No medicines scheduled',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the + button to add a medicine',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (upcomingMedicines.isNotEmpty) ...[
                  _buildSectionTitle('Upcoming Today'),
                  const SizedBox(height: 12),
                  ...upcomingMedicines.map((medicine) => _buildMedicineCard(
                        context,
                        medicine,
                        provider,
                        isUpcoming: true,
                      )),
                  const SizedBox(height: 24),
                ],
                _buildSectionTitle('All Medicines'),
                const SizedBox(height: 12),
                ...medicines.map((medicine) => _buildMedicineCard(
                      context,
                      medicine,
                      provider,
                    )),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddMedicineDialog(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Medicine'),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildMedicineCard(
    BuildContext context,
    MedicineModel medicine,
    MedicineProvider provider, {
    bool isUpcoming = false,
  }) {
    final color = _getMedicineColor(medicine.color);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              medicine.name[0].toUpperCase(),
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
        ),
        title: Text(
          medicine.name,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${medicine.dosage}'),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              children: medicine.times.map((time) {
                return Chip(
                  label: Text(
                    time.formattedTime,
                    style: const TextStyle(fontSize: 12),
                  ),
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                );
              }).toList(),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isUpcoming)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Upcoming',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.primaryGreen,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            IconButton(
              icon: Icon(
                medicine.isActive
                    ? Icons.toggle_on_rounded
                    : Icons.toggle_off_rounded,
                color: medicine.isActive ? AppTheme.primaryGreen : AppTheme.neutralGray,
              ),
              onPressed: () {
                final authProvider = context.read<AuthProvider>();
                provider.toggleMedicineActive(
                  medicine.id,
                  userId: authProvider.currentUser?.id,
                );
              },
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Days', _formatDaysOfWeek(medicine.daysOfWeek)),
                if (medicine.startDate != null)
                  _buildInfoRow(
                    'Start Date',
                    DateFormat('MMM d, yyyy').format(medicine.startDate),
                  ),
                if (medicine.endDate != null)
                  _buildInfoRow(
                    'End Date',
                    DateFormat('MMM d, yyyy').format(medicine.endDate!),
                  ),
                if (medicine.note != null && medicine.note!.isNotEmpty)
                  _buildInfoRow('Note', medicine.note!),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showEditMedicineDialog(context, medicine),
                        icon: const Icon(Icons.edit_rounded),
                        label: const Text('Edit'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _confirmDeleteMedicine(context, medicine, provider),
                        icon: const Icon(Icons.delete_outline_rounded),
                        label: const Text('Delete'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDaysOfWeek(List<int> days) {
    const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    if (days.length == 7) return 'Every day';
    if (days.length == 5 && !days.contains(6) && !days.contains(7)) {
      return 'Weekdays';
    }
    return days.map((d) => dayNames[d - 1]).join(', ');
  }

  Color _getMedicineColor(String? colorHex) {
    if (colorHex == null) return AppTheme.accentPurple;
    try {
      return Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
    } catch (e) {
      return AppTheme.accentPurple;
    }
  }

  void _confirmDeleteMedicine(
      BuildContext context, MedicineModel medicine, MedicineProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Medicine'),
        content: Text('Are you sure you want to delete ${medicine.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              await provider.deleteMedicine(medicine.id, userId: authProvider.currentUser?.id);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${medicine.name} deleted')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAddMedicineDialog(BuildContext context) {
    _showMedicineDialog(context);
  }

  void _showEditMedicineDialog(BuildContext context, MedicineModel medicine) {
    _showMedicineDialog(context, medicine: medicine);
  }

  void _showMedicineDialog(BuildContext context, {MedicineModel? medicine}) {
    final nameController = TextEditingController(text: medicine?.name ?? '');
    final dosageController = TextEditingController(text: medicine?.dosage ?? '');
    final noteController = TextEditingController(text: medicine?.note ?? '');
    final times = <TimeOfDayModel>[...?medicine?.times];
    final daysOfWeek = <int>[...?medicine?.daysOfWeek ?? [1, 2, 3, 4, 5, 6, 7]];
    final startDate = medicine?.startDate ?? DateTime.now();
    DateTime? endDate = medicine?.endDate;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(medicine == null ? 'Add Medicine' : 'Edit Medicine'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Medicine Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: dosageController,
                    decoration: const InputDecoration(
                      labelText: 'Dosage (e.g., 1 tablet, 5ml)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Times per day:'),
                  const SizedBox(height: 8),
                  ...times.asMap().entries.map((entry) {
                    final index = entry.key;
                    final time = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () async {
                                final picked = await _selectTime(context, time);
                                if (picked != null) {
                                  setState(() {
                                    times[index] = picked;
                                  });
                                }
                              },
                              child: Text(time.formattedTime),
                            ),
                          ),
                          if (times.length > 1)
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded),
                              onPressed: () {
                                setState(() => times.removeAt(index));
                              },
                            ),
                        ],
                      ),
                    );
                  }),
                  TextButton.icon(
                    onPressed: () {
                      setState(() => times.add(TimeOfDayModel(hour: 12, minute: 0)));
                    },
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Add Time'),
                  ),
                  const SizedBox(height: 16),
                  const Text('Days of week:'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (int i = 1; i <= 7; i++)
                        FilterChip(
                          label: Text(_getDayName(i)),
                          selected: daysOfWeek.contains(i),
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                daysOfWeek.add(i);
                              } else {
                                daysOfWeek.remove(i);
                              }
                            });
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: noteController,
                    decoration: const InputDecoration(
                      labelText: 'Note (Optional)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isEmpty || dosageController.text.isEmpty || times.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all required fields')),
                  );
                  return;
                }

                final provider = context.read<MedicineProvider>();
                final authProvider = context.read<AuthProvider>();
                final userId = authProvider.currentUser?.id;
                
                if (medicine == null) {
                  await provider.addMedicine(
                    name: nameController.text,
                    dosage: dosageController.text,
                    times: times,
                    startDate: startDate,
                    endDate: endDate,
                    daysOfWeek: daysOfWeek,
                    note: noteController.text.isEmpty ? null : noteController.text,
                    userId: userId,
                  );
                } else {
                  final updated = MedicineModel(
                    id: medicine.id,
                    name: nameController.text,
                    dosage: dosageController.text,
                    times: times,
                    startDate: startDate,
                    endDate: endDate,
                    daysOfWeek: daysOfWeek,
                    note: noteController.text.isEmpty ? null : noteController.text,
                    isActive: medicine.isActive,
                    color: medicine.color,
                  );
                  await provider.updateMedicine(updated, userId: userId);
                }

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(medicine == null
                        ? 'Medicine added successfully!'
                        : 'Medicine updated successfully!'),
                  ),
                );
              },
              child: Text(medicine == null ? 'Add' : 'Update'),
            ),
          ],
        ),
      ),
    );
  }

  Future<TimeOfDayModel?> _selectTime(BuildContext context, TimeOfDayModel initial) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: initial.hour, minute: initial.minute),
    );

    if (time != null) {
      return TimeOfDayModel(hour: time.hour, minute: time.minute);
    }
    return null;
  }

  String _getDayName(int day) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[day - 1];
  }
}

