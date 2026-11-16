import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/local_storage.dart';
import '../../../core/utils/date_formatter.dart';
import '../models/habit_model.dart';

class HabitsRepository {
  final ApiClient apiClient;

  HabitsRepository({required this.apiClient});

  // Load all habits locally from storage
  List<HabitModel> _getLocalHabits() {
    final cached = LocalStorage.getString(AppConstants.keyCachedHabits);
    if (cached == null || cached.trim().isEmpty) return [];
    try {
      final decoded = jsonDecode(cached) as List;
      final todayKey = DateFormatter.toDateKey(DateTime.now());
      final completions = _getLocalCompletions();

      return decoded.map((item) {
        final map = Map<String, dynamic>.from(item as Map);
        final habitId = map['_id']?.toString() ?? map['id']?.toString() ?? '';

        // Check if there is a completion recorded for today
        final todayComp = completions.firstWhere(
          (c) => c['habitId'] == habitId && c['dateKey'] == todayKey,
          orElse: () => {},
        );

        if (todayComp.isNotEmpty) {
          map['isCompletedToday'] = true;
          map['todayCompletedValue'] = (todayComp['completedValue'] as num?)?.toDouble() ?? 1.0;
        }

        return HabitModel.fromJson(map);
      }).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveLocalHabits(List<HabitModel> habits) async {
    final jsonList = habits.map((h) => h.toJson()).toList();
    await LocalStorage.setString(AppConstants.keyCachedHabits, jsonEncode(jsonList));
  }

  List<Map<String, dynamic>> _getLocalCompletions() {
    final cached = LocalStorage.getString(AppConstants.keyCachedCompletions);
    if (cached == null || cached.trim().isEmpty) return [];
    try {
      final decoded = jsonDecode(cached) as List;
      return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveLocalCompletions(List<Map<String, dynamic>> completions) async {
    await LocalStorage.setString(AppConstants.keyCachedCompletions, jsonEncode(completions));
  }

  Future<List<HabitModel>> fetchHabits({
    bool? isArchived,
    String? category,
    String? search,
  }) async {
    // 1. Try fetching from live MongoDB backend first
    try {
      final query = <String, dynamic>{};
      if (isArchived != null) query['isArchived'] = isArchived.toString();
      if (category != null && category != 'All') query['category'] = category;
      if (search != null && search.isNotEmpty) query['search'] = search;

      final res = await apiClient.get(ApiConstants.habits, queryParameters: query);
      if (res != null && res['data'] is List) {
        final serverList = (res['data'] as List)
            .map((item) => HabitModel.fromJson(item as Map<String, dynamic>))
            .toList();
        await _saveLocalHabits(serverList);
        return serverList;
      }
    } catch (_) {
      // Offline fallback: use local cache
    }

    // 2. Fallback to cached habits
    var list = _getLocalHabits();

    if (isArchived != null) {
      list = list.where((h) => h.isArchived == isArchived).toList();
    }
    if (category != null && category != 'All') {
      list = list.where((h) => h.category.toLowerCase() == category.toLowerCase()).toList();
    }
    if (search != null && search.trim().isNotEmpty) {
      final q = search.trim().toLowerCase();
      list = list.where((h) => h.name.toLowerCase().contains(q) || h.description.toLowerCase().contains(q)).toList();
    }

    return list;
  }

  Future<HabitModel?> fetchHabitById(String id) async {
    try {
      final res = await apiClient.get('${ApiConstants.habits}/$id');
      if (res != null && res['data'] != null) {
        final serverHabit = HabitModel.fromJson(res['data'] as Map<String, dynamic>);
        return serverHabit;
      }
    } catch (_) {}

    final list = _getLocalHabits();
    final match = list.where((h) => h.id == id);
    if (match.isNotEmpty) return match.first;

    return null;
  }

  Future<HabitModel> createHabit(Map<String, dynamic> habitData) async {
    // 1. Send to live MongoDB backend
    try {
      final res = await apiClient.post(ApiConstants.habits, data: habitData);
      if (res != null && res['data'] != null) {
        final serverHabit = HabitModel.fromJson(res['data'] as Map<String, dynamic>);
        final list = _getLocalHabits();
        list.removeWhere((h) => h.id == serverHabit.id);
        list.insert(0, serverHabit);
        await _saveLocalHabits(list);
        return serverHabit;
      }
    } catch (_) {}

    // 2. Offline fallback creation
    final newId = 'habit_${const Uuid().v4()}';
    final now = DateTime.now();

    final data = Map<String, dynamic>.from(habitData);
    data['_id'] = newId;
    data['startDate'] = data['startDate'] ?? now.toIso8601String();
    data['isArchived'] = false;
    data['currentStreak'] = 0;
    data['longestStreak'] = 0;
    data['isCompletedToday'] = false;
    data['todayCompletedValue'] = 0.0;

    final newHabit = HabitModel.fromJson(data);

    final list = _getLocalHabits();
    list.insert(0, newHabit);
    await _saveLocalHabits(list);

    return newHabit;
  }

  Future<HabitModel> updateHabit(String id, Map<String, dynamic> habitData) async {
    final list = _getLocalHabits();
    final index = list.indexWhere((h) => h.id == id);

    HabitModel updatedHabit;
    if (index != -1) {
      final current = list[index];
      updatedHabit = current.copyWith(
        name: habitData['name']?.toString() ?? current.name,
        description: habitData['description']?.toString() ?? current.description,
        icon: habitData['icon']?.toString() ?? current.icon,
        color: habitData['color']?.toString() ?? current.color,
        category: habitData['category']?.toString() ?? current.category,
        habitType: habitData['habitType']?.toString() ?? current.habitType,
        targetValue: (habitData['targetValue'] as num?)?.toDouble() ?? current.targetValue,
        targetUnit: habitData['targetUnit']?.toString() ?? current.targetUnit,
        frequency: habitData['frequency']?.toString() ?? current.frequency,
        selectedWeekdays: habitData['selectedWeekdays'] is List
            ? (habitData['selectedWeekdays'] as List).map((e) => (e as num).toInt()).toList()
            : current.selectedWeekdays,
        reminderEnabled: habitData['reminderEnabled'] is bool
            ? habitData['reminderEnabled'] as bool
            : current.reminderEnabled,
        reminderTime: habitData['reminderTime']?.toString() ?? current.reminderTime,
        reminderType: habitData['reminderType']?.toString() ?? current.reminderType,
        reminderIntervalMinutes: (habitData['reminderIntervalMinutes'] as num?)?.toInt() ?? current.reminderIntervalMinutes,
      );
      list[index] = updatedHabit;
      await _saveLocalHabits(list);
    } else {
      updatedHabit = HabitModel.fromJson(habitData);
    }

    // Sync in background and update local copy if backend responds
    Future(() async {
      try {
        final res = await apiClient.patch('${ApiConstants.habits}/$id', data: habitData);
        if (res != null && res['data'] != null) {
          final serverHabit = HabitModel.fromJson(res['data'] as Map<String, dynamic>);
          final currentList = _getLocalHabits();
          final idx = currentList.indexWhere((h) => h.id == id);
          if (idx != -1) {
            currentList[idx] = serverHabit;
            await _saveLocalHabits(currentList);
          }
        }
      } catch (_) {}
    });

    return updatedHabit;
  }

  Future<HabitModel> archiveHabit(String id, bool isArchived) async {
    final list = _getLocalHabits();
    final index = list.indexWhere((h) => h.id == id);

    HabitModel updatedHabit;
    if (index != -1) {
      updatedHabit = list[index].copyWith(isArchived: isArchived);
      list[index] = updatedHabit;
      await _saveLocalHabits(list);
    } else {
      updatedHabit = HabitModel(id: id, name: '', startDate: DateTime.now(), isArchived: isArchived);
    }

    Future(() async {
      try {
        await apiClient.patch(
          '${ApiConstants.habits}/$id/archive',
          data: {'isArchived': isArchived},
        );
      } catch (_) {}
    });

    return updatedHabit;
  }

  Future<void> deleteHabit(String id) async {
    final list = _getLocalHabits();
    list.removeWhere((h) => h.id == id);
    await _saveLocalHabits(list);

    final comps = _getLocalCompletions();
    comps.removeWhere((c) => c['habitId'] == id);
    await _saveLocalCompletions(comps);

    Future(() async {
      try {
        await apiClient.delete('${ApiConstants.habits}/$id');
      } catch (_) {}
    });
  }

  Future<void> completeHabit({
    required String habitId,
    required String dateKey,
    required double completedValue,
    String? notes,
  }) async {
    // 1. Save completion locally
    final comps = _getLocalCompletions();
    comps.removeWhere((c) => c['habitId'] == habitId && c['dateKey'] == dateKey);
    comps.add({
      'habitId': habitId,
      'dateKey': dateKey,
      'status': 'completed',
      'completedValue': completedValue,
      'notes': notes ?? '',
      'completedAt': DateTime.now().toIso8601String(),
    });
    await _saveLocalCompletions(comps);

    // 2. Update habit streak and status
    final list = _getLocalHabits();
    final index = list.indexWhere((h) => h.id == habitId);
    if (index != -1) {
      final h = list[index];
      final newStreak = h.currentStreak + 1;
      final newLongest = newStreak > h.longestStreak ? newStreak : h.longestStreak;
      list[index] = h.copyWith(
        isCompletedToday: true,
        todayCompletedValue: completedValue,
        currentStreak: newStreak,
        longestStreak: newLongest,
      );
      await _saveLocalHabits(list);
    }

    // 3. Background sync
    Future(() async {
      try {
        await apiClient.post(
          ApiConstants.completions,
          data: {
            'habitId': habitId,
            'dateKey': dateKey,
            'status': 'completed',
            'completedValue': completedValue,
            'notes': notes ?? '',
          },
        );
      } catch (_) {}
    });
  }

  Future<void> undoHabitCompletion({
    required String habitId,
    required String dateKey,
  }) async {
    // 1. Remove completion locally
    final comps = _getLocalCompletions();
    comps.removeWhere((c) => c['habitId'] == habitId && c['dateKey'] == dateKey);
    await _saveLocalCompletions(comps);

    // 2. Update habit streak and status
    final list = _getLocalHabits();
    final index = list.indexWhere((h) => h.id == habitId);
    if (index != -1) {
      final h = list[index];
      final newStreak = h.currentStreak > 0 ? h.currentStreak - 1 : 0;
      list[index] = h.copyWith(
        isCompletedToday: false,
        todayCompletedValue: 0.0,
        currentStreak: newStreak,
      );
      await _saveLocalHabits(list);
    }

    // 3. Background sync
    Future(() async {
      try {
        await apiClient.post(
          ApiConstants.completionsUndo,
          data: {
            'habitId': habitId,
            'dateKey': dateKey,
          },
        );
      } catch (_) {}
    });
  }

  Future<Set<String>> getCompletedDatesForHabit(String habitId) async {
    final completions = <String>{};

    // 1. Gather from local storage completions with robust key normalization
    final localComps = _getLocalCompletions();
    for (final c in localComps) {
      if (c['habitId'] == habitId) {
        final status = c['status']?.toString();
        final val = (c['completedValue'] as num?)?.toDouble() ?? 0.0;
        if (status == 'completed' || val >= 1.0) {
          final dk = DateFormatter.normalizeDateKey(
            c['dateKey'] ?? c['completedDate'] ?? c['date'] ?? c['completedAt'],
          );
          if (dk != null && dk.isNotEmpty) {
            completions.add(dk);
          }
        }
      }
    }

    // 2. Include today's completion if habit is marked completed in local state
    final allHabits = _getLocalHabits();
    for (final h in allHabits) {
      if (h.id == habitId && h.isCompletedToday) {
        completions.add(DateFormatter.toDateKey(DateTime.now()));
        break;
      }
    }

    // 3. Fetch from backend API if online
    try {
      final res = await apiClient.get(
        ApiConstants.completions,
        queryParameters: {'habitId': habitId},
      );
      if (res != null && res['data'] is List) {
        for (final item in res['data']) {
          if (item is Map) {
            final status = item['status']?.toString();
            final val = (item['completedValue'] as num?)?.toDouble() ?? 0.0;
            if (status == 'completed' || val >= 1.0) {
              final dk = DateFormatter.normalizeDateKey(
                item['dateKey'] ?? item['completedDate'] ?? item['date'] ?? item['completedAt'],
              );
              if (dk != null && dk.isNotEmpty) {
                completions.add(dk);
              }
            }
          }
        }
      }
    } catch (_) {}

    return completions;
  }
}
