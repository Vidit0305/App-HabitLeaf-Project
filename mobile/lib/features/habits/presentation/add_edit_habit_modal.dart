import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/haptic_feedback_helper.dart';
import '../../../../core/utils/icon_helper.dart';
import '../controllers/habits_controller.dart';
import '../models/habit_model.dart';

class AddEditHabitModal extends ConsumerStatefulWidget {
  final HabitModel? habitToEdit;

  const AddEditHabitModal({super.key, this.habitToEdit});

  @override
  ConsumerState<AddEditHabitModal> createState() => _AddEditHabitModalState();
}

class _AddEditHabitModalState extends ConsumerState<AddEditHabitModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _targetValueController;
  late TextEditingController _targetUnitController;

  late String _selectedCategory;
  late String _selectedIcon;
  late String _selectedColorHex;
  late String _habitType; // 'completion' or 'measurable'
  late String _frequency; // 'every_day' or 'selected_weekdays'
  late List<int> _selectedWeekdays; // 1..7
  late bool _reminderEnabled;
  late TimeOfDay _reminderTime;
  late DateTime _startDate;
  DateTime? _endDate;
  bool _isSaving = false;

  final List<String> _paletteHex = [
    '#10B981', // Emerald
    '#059669', // Deep Emerald
    '#0D9488', // Teal
    '#14B8A6', // Mint Teal
    '#22C55E', // Fresh Green
    '#047857', // Forest Jade
    '#34D399', // Bright Mint
    '#84CC16', // Lime
  ];

  @override
  void initState() {
    super.initState();
    final h = widget.habitToEdit;
    _nameController = TextEditingController(text: h?.name ?? '');
    _descController = TextEditingController(text: h?.description ?? '');
    _targetValueController = TextEditingController(
      text: h != null ? h.targetValue.toString() : '1',
    );
    _targetUnitController = TextEditingController(text: h?.targetUnit ?? 'times');

    _selectedCategory = h?.category ?? 'Health';
    _selectedIcon = h?.icon ?? 'fitness_center';
    _selectedColorHex = h?.color ?? '#10B981';
    _habitType = h?.habitType ?? 'completion';
    _frequency = h?.frequency ?? 'every_day';
    _selectedWeekdays = h != null ? List<int>.from(h.selectedWeekdays) : [1, 2, 3, 4, 5, 6, 7];
    _reminderEnabled = h?.reminderEnabled ?? false;
    _startDate = h?.startDate ?? DateTime.now();
    _endDate = h?.endDate;

    if (h != null && h.reminderTime.contains(':')) {
      final parts = h.reminderTime.split(':');
      _reminderTime = TimeOfDay(
        hour: int.tryParse(parts[0]) ?? 9,
        minute: int.tryParse(parts[1]) ?? 0,
      );
    } else {
      _reminderTime = const TimeOfDay(hour: 9, minute: 0);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _targetValueController.dispose();
    _targetUnitController.dispose();
    super.dispose();
  }

  Future<void> _saveHabit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_frequency == 'selected_weekdays' && _selectedWeekdays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one weekday for this habit.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final timeStr =
        '${_reminderTime.hour.toString().padLeft(2, '0')}:${_reminderTime.minute.toString().padLeft(2, '0')}';
    final targetVal = double.tryParse(_targetValueController.text.trim()) ?? 1.0;

    final habitData = {
      'name': _nameController.text.trim(),
      'description': _descController.text.trim(),
      'category': _selectedCategory,
      'icon': _selectedIcon,
      'color': _selectedColorHex,
      'habitType': _habitType,
      'targetValue': _habitType == 'measurable' ? targetVal : 1.0,
      'targetUnit': _habitType == 'measurable' ? _targetUnitController.text.trim() : 'times',
      'frequency': _frequency,
      'selectedWeekdays': _frequency == 'every_day' ? [1, 2, 3, 4, 5, 6, 7] : _selectedWeekdays,
      'startDate': _startDate.toIso8601String(),
      'endDate': _endDate?.toIso8601String(),
      'reminderEnabled': _reminderEnabled,
      'reminderTime': timeStr,
    };

    bool success;
    if (widget.habitToEdit != null) {
      success = await ref
          .read(habitsProvider.notifier)
          .updateHabit(widget.habitToEdit!.id, habitData);
    } else {
      success = await ref.read(habitsProvider.notifier).createHabit(habitData);
    }

    setState(() => _isSaving = false);

    if (mounted) {
      if (success) {
        HapticFeedbackHelper.medium();
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.habitToEdit != null
                ? 'Habit updated successfully!'
                : 'Habit created successfully!'),
            backgroundColor: AppColors.successGreenDark,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save habit. Please check backend connection.'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEditing = widget.habitToEdit != null;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          // Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isEditing ? 'Edit Habit' : 'Create New Habit',
                style: AppTypography.displayMedium.copyWith(
                  fontSize: 20,
                  color: isDark ? AppColors.textLight : AppColors.textDarkNavy,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 8),

          // Scrollable Form Fields
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Habit Name
                    Text('Habit Name', style: AppTypography.titleMedium),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        hintText: 'e.g., Drink 3L Water, Morning Run',
                        prefixIcon: Icon(Icons.edit_note_rounded),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Habit name is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Description
                    Text('Description (Optional)', style: AppTypography.titleMedium),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descController,
                      decoration: const InputDecoration(
                        hintText: 'e.g., Hydrate throughout the workday',
                        prefixIcon: Icon(Icons.notes_rounded),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 20),

                    // Category Picker
                    Text('Category', style: AppTypography.titleMedium),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: AppConstants.categories.map((cat) {
                        final isSelected = _selectedCategory == cat;
                        return ChoiceChip(
                          label: Text(cat),
                          selected: isSelected,
                          onSelected: (_) => setState(() => _selectedCategory = cat),
                          selectedColor: AppColors.primaryRoyalBlue,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : (isDark ? AppColors.textLight : AppColors.textDarkNavy),
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // Icon Picker
                    Text('Icon', style: AppTypography.titleMedium),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 52,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: IconHelper.availableIcons.keys.map((iconKey) {
                          final isSelected = _selectedIcon == iconKey;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedIcon = iconKey),
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primaryRoyalBlue
                                    : (isDark ? AppColors.surfaceDarkElevated : AppColors.bgLight),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? AppColors.primaryRoyalBlue : AppColors.borderLight,
                                ),
                              ),
                              child: Icon(
                                IconHelper.getIcon(iconKey),
                                color: isSelected ? Colors.white : (isDark ? AppColors.textLight : AppColors.textDarkNavy),
                                size: 24,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Color Palette
                    Text('Accent Color', style: AppTypography.titleMedium),
                    const SizedBox(height: 8),
                    Row(
                      children: _paletteHex.map((hex) {
                        final color = IconHelper.parseColor(hex);
                        final isSelected = _selectedColorHex == hex;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedColorHex = hex),
                          child: Container(
                            margin: const EdgeInsets.only(right: 10),
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? Colors.white : Colors.transparent,
                                width: 2.5,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: color.withOpacity(0.5),
                                        blurRadius: 8,
                                        spreadRadius: 2,
                                      )
                                    ]
                                  : [],
                            ),
                            child: isSelected
                                ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // Habit Type (Completion vs Measurable)
                    Text('Habit Type', style: AppTypography.titleMedium),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTypeCard(
                            title: 'Yes / No',
                            subtitle: 'Simple completion',
                            icon: Icons.check_circle_outline_rounded,
                            isSelected: _habitType == 'completion',
                            onTap: () => setState(() => _habitType = 'completion'),
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTypeCard(
                            title: 'Measurable',
                            subtitle: 'Target with unit',
                            icon: Icons.tune_rounded,
                            isSelected: _habitType == 'measurable',
                            onTap: () => setState(() => _habitType = 'measurable'),
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Measurable Details (if selected)
                    if (_habitType == 'measurable') ...[
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Daily Target', style: AppTypography.bodyMedium),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _targetValueController,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  decoration: const InputDecoration(hintText: 'e.g. 3'),
                                  validator: (v) {
                                    final n = double.tryParse(v ?? '');
                                    if (n == null || n <= 0) return 'Must be > 0';
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Unit', style: AppTypography.bodyMedium),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _targetUnitController,
                                  decoration: const InputDecoration(hintText: 'litres, pages, mins'),
                                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Frequency
                    Text('Frequency', style: AppTypography.titleMedium),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ChoiceChip(
                          label: const Text('Every Day'),
                          selected: _frequency == 'every_day',
                          onSelected: (_) => setState(() => _frequency = 'every_day'),
                        ),
                        const SizedBox(width: 10),
                        ChoiceChip(
                          label: const Text('Selected Days'),
                          selected: _frequency == 'selected_weekdays',
                          onSelected: (_) => setState(() => _frequency = 'selected_weekdays'),
                        ),
                      ],
                    ),
                    if (_frequency == 'selected_weekdays') ...[
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildDayChip('M', 1),
                          _buildDayChip('T', 2),
                          _buildDayChip('W', 3),
                          _buildDayChip('T', 4),
                          _buildDayChip('F', 5),
                          _buildDayChip('S', 6),
                          _buildDayChip('S', 7),
                        ],
                      ),
                    ],
                    const SizedBox(height: 20),

                    // Reminders
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text('Daily Reminder', style: AppTypography.titleMedium),
                      subtitle: Text(
                        _reminderEnabled
                            ? 'Alarm set for ${_reminderTime.format(context)}'
                            : 'Disabled',
                        style: AppTypography.bodySmall,
                      ),
                      value: _reminderEnabled,
                      activeColor: AppColors.primaryRoyalBlue,
                      onChanged: (val) => setState(() => _reminderEnabled = val),
                    ),
                    if (_reminderEnabled) ...[
                      OutlinedButton.icon(
                        onPressed: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: _reminderTime,
                          );
                          if (picked != null) {
                            setState(() => _reminderTime = picked);
                          }
                        },
                        icon: const Icon(Icons.access_time_rounded),
                        label: Text('Change Reminder Time (${_reminderTime.format(context)})'),
                      ),
                      const SizedBox(height: 16),
                    ],

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),

          // Submit Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _saveHabit,
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(isEditing ? 'Save Changes' : 'Create Habit'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryRoyalBlue.withOpacity(isDark ? 0.2 : 0.08)
              : (isDark ? AppColors.surfaceDarkElevated : AppColors.bgLight),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primaryRoyalBlue : AppColors.borderLight,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primaryRoyalBlue : AppColors.textSecondary,
              size: 20,
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textLight : AppColors.textDarkNavy,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(fontSize: 11, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayChip(String label, int dayIndex) {
    final isSelected = _selectedWeekdays.contains(dayIndex);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedWeekdays.remove(dayIndex);
          } else {
            _selectedWeekdays.add(dayIndex);
          }
        });
      },
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryRoyalBlue : Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? AppColors.primaryRoyalBlue : AppColors.borderLight,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
