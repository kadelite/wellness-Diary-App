import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:wellness_diary/providers/auth_provider.dart';
import 'package:wellness_diary/providers/mood_provider.dart';
import 'package:wellness_diary/models/mood_model.dart';
import 'package:wellness_diary/utils/app_theme.dart';
import 'package:wellness_diary/widgets/mood_selector.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class MoodTrackingScreen extends StatefulWidget {
  const MoodTrackingScreen({super.key});

  @override
  State<MoodTrackingScreen> createState() => _MoodTrackingScreenState();
}

class _MoodTrackingScreenState extends State<MoodTrackingScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  final TextEditingController _noteController = TextEditingController();

  final List<String> _availableMoods = [
    'Excellent',
    'Good',
    'Okay',
    'Bad',
    'Terrible',
  ];

  String? _selectedMood;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood Tracking'),
      ),
      body: Column(
        children: [
          _buildCalendar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMoodSelector(),
                  const SizedBox(height: 24),
                  _buildMoodHistory(),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddMoodDialog,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Log Mood'),
      ),
    );
  }

  Widget _buildCalendar() {
    return Consumer<MoodProvider>(
      builder: (context, moodProvider, _) {
        final moods = moodProvider.moods;
        final moodDates = {
          for (var mood in moods)
            DateTime(
              mood.dateTime.year,
              mood.dateTime.month,
              mood.dateTime.day,
            ): mood.mood,
        };

        return Card(
          margin: const EdgeInsets.all(16),
          child: TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            calendarFormat: _calendarFormat,
            eventLoader: (day) {
              final dayKey = DateTime(day.year, day.month, day.day);
              return moodDates.containsKey(dayKey) ? [moodDates[dayKey]!] : [];
            },
            startingDayOfWeek: StartingDayOfWeek.monday,
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              weekendTextStyle: TextStyle(color: AppTheme.textSecondary),
              defaultTextStyle: const TextStyle(fontWeight: FontWeight.w500),
              selectedDecoration: BoxDecoration(
                color: AppTheme.primaryBlue,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: AppTheme.primaryBlue.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                color: AppTheme.primaryGreen,
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: true,
              formatButtonShowsNext: false,
              formatButtonDecoration: BoxDecoration(
                color: AppTheme.primaryBlue,
                borderRadius: BorderRadius.circular(12),
              ),
              formatButtonTextStyle: const TextStyle(color: Colors.white),
            ),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              setState(() => _calendarFormat = format);
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                if (events.isEmpty) return null;
                final mood = events.first as String;
                return Positioned(
                  bottom: 1,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: MoodColors.getColor(mood),
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildMoodSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How are you feeling today?',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            MoodSelector(
              moods: _availableMoods,
              onMoodSelected: (mood) {
                setState(() => _selectedMood = mood);
              },
              selectedMood: _selectedMood,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodHistory() {
    return Consumer<MoodProvider>(
      builder: (context, moodProvider, _) {
        final dayMoods = moodProvider.getMoodsByDate(_selectedDay);
        dayMoods.sort((a, b) => b.dateTime.compareTo(a.dateTime));

        if (dayMoods.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text(
                  'No moods logged for this day',
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
              'Mood History',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ...dayMoods.map((mood) => _buildMoodCard(context, mood, moodProvider)),
          ],
        );
      },
    );
  }

  Widget _buildMoodCard(BuildContext context, MoodModel mood, MoodProvider provider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: MoodColors.getColor(mood.mood).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              _getMoodEmoji(mood.mood),
              style: const TextStyle(fontSize: 24),
            ),
          ),
        ),
        title: Text(
          mood.mood,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: MoodColors.getColor(mood.mood),
              ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (mood.note != null && mood.note!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(mood.note!),
              ),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                DateFormat('HH:mm').format(mood.dateTime),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline_rounded),
          onPressed: () async {
            final authProvider = context.read<AuthProvider>();
            await provider.deleteMood(
              mood.id,
              userId: authProvider.currentUser?.id,
            );
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Mood deleted')),
              );
            }
          },
        ),
      ),
    );
  }

  String _getMoodEmoji(String mood) {
    switch (mood) {
      case 'Excellent':
        return '😄';
      case 'Good':
        return '😊';
      case 'Okay':
        return '😐';
      case 'Bad':
        return '😔';
      case 'Terrible':
        return '😢';
      default:
        return '😊';
    }
  }

  void _showAddMoodDialog() {
    if (_selectedMood == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a mood first')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Note (Optional)'),
        content: TextField(
          controller: _noteController,
          decoration: const InputDecoration(
            hintText: 'Add a note about your mood...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final provider = context.read<MoodProvider>();
              final authProvider = context.read<AuthProvider>();
              await provider.addMood(
                mood: _selectedMood!,
                dateTime: _selectedDay,
                note: _noteController.text.isEmpty ? null : _noteController.text,
                userId: authProvider.currentUser?.id,
              );
              _noteController.clear();
              _selectedMood = null;
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Mood logged successfully!')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

