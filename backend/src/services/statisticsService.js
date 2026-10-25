const Habit = require('../models/Habit');
const HabitCompletion = require('../models/HabitCompletion');
const { calculateOverallStreak, calculateHabitStreak } = require('../utils/streakCalculator');
const { formatDateKey, parseDateKey, addDays, isHabitScheduledOnDate } = require('../utils/dateHelper');

async function getSummary(installationId, todayKey = formatDateKey(new Date())) {
  const habits = await Habit.find({ installationId, isArchived: false });
  const completions = await HabitCompletion.find({ installationId });

  // Today's scheduled habits
  const scheduledToday = habits.filter((h) => isHabitScheduledOnDate(h, todayKey));
  const todayCompletions = completions.filter((c) => c.dateKey === todayKey);

  const completedMap = new Map();
  for (const c of todayCompletions) {
    if (c.status === 'completed' || c.completedValue >= (c.targetValueSnapshot || 1)) {
      completedMap.set(c.habitId.toString(), c);
    }
  }

  const completedTodayCount = scheduledToday.filter((h) => completedMap.has(h._id.toString())).length;
  const totalScheduledToday = scheduledToday.length;
  const pendingTodayCount = Math.max(0, totalScheduledToday - completedTodayCount);
  const completionPercentage = totalScheduledToday > 0 ? Math.round((completedTodayCount / totalScheduledToday) * 100) : 0;

  // Overall streaks
  const overallStreaks = calculateOverallStreak(habits, completions, todayKey);

  // Total completions count
  const totalCompletedCount = completions.filter(
    (c) => c.status === 'completed' || c.completedValue >= (c.targetValueSnapshot || 1)
  ).length;

  // Habit consistency analysis
  let mostConsistentHabit = null;
  let leastConsistentHabit = null;

  if (habits.length > 0) {
    const habitStats = [];
    const compByHabit = new Map();
    for (const c of completions) {
      const hId = c.habitId.toString();
      if (!compByHabit.has(hId)) compByHabit.set(hId, new Map());
      compByHabit.get(hId).set(c.dateKey, c);
    }

    for (const habit of habits) {
      const map = compByHabit.get(habit._id.toString()) || new Map();
      const streak = calculateHabitStreak(habit, map, todayKey);

      // Count scheduled days in past 30 days
      let scheduledCount30 = 0;
      let completedCount30 = 0;
      const todayDate = parseDateKey(todayKey);
      for (let i = 0; i < 30; i++) {
        const d = addDays(todayDate, -i);
        const k = formatDateKey(d);
        if (isHabitScheduledOnDate(habit, k)) {
          scheduledCount30 += 1;
          const comp = map.get(k);
          if (comp && (comp.status === 'completed' || comp.completedValue >= habit.targetValue)) {
            completedCount30 += 1;
          }
        }
      }

      const rate = scheduledCount30 > 0 ? Math.round((completedCount30 / scheduledCount30) * 100) : 0;
      habitStats.push({
        id: habit._id,
        name: habit.name,
        color: habit.color,
        icon: habit.icon,
        rate,
        currentStreak: streak.currentStreak,
        longestStreak: streak.longestStreak,
      });
    }

    habitStats.sort((a, b) => b.rate - a.rate || b.currentStreak - a.currentStreak);
    if (habitStats.length > 0) {
      mostConsistentHabit = habitStats[0];
      if (habitStats.length > 1) {
        leastConsistentHabit = habitStats[habitStats.length - 1];
      }
    }
  }

  // Overall completion rate (lifetime or last 30 days)
  let totalScheduledAll = 0;
  let totalCompletedAll = 0;
  const todayDate = parseDateKey(todayKey);
  for (let i = 0; i < 30; i++) {
    const d = addDays(todayDate, -i);
    const k = formatDateKey(d);
    const sched = habits.filter((h) => isHabitScheduledOnDate(h, k));
    totalScheduledAll += sched.length;
    const comps = completions.filter((c) => c.dateKey === k && (c.status === 'completed' || c.completedValue >= (c.targetValueSnapshot || 1)));
    totalCompletedAll += Math.min(comps.length, sched.length);
  }

  const overallRate = totalScheduledAll > 0 ? Math.round((totalCompletedAll / totalScheduledAll) * 100) : 0;

  return {
    today: {
      dateKey: todayKey,
      completedCount: completedTodayCount,
      pendingCount: pendingTodayCount,
      totalScheduled: totalScheduledToday,
      percentage: completionPercentage,
    },
    streaks: {
      currentOverallStreak: overallStreaks.currentStreak,
      longestOverallStreak: overallStreaks.longestStreak,
    },
    totalCompletions: totalCompletedCount,
    overallCompletionRate: overallRate,
    mostConsistentHabit,
    leastConsistentHabit,
    activeHabitsCount: habits.length,
  };
}

