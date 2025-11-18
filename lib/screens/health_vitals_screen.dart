import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wellness_diary/providers/health_vital_provider.dart';
import 'package:wellness_diary/models/health_vital_model.dart';
import 'package:wellness_diary/utils/app_theme.dart';
import 'package:wellness_diary/widgets/vital_type_selector.dart';
import 'package:wellness_diary/widgets/vitals_chart.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class HealthVitalsScreen extends StatefulWidget {
  const HealthVitalsScreen({super.key});

  @override
  State<HealthVitalsScreen> createState() => _HealthVitalsScreenState();
}

class _HealthVitalsScreenState extends State<HealthVitalsScreen> {
  VitalType _selectedType = VitalType.heartRate;
  final TextEditingController _valueController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _valueController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Vitals'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildVitalTypeSelector(),
            const SizedBox(height: 24),
            _buildStatsCard(),
            const SizedBox(height: 24),
            _buildChart(),
            const SizedBox(height: 24),
            _buildRecentVitals(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddVitalDialog,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Log Vital'),
      ),
    );
  }

  Widget _buildVitalTypeSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Vital Type',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            VitalTypeSelector(
              selectedType: _selectedType,
              onTypeSelected: (type) {
                setState(() => _selectedType = type);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    return Consumer<HealthVitalProvider>(
      builder: (context, provider, _) {
        final recentVitals = provider.getRecentVitals(_selectedType, days: 7);
        final average = provider.getAverageValue(_selectedType, days: 7);
        final min = provider.getMinValue(_selectedType, days: 7);
        final max = provider.getMaxValue(_selectedType, days: 7);
        final latest = provider.getLatestVital(_selectedType);

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _selectedType.icon,
                      style: const TextStyle(fontSize: 32),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedType.displayName,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          if (latest != null)
                            Text(
                              'Latest: ${latest.value} ${latest.unit ?? _selectedType.defaultUnit}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        'Average',
                        average != null ? '${average.toStringAsFixed(1)}' : 'N/A',
                        AppTheme.primaryBlue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatItem(
                        'Min',
                        min != null ? '${min.toStringAsFixed(1)}' : 'N/A',
                        AppTheme.primaryGreen,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatItem(
                        'Max',
                        max != null ? '${max.toStringAsFixed(1)}' : 'N/A',
                        AppTheme.accentPurple,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart() {
    return Consumer<HealthVitalProvider>(
      builder: (context, provider, _) {
        final recentVitals = provider.getRecentVitals(_selectedType, days: 7);
        
        if (recentVitals.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text(
                  'No data available for the last 7 days',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
              ),
            ),
          );
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '7-Day Trend',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: VitalsChart(
                    vitals: recentVitals,
                    type: _selectedType,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecentVitals() {
    return Consumer<HealthVitalProvider>(
      builder: (context, provider, _) {
        final vitals = provider.getVitalsByType(_selectedType).take(10).toList();

        if (vitals.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text(
                  'No vitals logged yet',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Logs',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ...vitals.map((vital) => _buildVitalCard(context, vital, provider)),
          ],
        );
      },
    );
  }

  Widget _buildVitalCard(
      BuildContext context, HealthVitalModel vital, HealthVitalProvider provider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppTheme.primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              vital.type.icon,
              style: const TextStyle(fontSize: 24),
            ),
          ),
        ),
        title: Text(
          '${vital.value} ${vital.unit ?? vital.type.defaultUnit}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryGreen,
              ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('MMM d, yyyy • HH:mm').format(vital.dateTime),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (vital.note != null && vital.note!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(vital.note!),
              ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline_rounded),
          onPressed: () async {
            final authProvider = context.read<AuthProvider>();
            await provider.deleteVital(
              vital.id,
              userId: authProvider.currentUser?.id,
            );
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Vital deleted')),
              );
            }
          },
        ),
      ),
    );
  }

  void _showAddVitalDialog() {
    _valueController.clear();
    _noteController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Log ${_selectedType.displayName}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _valueController,
                decoration: InputDecoration(
                  labelText: 'Value',
                  hintText: 'Enter ${_selectedType.displayName.toLowerCase()}',
                  suffixText: _selectedType.defaultUnit,
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: 'Note (Optional)',
                  hintText: 'Add a note...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final value = double.tryParse(_valueController.text);
              if (value == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a valid number')),
                );
                return;
              }

              final provider = context.read<HealthVitalProvider>();
              final authProvider = context.read<AuthProvider>();
              await provider.addVital(
                type: _selectedType,
                value: value,
                dateTime: DateTime.now(),
                note: _noteController.text.isEmpty ? null : _noteController.text,
                userId: authProvider.currentUser?.id,
              );

              _valueController.clear();
              _noteController.clear();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Vital logged successfully!')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

