import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/notifications/local_notifications_service.dart';
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
  late String _reminderType; // 'specific_time' or 'interval'
  late int _reminderIntervalMinutes;
  late DateTime _startDate;
  DateTime? _endDate;
  bool _isSaving = false;

  // Vibrant, rich multi-color palette (not just greens!)
  final List<String> _paletteHex = [
    '#10B981', // Emerald Green
    '#059669', // Deep Forest
    '#06B6D4', // Cyan Teal
    '#0EA5E9', // Sky Blue
    '#2563EB', // Royal Blue
    '#6366F1', // Electric Indigo
    '#8B5CF6', // Royal Purple
    '#D946EF', // Magenta Fuchsia
    '#EC4899', // Rose Pink
    '#EF4444', // Crimson Red
    '#F97316', // Sunset Orange
    '#F59E0B', // Amber Gold
    '#84CC16', // Fresh Lime
    '#475569', // Slate Midnight
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
    _selectedIcon = h?.icon ?? 'track_changes';
    _selectedColorHex = h?.color ?? '#10B981';
    _habitType = h?.habitType ?? 'completion';
    _frequency = h?.frequency ?? 'every_day';
    _selectedWeekdays = h != null ? List<int>.from(h.selectedWeekdays) : [1, 2, 3, 4, 5, 6, 7];
    _reminderEnabled = h?.reminderEnabled ?? false;
    _reminderType = h?.reminderType ?? 'specific_time';
    _reminderIntervalMinutes = h?.reminderIntervalMinutes ?? 15;
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
      _selectedWeekdays = [1, 2, 3, 4, 5, 6, 7];
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
      'reminderType': _reminderType,
      'reminderIntervalMinutes': _reminderIntervalMinutes,
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
        if (_reminderEnabled) {
          final reminderMsg = _reminderType == 'specific_time'
              ? 'Reminder scheduled daily at $timeStr'
              : 'Reminder repeats every $_reminderIntervalMinutes minutes';
          LocalNotificationsService.showInstantNotification(
            id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
            title: '⏰ Habit Reminder Active',
            body: '$reminderMsg for "${_nameController.text.trim()}"',
            habitId: widget.habitToEdit?.id,
            habitName: _nameController.text.trim(),
            habitIcon: _selectedIcon,
            habitColor: _selectedColorHex,
            type: 'reminder',
          );
        }
        Navigator.of(context).pop();
      } else {
        HapticFeedbackHelper.heavy();
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
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isEditing ? 'Edit Habit' : 'Create New Habit',
                style: AppTypography.displayMedium.copyWith(
                  color: isDark ? AppColors.textLight : AppColors.textDarkNavy,
                ),
              ),
              IconButton(
                icon: Icon(Icons.close_rounded, color: isDark ? AppColors.textLight : AppColors.textDarkNavy),
                onPressed: () {
                  HapticFeedbackHelper.light();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Scrollable Form
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Habit Name Field
                    Text(
                      'Habit Name',
                      style: AppTypography.titleMedium.copyWith(
                        color: isDark ? AppColors.textLight : AppColors.textDarkNavy,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        hintText: 'e.g., Drink 3L Water, Morning Run',
                        prefixIcon: Icon(Icons.edit_note_rounded),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a habit name';
                        }
                        if (value.trim().length > 80) {
                          return 'Name must be 80 characters or fewer';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Description Field
                    Text(
                      'Description (Optional)',
                      style: AppTypography.titleMedium.copyWith(
                        color: isDark ? AppColors.textLight : AppColors.textDarkNavy,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _descController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        hintText: 'e.g., Stay hydrated throughout the workday',
                        prefixIcon: Icon(Icons.notes_rounded),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Category Picker
                    Text(
                      'Category',
                      style: AppTypography.titleMedium.copyWith(
                        color: isDark ? AppColors.textLight : AppColors.textDarkNavy,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: AppConstants.categories.map((cat) {
                        final isSelected = _selectedCategory == cat;
                        return ChoiceChip(
                          label: Text(cat),
                          selected: isSelected,
                          onSelected: (_) {
                            HapticFeedbackHelper.selection();
                            setState(() => _selectedCategory = cat);
                          },
                          selectedColor: AppColors.primaryEmerald,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : (isDark ? AppColors.textLight : AppColors.textDarkNavy),
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // Icon Picker
                    Text(
                      'Icon & Symbol',
                      style: AppTypography.titleMedium.copyWith(
                        color: isDark ? AppColors.textLight : AppColors.textDarkNavy,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 52,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        children: IconHelper.availableIcons.keys.map((iconKey) {
                          final isSelected = _selectedIcon == iconKey;
                          return GestureDetector(
                            onTap: () {
                              HapticFeedbackHelper.selection();
                              setState(() => _selectedIcon = iconKey);
                            },
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primaryEmerald
                                    : (isDark ? AppColors.surfaceDarkElevated : AppColors.bgLight),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? AppColors.primaryEmerald : (isDark ? AppColors.borderDark : AppColors.borderLight),
                                  width: isSelected ? 1.8 : 1,
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

                    // Color Palette (Multi-Color)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Accent Color',
                          style: AppTypography.titleMedium.copyWith(
                            color: isDark ? AppColors.textLight : AppColors.textDarkNavy,
                          ),
                        ),
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: IconHelper.parseColor(_selectedColorHex),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 12,
                      runSpacing: 10,
                      children: _paletteHex.map((hex) {
                        final color = IconHelper.parseColor(hex);
                        final isSelected = _selectedColorHex == hex;
                        return GestureDetector(
                          onTap: () {
                            HapticFeedbackHelper.selection();
                            setState(() => _selectedColorHex = hex);
                          },
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? Colors.white : Colors.transparent,
                                width: 2.8,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: color.withOpacity(0.6),
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                      )
                                    ]
                                  : [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.12),
                                        blurRadius: 3,
                                      ),
                                    ],
                            ),
                            child: isSelected
                                ? const Icon(Icons.check_rounded, color: Colors.white, size: 20)
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // Habit Type (Completion vs Measurable)
                    Text(
                      'Habit Type',
                      style: AppTypography.titleMedium.copyWith(
                        color: isDark ? AppColors.textLight : AppColors.textDarkNavy,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTypeCard(
                            title: 'Yes / No',
                            subtitle: 'Simple completion',
                            icon: Icons.check_circle_outline_rounded,
                            isSelected: _habitType == 'completion',
                            onTap: () {
                              HapticFeedbackHelper.selection();
                              setState(() => _habitType = 'completion');
                            },
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
                            onTap: () {
                              HapticFeedbackHelper.selection();
                              setState(() => _habitType = 'measurable');
                            },
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
                                Text(
                                  'Daily Target',
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _targetValueController,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  decoration: const InputDecoration(hintText: 'e.g. 2000'),
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
                                Text(
                                  'Unit',
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _targetUnitController,
                                  decoration: const InputDecoration(hintText: 'ml, pages, mins'),
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
                    Text(
                      'Frequency',
                      style: AppTypography.titleMedium.copyWith(
                        color: isDark ? AppColors.textLight : AppColors.textDarkNavy,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ChoiceChip(
                          label: const Text('Every Day'),
                          selected: _frequency == 'every_day',
                          onSelected: (_) {
                            HapticFeedbackHelper.selection();
                            setState(() => _frequency = 'every_day');
                          },
                          selectedColor: AppColors.primaryEmerald,
                          labelStyle: TextStyle(
                            color: _frequency == 'every_day'
                                ? Colors.white
                                : (isDark ? AppColors.textLight : AppColors.textDarkNavy),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 10),
                        ChoiceChip(
                          label: const Text('Selected Days'),
                          selected: _frequency == 'selected_weekdays',
                          onSelected: (_) {
                            HapticFeedbackHelper.selection();
                            setState(() => _frequency = 'selected_weekdays');
                          },
                          selectedColor: AppColors.primaryEmerald,
                          labelStyle: TextStyle(
                            color: _frequency == 'selected_weekdays'
                                ? Colors.white
                                : (isDark ? AppColors.textLight : AppColors.textDarkNavy),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    if (_frequency == 'selected_weekdays') ...[
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildDayChip('M', 1, isDark),
                          _buildDayChip('T', 2, isDark),
                          _buildDayChip('W', 3, isDark),
                          _buildDayChip('T', 4, isDark),
                          _buildDayChip('F', 5, isDark),
                          _buildDayChip('S', 6, isDark),
                          _buildDayChip('S', 7, isDark),
                        ],
                      ),
                    ],
                    const SizedBox(height: 20),

                    // Reminders Section (Supports Specific Time OR Intervals 5, 10, 15, etc.)
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        'Habit Reminder',
                        style: AppTypography.titleMedium.copyWith(
                          color: isDark ? AppColors.textLight : AppColors.textDarkNavy,
                        ),
                      ),
                      subtitle: Text(
                        _reminderEnabled
                            ? (_reminderType == 'specific_time'
                                ? 'Daily notification at ${_reminderTime.format(context)}'
                                : 'Repeats every $_reminderIntervalMinutes minutes')
                            : 'Disabled',
                        style: AppTypography.bodySmall.copyWith(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                        ),
                      ),
                      value: _reminderEnabled,
                      activeColor: AppColors.primaryEmerald,
                      onChanged: (val) {
                        HapticFeedbackHelper.light();
                        setState(() => _reminderEnabled = val);
                      },
                    ),

                    if (_reminderEnabled) ...[
                      const SizedBox(height: 8),
                      // Choice: Specific Time vs Repeating Interval
                      Row(
                        children: [
                          ChoiceChip(
                            label: const Text('Specific Time'),
                            selected: _reminderType == 'specific_time',
                            onSelected: (_) {
                              HapticFeedbackHelper.selection();
                              setState(() => _reminderType = 'specific_time');
                            },
                            selectedColor: AppColors.primaryEmerald,
                            labelStyle: TextStyle(
                              color: _reminderType == 'specific_time'
                                  ? Colors.white
                                  : (isDark ? AppColors.textLight : AppColors.textDarkNavy),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 10),
                          ChoiceChip(
                            label: const Text('Repeating Interval'),
                            selected: _reminderType == 'interval',
                            onSelected: (_) {
                              HapticFeedbackHelper.selection();
                              setState(() => _reminderType = 'interval');
                            },
                            selectedColor: AppColors.primaryEmerald,
                            labelStyle: TextStyle(
                              color: _reminderType == 'interval'
                                  ? Colors.white
                                  : (isDark ? AppColors.textLight : AppColors.textDarkNavy),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      if (_reminderType == 'specific_time') ...[
                        OutlinedButton.icon(
                          onPressed: () async {
                            HapticFeedbackHelper.light();
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: _reminderTime,
                            );
                            if (picked != null) {
                              setState(() => _reminderTime = picked);
                            }
                          },
                          icon: const Icon(Icons.access_time_rounded, color: AppColors.primaryEmerald),
                          label: Text('Set Time: ${_reminderTime.format(context)}'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: isDark ? AppColors.primaryGreenLight : AppColors.primaryEmerald,
                          ),
                        ),
                      ] else ...[
                        Text(
                          'Repeat Notification Interval:',
                          style: AppTypography.bodySmall.copyWith(
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [5, 10, 15, 30, 60, 120].map((mins) {
                            final isSel = _reminderIntervalMinutes == mins;
                            final label = mins >= 60 ? '${mins ~/ 60} hr' : '$mins mins';
                            return ChoiceChip(
                              label: Text(label),
                              selected: isSel,
                              selectedColor: AppColors.primaryEmerald,
                              labelStyle: TextStyle(
                                color: isSel
                                    ? Colors.white
                                    : (isDark ? AppColors.textLight : AppColors.textDarkNavy),
                                fontWeight: FontWeight.w600,
                              ),
                              onSelected: (_) {
                                HapticFeedbackHelper.selection();
                                setState(() => _reminderIntervalMinutes = mins);
                              },
                            );
                          }).toList(),
                        ),
                      ],
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
            height: 52,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _saveHabit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryEmerald,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                      isEditing ? 'Save Changes' : 'Create Habit',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
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
              ? AppColors.primaryEmerald.withOpacity(isDark ? 0.2 : 0.08)
              : (isDark ? AppColors.surfaceDarkElevated : AppColors.bgLight),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primaryEmerald : (isDark ? AppColors.borderDark : AppColors.borderLight),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primaryEmerald : AppColors.textSecondary,
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

  Widget _buildDayChip(String label, int dayIndex, bool isDark) {
    final isSelected = _selectedWeekdays.contains(dayIndex);
    return GestureDetector(
      onTap: () {
        HapticFeedbackHelper.selection();
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
          color: isSelected ? AppColors.primaryEmerald : Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? AppColors.primaryEmerald : (isDark ? AppColors.borderDark : AppColors.borderLight),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : (isDark ? AppColors.textLight : AppColors.textSecondary),
          ),
        ),
      ),
    );
  }
}
