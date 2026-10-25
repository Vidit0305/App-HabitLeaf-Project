const Habit = require('../models/Habit');
const HabitCompletion = require('../models/HabitCompletion');
const { calculateHabitStreak } = require('../utils/streakCalculator');
const { formatDateKey } = require('../utils/dateHelper');

async function getHabits(installationId, filter = {}) {
  const query = { installationId };

  if (filter.isArchived !== undefined) {
    query.isArchived = filter.isArchived === 'true' || filter.isArchived === true;
  }
  if (filter.category && filter.category !== 'All') {
    query.category = filter.category;
  }
  if (filter.search) {
    query.name = { $regex: filter.search, $options: 'i' };
  }

  const habits = await Habit.find(query).sort({ createdAt: -1 });

  // Attach streaks and today's status to habits
  const todayKey = formatDateKey(new Date());
  const habitIds = habits.map((h) => h._id);
  const completions = await HabitCompletion.find({
    installationId,
    habitId: { $in: habitIds },
  });

  // Group completions by habitId
  const completionsByHabit = new Map();
  for (const c of completions) {
    const hId = c.habitId.toString();
    if (!completionsByHabit.has(hId)) {
      completionsByHabit.set(hId, new Map());
    }
    completionsByHabit.get(hId).set(c.dateKey, c);
  }

  const habitsWithStats = habits.map((habit) => {
    const hId = habit._id.toString();
    const map = completionsByHabit.get(hId) || new Map();
    const streak = calculateHabitStreak(habit, map, todayKey);
    const todayComp = map.get(todayKey);

    return {
      ...habit.toObject(),
      currentStreak: streak.currentStreak,
      longestStreak: streak.longestStreak,
      todayCompletion: todayComp || null,
      isCompletedToday: Boolean(
        todayComp &&
          (todayComp.status === 'completed' ||
            (habit.habitType === 'measurable' && todayComp.completedValue >= habit.targetValue))
      ),
    };
  });

  return habitsWithStats;
}

async function getHabitById(installationId, habitId) {
  const habit = await Habit.findOne({ _id: habitId, installationId });
  if (!habit) return null;

  const todayKey = formatDateKey(new Date());
  const completions = await HabitCompletion.find({ installationId, habitId }).sort({ dateKey: -1 });
  const map = new Map();
  for (const c of completions) {
    map.set(c.dateKey, c);
  }

  const streak = calculateHabitStreak(habit, map, todayKey);
  const todayComp = map.get(todayKey);

  return {
    ...habit.toObject(),
    currentStreak: streak.currentStreak,
    longestStreak: streak.longestStreak,
    todayCompletion: todayComp || null,
    isCompletedToday: Boolean(
      todayComp &&
        (todayComp.status === 'completed' ||
          (habit.habitType === 'measurable' && todayComp.completedValue >= habit.targetValue))
    ),
    recentCompletions: completions.slice(0, 30),
  };
}

async function createHabit(installationId, habitData) {
  const habit = new Habit({
    ...habitData,
    installationId,
  });
  return await habit.save();
}

async function updateHabit(installationId, habitId, updateData) {
  // Prevent changing installationId
  delete updateData.installationId;

  const habit = await Habit.findOneAndUpdate(
    { _id: habitId, installationId },
    { $set: updateData },
    { returnDocument: 'after', runValidators: true }
  );
  return habit;
}

async function archiveHabit(installationId, habitId, isArchived = true) {
  return await Habit.findOneAndUpdate(
    { _id: habitId, installationId },
    { $set: { isArchived } },
    { returnDocument: 'after' }
  );
}

async function deleteHabit(installationId, habitId) {
  const habit = await Habit.findOneAndDelete({ _id: habitId, installationId });
  if (habit) {
    await HabitCompletion.deleteMany({ habitId, installationId });
  }
  return habit;
}

module.exports = {
  getHabits,
  getHabitById,
  createHabit,
  updateHabit,
  archiveHabit,
  deleteHabit,
};
