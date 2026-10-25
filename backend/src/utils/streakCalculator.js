const { formatDateKey, parseDateKey, addDays, isHabitScheduledOnDate } = require('./dateHelper');

/**
 * Calculate streak for an individual habit
 * @param {Object} habit - Habit Mongoose doc or object
 * @param {Map<string, Object>} completionByDate - Map of dateKey -> HabitCompletion doc
 * @param {string} todayKey - Today's dateKey 'YYYY-MM-DD'
 */
function calculateHabitStreak(habit, completionByDate, todayKey = formatDateKey(new Date())) {
  const startDateKey = formatDateKey(new Date(habit.startDate));
  const today = parseDateKey(todayKey);

  // Get all scheduled date keys from startDate up to today in chronological order
  const scheduledDateKeys = [];
  let curr = parseDateKey(startDateKey);
  
  while (curr <= today) {
    const key = formatDateKey(curr);
    if (isHabitScheduledOnDate(habit, key)) {
      scheduledDateKeys.push(key);
    }
    curr = addDays(curr, 1);
  }

  if (scheduledDateKeys.length === 0) {
    return { currentStreak: 0, longestStreak: 0 };
  }

  // Calculate longest streak across history
  let longestStreak = 0;
  let tempStreak = 0;

  for (const dateKey of scheduledDateKeys) {
    const comp = completionByDate.get(dateKey);
    const isCompleted = comp && (comp.status === 'completed' || (habit.habitType === 'measurable' && comp.completedValue >= habit.targetValue));
    
    if (isCompleted) {
      tempStreak += 1;
      if (tempStreak > longestStreak) {
        longestStreak = tempStreak;
      }
    } else {
      // If dateKey is today and not yet completed, don't reset tempStreak for historical longest streak
      if (dateKey !== todayKey) {
        tempStreak = 0;
      }
    }
  }

  // Calculate current streak walking backwards
  let currentStreak = 0;
  let startIndex = scheduledDateKeys.length - 1;

  // Check if today is the latest scheduled day
  const latestDateKey = scheduledDateKeys[startIndex];
  if (latestDateKey === todayKey) {
    const todayComp = completionByDate.get(todayKey);
    const isTodayDone = todayComp && (todayComp.status === 'completed' || (habit.habitType === 'measurable' && todayComp.completedValue >= habit.targetValue));
    
    if (isTodayDone) {
      currentStreak += 1;
      startIndex -= 1;
    } else {
      // Today is not yet completed, but it's today so it doesn't break yesterday's streak
      startIndex -= 1;
    }
  }

  for (let i = startIndex; i >= 0; i--) {
    const dateKey = scheduledDateKeys[i];
    const comp = completionByDate.get(dateKey);
    const isDone = comp && (comp.status === 'completed' || (habit.habitType === 'measurable' && comp.completedValue >= habit.targetValue));
    
    if (isDone) {
      currentStreak += 1;
    } else {
      break; // Streak broken on past scheduled day
    }
  }

  return {
    currentStreak,
    longestStreak: Math.max(longestStreak, currentStreak),
  };
}

/**
 * Calculate overall streak across all active habits
 * @param {Array} habits - List of active habits
 * @param {Array} completions - List of completion records
 * @param {string} todayKey - Today's dateKey
 */
function calculateOverallStreak(habits, completions, todayKey = formatDateKey(new Date())) {
  if (!habits || habits.length === 0) {
    return { currentStreak: 0, longestStreak: 0 };
  }

  // Map: dateKey -> Set of completed habitIds
  const completionsByDate = new Map();
  for (const c of completions) {
    const isCompleted = c.status === 'completed' || c.completedValue >= (c.targetValueSnapshot || 1);
    if (isCompleted) {
      const hId = c.habitId.toString();
      if (!completionsByDate.has(c.dateKey)) {
        completionsByDate.set(c.dateKey, new Set());
      }
      completionsByDate.get(c.dateKey).add(hId);
    }
  }

  // Find the earliest start date among habits
  let earliestStart = parseDateKey(todayKey);
  for (const h of habits) {
    const hStart = new Date(h.startDate);
    if (hStart < earliestStart) {
      earliestStart = hStart;
    }
  }

  const today = parseDateKey(todayKey);
  let curr = parseDateKey(formatDateKey(earliestStart));

  // Determine for each date: total scheduled habits, completed habits
  const dayStats = [];
  while (curr <= today) {
    const dateKey = formatDateKey(curr);
    const scheduledHabits = habits.filter((h) => isHabitScheduledOnDate(h, dateKey));

    if (scheduledHabits.length > 0) {
      const completedSet = completionsByDate.get(dateKey) || new Set();
      let completedCount = 0;
      for (const h of scheduledHabits) {
        if (completedSet.has(h._id.toString())) {
          completedCount += 1;
        }
      }
      const isDayComplete = completedCount === scheduledHabits.length;
      dayStats.push({
        dateKey,
        scheduledCount: scheduledHabits.length,
        completedCount,
        isDayComplete,
      });
    }

    curr = addDays(curr, 1);
  }

  if (dayStats.length === 0) {
    return { currentStreak: 0, longestStreak: 0 };
  }

  // Longest streak
  let longestStreak = 0;
  let tempStreak = 0;

  for (const day of dayStats) {
    if (day.isDayComplete) {
      tempStreak += 1;
      if (tempStreak > longestStreak) {
        longestStreak = tempStreak;
      }
    } else {
      if (day.dateKey !== todayKey) {
        tempStreak = 0;
      }
    }
  }

  // Current streak walking backwards
  let currentStreak = 0;
  let startIndex = dayStats.length - 1;

  if (dayStats[startIndex].dateKey === todayKey) {
    if (dayStats[startIndex].isDayComplete) {
      currentStreak += 1;
      startIndex -= 1;
    } else {
      // Today in progress, check previous day
      startIndex -= 1;
    }
  }

  for (let i = startIndex; i >= 0; i--) {
    if (dayStats[i].isDayComplete) {
      currentStreak += 1;
    } else {
      break;
    }
  }

  return {
    currentStreak,
    longestStreak: Math.max(longestStreak, currentStreak),
  };
}

module.exports = {
  calculateHabitStreak,
  calculateOverallStreak,
};
