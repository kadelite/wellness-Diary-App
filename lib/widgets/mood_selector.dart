import 'package:flutter/material.dart';
import 'package:wellness_diary/utils/app_theme.dart';

class MoodSelector extends StatelessWidget {
  final List<String> moods;
  final Function(String) onMoodSelected;
  final String? selectedMood;

  const MoodSelector({
    super.key,
    required this.moods,
    required this.onMoodSelected,
    this.selectedMood,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: moods.map((mood) {
        final isSelected = selectedMood == mood;
        final color = MoodColors.getColor(mood);

        return InkWell(
          onTap: () => onMoodSelected(mood),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: isSelected
                  ? color.withOpacity(0.2)
                  : Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? color : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _getMoodEmoji(mood),
                  style: const TextStyle(fontSize: 36),
                ),
                const SizedBox(height: 8),
                Text(
                  mood,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected ? color : AppTheme.textPrimary,
                      ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
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
}

