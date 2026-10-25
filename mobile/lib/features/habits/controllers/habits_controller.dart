import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/utils/date_formatter.dart';
import '../models/habit_model.dart';
import '../repositories/habits_repository.dart';
import '../../statistics/controllers/statistics_controller.dart';
import '../../notifications/controllers/notifications_controller.dart';

// Filter providers
final selectedCategoryProvider = StateProvider<String>((ref) => 'All');
final habitSearchQueryProvider = StateProvider<String>((ref) => '');

// Habits State
class HabitsNotifier extends StateNotifier<AsyncValue<List<HabitModel>>> {
  final HabitsRepository repository;
  final Ref ref;

  HabitsNotifier({required this.repository, required this.ref})
      : super(const AsyncValue.loading()) {
    loadHabits();
  }

  Future<void> loadHabits() async {
    state = const AsyncValue.loading();
    try {
      final habits = await repository.fetchHabits(isArchived: false);
      state = AsyncValue.data(habits);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> createHabit(Map<String, dynamic> data) async {
    try {
      final newHabit = await repository.createHabit(data);
      state.whenData((current) {
        state = AsyncValue.data([newHabit, ...current]);
      });
      ref.invalidate(statisticsSummaryProvider);
      ref.invalidate(trendsProvider);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateHabit(String id, Map<String, dynamic> data) async {
    try {
      final updated = await repository.updateHabit(id, data);
      state.whenData((current) {
        state = AsyncValue.data(
          current.map((h) => h.id == id ? updated : h).toList(),
        );
      });
      ref.invalidate(statisticsSummaryProvider);
      ref.invalidate(trendsProvider);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> archiveHabit(String id, bool isArchived) async {
    try {
      await repository.archiveHabit(id, isArchived);
      state.whenData((current) {
        state = AsyncValue.data(current.where((h) => h.id != id).toList());
      });
      ref.invalidate(statisticsSummaryProvider);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteHabit(String id) async {
    try {
      await repository.deleteHabit(id);
      state.whenData((current) {
        state = AsyncValue.data(current.where((h) => h.id != id).toList());
      });
      ref.invalidate(statisticsSummaryProvider);
      ref.invalidate(trendsProvider);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> toggleCompletion(String habitId, {double? completedValue}) async {
    final todayKey = DateFormatter.toDateKey(DateTime.now());

    // Optimistic update
    state.whenData((current) {
      final habitIndex = current.indexWhere((h) => h.id == habitId);
      if (habitIndex == -1) return;
      final habit = current[habitIndex];
      final isCurrentlyDone = habit.isCompletedToday;
      final targetVal = habit.targetValue;
      final newDone = !isCurrentlyDone;
      final newVal = completedValue ?? (newDone ? targetVal : 0.0);

      final updated = habit.copyWith(
        isCompletedToday: newDone,
        todayCompletedValue: newVal,
        currentStreak: newDone
            ? habit.currentStreak + 1
            : (habit.currentStreak > 0 ? habit.currentStreak - 1 : 0),
      );

      final updatedList = List<HabitModel>.from(current);
      updatedList[habitIndex] = updated;
      state = AsyncValue.data(updatedList);

      // Perform background sync
      Future(() async {
        try {
          if (newDone) {
            await repository.completeHabit(
              habitId: habitId,
              dateKey: todayKey,
              completedValue: newVal,
            );
          } else {
            await repository.undoHabitCompletion(
              habitId: habitId,
              dateKey: todayKey,
            );
          }
          ref.invalidate(statisticsSummaryProvider);
          ref.invalidate(trendsProvider);
          ref.invalidate(notificationsProvider);
        } catch (_) {
          // In case of error, reload true state
          loadHabits();
        }
      });
    });
  }

  Future<void> updateMeasurableValue(String habitId, double newValue) async {
    final todayKey = DateFormatter.toDateKey(DateTime.now());

    state.whenData((current) {
      final habitIndex = current.indexWhere((h) => h.id == habitId);
      if (habitIndex == -1) return;
      final habit = current[habitIndex];
      final isDone = newValue >= habit.targetValue;

      final updated = habit.copyWith(
        isCompletedToday: isDone,
        todayCompletedValue: newValue,
      );

      final updatedList = List<HabitModel>.from(current);
      updatedList[habitIndex] = updated;
      state = AsyncValue.data(updatedList);

      Future(() async {
        try {
          await repository.completeHabit(
            habitId: habitId,
            dateKey: todayKey,
            completedValue: newValue,
          );
          ref.invalidate(statisticsSummaryProvider);
          ref.invalidate(trendsProvider);
        } catch (_) {
          loadHabits();
        }
      });
    });
  }
}

final habitsProvider =
    StateNotifierProvider<HabitsNotifier, AsyncValue<List<HabitModel>>>((ref) {
  final repo = ref.watch(habitsRepositoryProvider);
  return HabitsNotifier(repository: repo, ref: ref);
});

// Archived habits provider
final archivedHabitsProvider = FutureProvider<List<HabitModel>>((ref) async {
  final repo = ref.watch(habitsRepositoryProvider);
  return repo.fetchHabits(isArchived: true);
});
