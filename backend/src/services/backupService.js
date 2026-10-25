const Habit = require('../models/Habit');
const HabitCompletion = require('../models/HabitCompletion');
const Notification = require('../models/Notification');
const Settings = require('../models/Settings');
const { getSettings } = require('./settingsService');

async function exportJsonBackup(installationId) {
  const [habits, completions, notifications, settings] = await Promise.all([
    Habit.find({ installationId }).lean(),
    HabitCompletion.find({ installationId }).lean(),
    Notification.find({ installationId }).lean(),
    getSettings(installationId),
  ]);

  return {
    version: '1.0.0',
    exportedAt: new Date().toISOString(),
    installationId,
    data: {
      habits,
      completions,
      notifications,
      settings,
    },
  };
}

async function exportCsv(installationId) {
  const [habits, completions] = await Promise.all([
    Habit.find({ installationId }).lean(),
    HabitCompletion.find({ installationId }).lean(),
  ]);

  const habitMap = new Map();
  for (const h of habits) {
    habitMap.set(h._id.toString(), h);
  }

  // Generate completions CSV
  let csv = 'Date,Habit Name,Category,Status,Completed Value,Target Value,Unit,Notes\n';
  for (const c of completions) {
    const habit = habitMap.get(c.habitId.toString()) || {};
    const name = `"${(c.habitNameSnapshot || habit.name || 'Unknown').replace(/"/g, '""')}"`;
    const category = `"${(habit.category || 'General').replace(/"/g, '""')}"`;
    const notes = `"${(c.notes || '').replace(/"/g, '""')}"`;
    const targetUnit = `"${(habit.targetUnit || 'times').replace(/"/g, '""')}"`;
    csv += `${c.dateKey},${name},${category},${c.status},${c.completedValue},${c.targetValueSnapshot || 1},${targetUnit},${notes}\n`;
  }

  return csv;
}

async function importJsonBackup(installationId, backupPayload) {
  if (!backupPayload || typeof backupPayload !== 'object') {
    throw new Error('Invalid backup payload: expected a JSON object.');
  }

  const data = backupPayload.data || backupPayload;
  if (!data.habits || !Array.isArray(data.habits)) {
    throw new Error('Invalid backup format: missing habits array.');
  }

  // 1. Map old habit IDs to new ObjectIds
  const mongoose = require('mongoose');
  const idMap = new Map();

  const importedHabits = [];
  for (const h of data.habits) {
    const oldId = (h._id || h.id).toString();
    const newId = new mongoose.Types.ObjectId();
    idMap.set(oldId, newId);

    const doc = {
      ...h,
      _id: newId,
      installationId,
      isArchived: Boolean(h.isArchived),
      createdAt: h.createdAt ? new Date(h.createdAt) : new Date(),
      updatedAt: h.updatedAt ? new Date(h.updatedAt) : new Date(),
    };
    importedHabits.push(doc);
  }

  const importedCompletions = [];
  if (Array.isArray(data.completions)) {
    for (const c of data.completions) {
      const oldHabitId = (c.habitId || '').toString();
      const newHabitId = idMap.get(oldHabitId);
      if (newHabitId && c.dateKey) {
        importedCompletions.push({
          ...c,
          _id: new mongoose.Types.ObjectId(),
          habitId: newHabitId,
          installationId,
          createdAt: c.createdAt ? new Date(c.createdAt) : new Date(),
          updatedAt: c.updatedAt ? new Date(c.updatedAt) : new Date(),
        });
      }
    }
  }

  // Clear existing data for this installation before restoring
  await Habit.deleteMany({ installationId });
  await HabitCompletion.deleteMany({ installationId });

  if (importedHabits.length > 0) {
    await Habit.insertMany(importedHabits);
  }
  if (importedCompletions.length > 0) {
    await HabitCompletion.insertMany(importedCompletions);
  }

  if (data.settings && typeof data.settings === 'object') {
    const s = data.settings;
    await Settings.findOneAndUpdate(
      { installationId },
      {
        $set: {
          displayName: s.displayName || 'Alex',
          themeMode: s.themeMode || 'system',
          timeFormat: s.timeFormat || '12h',
          firstDayOfWeek: s.firstDayOfWeek || 'monday',
          defaultReminderEnabled: s.defaultReminderEnabled ?? true,
          dailySummaryEnabled: s.dailySummaryEnabled ?? true,
        },
      },
      { upsert: true }
    );
  }

  return {
    importedHabitsCount: importedHabits.length,
    importedCompletionsCount: importedCompletions.length,
  };
}

module.exports = {
  exportJsonBackup,
  exportCsv,
  importJsonBackup,
};