async function getTrends(installationId, timeframe = 'weekly', todayKey = formatDateKey(new Date())) {
  const habits = await Habit.find({ installationId, isArchived: false });
  const completions = await HabitCompletion.find({ installationId });

  const completionsMap = new Map();
  for (const c of completions) {
    if (c.status === 'completed' || c.completedValue >= (c.targetValueSnapshot || 1)) {
      if (!completionsMap.has(c.dateKey)) completionsMap.set(c.dateKey, new Set());
      completionsMap.get(c.dateKey).add(c.habitId.toString());
    }
  }

  const todayDate = parseDateKey(todayKey);

  // 1. Last 7 Days Daily Breakdown
  const dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  const last7Days = [];
  let totalScheduled7 = 0;
  let totalCompleted7 = 0;

  for (let i = 6; i >= 0; i--) {
    const d = addDays(todayDate, -i);
    const k = formatDateKey(d);
    const sched = habits.filter((h) => isHabitScheduledOnDate(h, k));
    const completedSet = completionsMap.get(k) || new Set();
    const completedCount = sched.filter((h) => completedSet.has(h._id.toString())).length;

    totalScheduled7 += sched.length;
    totalCompleted7 += completedCount;

    last7Days.push({
      dateKey: k,
      dayLabel: dayNames[d.getDay()],
      scheduled: sched.length,
      completed: completedCount,
      percentage: sched.length > 0 ? Math.round((completedCount / sched.length) * 100) : 0,
    });
  }

  // 2. Weekly Trends (Last 8 Weeks)
  const weeklyTrends = [];
  for (let w = 7; w >= 0; w--) {
    let weekScheduled = 0;
    let weekCompleted = 0;
    const weekStart = addDays(todayDate, -(w * 7 + 6));
    const weekEnd = addDays(todayDate, -(w * 7));

    let curr = new Date(weekStart);
    while (curr <= weekEnd) {
      const k = formatDateKey(curr);
      const sched = habits.filter((h) => isHabitScheduledOnDate(h, k));
      const done = (completionsMap.get(k) || new Set());
      weekScheduled += sched.length;
      weekCompleted += sched.filter((h) => done.has(h._id.toString())).length;
      curr = addDays(curr, 1);
    }

    weeklyTrends.push({
      weekLabel: `Wk ${8 - w}`,
      startDateKey: formatDateKey(weekStart),
      endDateKey: formatDateKey(weekEnd),
      scheduled: weekScheduled,
      completed: weekCompleted,
      percentage: weekScheduled > 0 ? Math.round((weekCompleted / weekScheduled) * 100) : 0,
    });
  }

  // 3. Monthly Trends (Last 6 Months)
  const monthlyTrends = [];
  const monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  for (let m = 5; m >= 0; m--) {
    const targetMonth = new Date(todayDate.getFullYear(), todayDate.getMonth() - m, 1);
    const y = targetMonth.getFullYear();
    const mo = targetMonth.getMonth();
    const daysInMonth = new Date(y, mo + 1, 0).getDate();

    let mSched = 0;
    let mComp = 0;

    for (let day = 1; day <= daysInMonth; day++) {
      const d = new Date(y, mo, day);
      if (d > todayDate) break; // Don't count future days of current month
      const k = formatDateKey(d);
      const sched = habits.filter((h) => isHabitScheduledOnDate(h, k));
      const done = completionsMap.get(k) || new Set();
      mSched += sched.length;
      mComp += sched.filter((h) => done.has(h._id.toString())).length;
    }

    monthlyTrends.push({
      monthLabel: monthNames[mo],
      year: y,
      scheduled: mSched,
      completed: mComp,
      percentage: mSched > 0 ? Math.round((mComp / mSched) * 100) : 0,
    });
  }

  // 4. Habit Performance Comparison
  const habitComparison = habits.map((habit) => {
    let schedCount = 0;
    let compCount = 0;
    for (let i = 0; i < 30; i++) {
      const d = addDays(todayDate, -i);
      const k = formatDateKey(d);
      if (isHabitScheduledOnDate(habit, k)) {
        schedCount += 1;
        const done = completionsMap.get(k) || new Set();
        if (done.has(habit._id.toString())) compCount += 1;
      }
    }
    return {
      habitId: habit._id,
      name: habit.name,
      color: habit.color,
      icon: habit.icon,
      scheduledCount: schedCount,
      completedCount: compCount,
      percentage: schedCount > 0 ? Math.round((compCount / schedCount) * 100) : 0,
    };
  });

  return {
    timeframe,
    last7Days,
    weeklyTrends,
    monthlyTrends,
    habitComparison,
    completedVsMissed: {
      completed: totalCompleted7,
      missed: Math.max(0, totalScheduled7 - totalCompleted7),
      totalScheduled: totalScheduled7,
    },
  };
}

