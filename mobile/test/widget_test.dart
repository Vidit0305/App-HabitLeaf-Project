import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:habit_tracker/core/storage/local_storage.dart';
import 'package:habit_tracker/core/utils/date_formatter.dart';
import 'package:habit_tracker/features/habits/models/habit_model.dart';
import 'package:habit_tracker/features/habits/controllers/habits_controller.dart';
import 'package:habit_tracker/features/main_navigation_screen.dart';
import 'package:habit_tracker/features/statistics/models/statistics_model.dart';
import 'package:habit_tracker/features/statistics/controllers/statistics_controller.dart';
import 'package:habit_tracker/features/settings/models/settings_model.dart';
import 'package:habit_tracker/features/settings/controllers/settings_controller.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'installation_id': 'test_installation_uuid_1234',
    });
    await LocalStorage.init();
  });

  testWidgets('App renders Home screen with 5 navigation destinations', (WidgetTester tester) async {
    // Provide test data overrides so the test doesn't depend on live network
    final sampleHabit = HabitModel(
      id: 'test_habit_1',
      name: 'Drink 3L Water',
      category: 'Health',
      habitType: 'measurable',
      targetValue: 3.0,
      targetUnit: 'litres',
      frequency: 'every_day',
      startDate: DateTime.now(),
      currentStreak: 5,
      longestStreak: 12,
      isCompletedToday: false,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          habitsProvider.overrideWith((ref) => HabitsNotifierMock([sampleHabit])),
          statisticsSummaryProvider.overrideWith(
            (ref) => Future.value(
              StatisticsSummary(
                completedToday: 0,
                pendingToday: 1,
                totalScheduledToday: 1,
                completionPercentage: 0,
                currentOverallStreak: 5,
                longestOverallStreak: 12,
                totalCompletions: 34,
                overallCompletionRate: 85,
              ),
            ),
          ),
          settingsProvider.overrideWith(
            (ref) => SettingsNotifierMock(
              SettingsModel(displayName: 'Alex', themeMode: 'system'),
            ),
          ),
        ],
        child: const MaterialApp(
          home: MainNavigationScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify 5 bottom navigation items are present
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('My Habits'), findsOneWidget);
    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('Statistics'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);

    // Verify Home header and progress card
    expect(find.textContaining('Alex'), findsOneWidget);
    expect(find.text('Today\'s Progress'), findsOneWidget);
    expect(find.text('Drink 3L Water'), findsOneWidget);

    // Tap on 'My Habits' tab and verify navigation
    await tester.tap(find.text('My Habits'));
    await tester.pumpAndSettle();
    expect(find.text('Active'), findsOneWidget);
    expect(find.text('Archived'), findsOneWidget);

    // Tap on 'Statistics' tab
    await tester.tap(find.text('Statistics'));
    await tester.pumpAndSettle();
    expect(find.text('Progress & Analytics'), findsOneWidget);

    // Tap on 'Settings' tab
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Personal Profile'), findsOneWidget);
    expect(find.text('Appearance'), findsOneWidget);
  });

  test('DateFormatter formatting and greeting logic test', () {
    final now = DateTime(2026, 10, 24);
    final dateKey = DateFormatter.toDateKey(now);
    expect(dateKey, '2026-10-24');

    final parsed = DateFormatter.fromDateKey(dateKey);
    expect(parsed.year, 2026);
    expect(parsed.month, 10);
    expect(parsed.day, 24);

    expect(DateFormatter.weekdayName(1), 'Mon');
    expect(DateFormatter.weekdayName(7), 'Sun');
  });

  test('HabitModel serialization and completion logic test', () {
    final habit = HabitModel(
      id: 'h1',
      name: 'Read Book',
      targetValue: 10,
      targetUnit: 'pages',
      habitType: 'measurable',
      startDate: DateTime(2026, 10, 1),
    );

    final json = habit.toJson();
    final reconstructed = HabitModel.fromJson(json);

    expect(reconstructed.id, 'h1');
    expect(reconstructed.name, 'Read Book');
    expect(reconstructed.targetValue, 10.0);
    expect(reconstructed.isMeasurable, true);
  });
}

// Mocks for widget test isolation
class HabitsNotifierMock extends StateNotifier<AsyncValue<List<HabitModel>>>
    implements HabitsNotifier {
  HabitsNotifierMock(List<HabitModel> initial)
      : super(AsyncValue.data(initial));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class SettingsNotifierMock extends StateNotifier<AsyncValue<SettingsModel>>
    implements SettingsNotifier {
  SettingsNotifierMock(SettingsModel initial)
      : super(AsyncValue.data(initial));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
