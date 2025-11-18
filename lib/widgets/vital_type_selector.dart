import 'package:flutter/material.dart';
import 'package:wellness_diary/models/health_vital_model.dart';
import 'package:wellness_diary/utils/app_theme.dart';

class VitalTypeSelector extends StatelessWidget {
  final VitalType selectedType;
  final Function(VitalType) onTypeSelected;

  const VitalTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: VitalType.values.map((type) {
        final isSelected = selectedType == type;

        return InkWell(
          onTap: () => onTypeSelected(type),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.primaryGreen.withOpacity(0.2)
                  : Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppTheme.primaryGreen : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  type.icon,
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 8),
                Text(
                  type.displayName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected ? AppTheme.primaryGreen : AppTheme.textPrimary,
                      ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