async function getCalendarHeatmap(installationId, year, month) {
  const y = parseInt(year, 10);
  const m = parseInt(month, 10) - 1; // 0-indexed

  const daysInMonth = new Date(y, m + 1, 0).getDate();
  const habits = await Habit.find({ installationId, isArchived: false });
  const startDateKey = formatDateKey(new Date(y, m, 1));
  const endDateKey = formatDateKey(new Date(y, m, daysInMonth));

  const completions = await HabitCompletion.find({
    installationId,
    dateKey: { $gte: startDateKey, $lte: endDateKey },
  });

  const completionsByDate = new Map();
  for (const c of completions) {
    if (!completionsByDate.has(c.dateKey)) {
      completionsByDate.set(c.dateKey, new Map());
    }
    completionsByDate.get(c.dateKey).set(c.habitId.toString(), c);
  }

  const days = [];
  for (let day = 1; day <= daysInMonth; day++) {
    const d = new Date(y, m, day);
    const dateKey = formatDateKey(d);
    const scheduledHabits = habits.filter((h) => isHabitScheduledOnDate(h, dateKey));
    const compMap = completionsByDate.get(dateKey) || new Map();

    const habitsDetails = scheduledHabits.map((h) => {
      const c = compMap.get(h._id.toString());
      const isDone = c && (c.status === 'completed' || c.completedValue >= (c.targetValueSnapshot || h.targetValue));
      return {
        habitId: h._id,
        name: h.name,
        color: h.color,
        icon: h.icon,
        isCompleted: Boolean(isDone),
        completedValue: c ? c.completedValue : 0,
        targetValue: h.targetValue,
        targetUnit: h.targetUnit,
      };
    });

    const completedCount = habitsDetails.filter((h) => h.isCompleted).length;
    const scheduledCount = scheduledHabits.length;

    let intensity = 'unscheduled';
    let percentage = 0;

    if (scheduledCount > 0) {
      percentage = Math.round((completedCount / scheduledCount) * 100);
      if (completedCount === scheduledCount) {
        intensity = 'full';
      } else if (completedCount > 0) {
        intensity = 'partial';
      } else {
        intensity = 'none';
      }
    }

    days.push({
      dateKey,
      day,
      dayOfWeek: d.getDay(),
      scheduledCount,
      completedCount,
      percentage,
      intensity, // 'unscheduled' | 'none' | 'partial' | 'full'
      habits: habitsDetails,
    });
  }

  return {
    year: y,
    month: m + 1,
    daysInMonth,
    days,
  };
}

async function getHabitStatistics(installationId, habitId) {
  const habit = await Habit.findOne({ _id: habitId, installationId });
  if (!habit) return null;

  const todayKey = formatDateKey(new Date());
  const completions = await HabitCompletion.find({ installationId, habitId }).sort({ dateKey: -1 });
  const map = new Map();
  for (const c of completions) {
    map.set(c.dateKey, c);
  }

  const streak = calculateHabitStreak(habit, map, todayKey);

  // Past 30 days history
  const todayDate = parseDateKey(todayKey);
  let totalScheduled = 0;
  let totalCompleted = 0;
  const recentHistory = [];

  for (let i = 13; i >= 0; i--) {
    const d = addDays(todayDate, -i);
    const k = formatDateKey(d);
    const isSched = isHabitScheduledOnDate(habit, k);
    const comp = map.get(k);
    const isDone = comp && (comp.status === 'completed' || comp.completedValue >= habit.targetValue);

    if (isSched) {
      totalScheduled += 1;
      if (isDone) totalCompleted += 1;
    }

    recentHistory.push({
      dateKey: k,
      isScheduled: isSched,
      isCompleted: Boolean(isDone),
      completedValue: comp ? comp.completedValue : 0,
    });
  }

  const completionRate = totalScheduled > 0 ? Math.round((totalCompleted / totalScheduled) * 100) : 0;

  return {
    habitId: habit._id,
    name: habit.name,
    category: habit.category,
    color: habit.color,
    icon: habit.icon,
    habitType: habit.habitType,
    targetValue: habit.targetValue,
    targetUnit: habit.targetUnit,
    currentStreak: streak.currentStreak,
    longestStreak: streak.longestStreak,
    completionRate,
    totalCompleted,
    totalScheduled,
    recentHistory,
  };
}

module.exports = {
  getSummary,
  getTrends,
  getCalendarHeatmap,
  getHabitStatistics,
};
