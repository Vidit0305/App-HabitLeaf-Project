import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/app_providers.dart';
import '../models/statistics_model.dart';

// Timeframe selector
final selectedTimeframeProvider = StateProvider<String>((ref) => 'weekly');

// Month selector for calendar heatmap
final currentHeatmapDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

// Summary metrics provider
final statisticsSummaryProvider = FutureProvider<StatisticsSummary>((ref) async {
  final repo = ref.watch(statisticsRepositoryProvider);
  return repo.fetchSummary();
});

// Trends provider
final trendsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repo = ref.watch(statisticsRepositoryProvider);
  final timeframe = ref.watch(selectedTimeframeProvider);
  return repo.fetchTrends(timeframe: timeframe);
});

// Calendar Heatmap provider
final calendarHeatmapProvider = FutureProvider<List<CalendarDayItem>>((ref) async {
  final repo = ref.watch(statisticsRepositoryProvider);
  final date = ref.watch(currentHeatmapDateProvider);
  return repo.fetchCalendarHeatmap(year: date.year, month: date.month);
});
