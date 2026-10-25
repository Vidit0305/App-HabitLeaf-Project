const HabitCompletion = require('../models/HabitCompletion');
const Habit = require('../models/Habit');
const Notification = require('../models/Notification');
const { calculateHabitStreak, calculateOverallStreak } = require('../utils/streakCalculator');
const { formatDateKey } = require('../utils/dateHelper');

async function getCompletions(installationId, filter = {}) {
  const query = { installationId };

  if (filter.habitId) {
    query.habitId = filter.habitId;
  }
  if (filter.dateKey) {
    query.dateKey = filter.dateKey;
  } else if (filter.startDateKey && filter.endDateKey) {
    query.dateKey = { $gte: filter.startDateKey, $lte: filter.endDateKey };
  }

  return await HabitCompletion.find(query).sort({ dateKey: -1 });
}

async function getCompletionsByDate(installationId, dateKey) {
  return await HabitCompletion.find({ installationId, dateKey });
}

async function upsertCompletion(installationId, data) {
  const { habitId, dateKey, status = 'completed', completedValue, notes = '' } = data;

  const habit = await Habit.findOne({ _id: habitId, installationId });
  if (!habit) {
    const error = new Error('Habit not found');
    error.statusCode = 404;
    throw error;
  }

  const value = completedValue !== undefined ? completedValue : (habit.habitType === 'measurable' ? habit.targetValue : 1);
  const isDone = status === 'completed' || (habit.habitType === 'measurable' && value >= habit.targetValue);

  const updateDoc = {
    $set: {
      status: isDone ? 'completed' : 'partial',
      completedValue: value,
      targetValueSnapshot: habit.targetValue || 1,
      habitNameSnapshot: habit.name,
      notes: notes,
      completedAt: new Date(),
    },
  };

  const completion = await HabitCompletion.findOneAndUpdate(
    { installationId, habitId, dateKey },
    updateDoc,
    { upsert: true, returnDocument: 'after', runValidators: true }
  );

  // Check if milestone streak achieved
  try {
    const allComps = await HabitCompletion.find({ installationId, habitId });
    const map = new Map();
    for (const c of allComps) map.set(c.dateKey, c);
    const streak = calculateHabitStreak(habit, map, dateKey);

    const milestones = [3, 7, 14, 21, 30, 50, 100];
    if (milestones.includes(streak.currentStreak)) {
      // Create milestone notification
      await Notification.create({
        installationId,
        type: 'streak_milestone',
        title: `🔥 ${streak.currentStreak}-Day Streak!`,
        message: `Incredible dedication! You reached a ${streak.currentStreak}-day streak on "${habit.name}".`,
        habitId: habit._id,
        status: 'delivered',
        deliveredAt: new Date(),
      });
    }
  } catch (err) {
    console.error('Streak milestone notification check error:', err);
  }

  return completion;
}

async function updateCompletion(installationId, completionId, updateData) {
  delete updateData.installationId;
  delete updateData.habitId;
  delete updateData.dateKey;

  return await HabitCompletion.findOneAndUpdate(
    { _id: completionId, installationId },
    { $set: updateData },
    { returnDocument: 'after', runValidators: true }
  );
}

async function deleteCompletion(installationId, completionId) {
  return await HabitCompletion.findOneAndDelete({ _id: completionId, installationId });
}

async function undoCompletionByHabitAndDate(installationId, habitId, dateKey) {
  return await HabitCompletion.findOneAndDelete({ installationId, habitId, dateKey });
}

module.exports = {
  getCompletions,
  getCompletionsByDate,
  upsertCompletion,
  updateCompletion,
  deleteCompletion,
  undoCompletionByHabitAndDate,
};
