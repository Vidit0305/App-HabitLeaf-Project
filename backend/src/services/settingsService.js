const Settings = require('../models/Settings');
const Habit = require('../models/Habit');
const HabitCompletion = require('../models/HabitCompletion');
const Notification = require('../models/Notification');

async function getSettings(installationId) {
  let settings = await Settings.findOne({ installationId });
  if (!settings) {
    settings = await Settings.create({
      installationId,
      displayName: 'Alex',
      avatarReference: 'avatar_1',
      themeMode: 'system',
      timeFormat: '12h',
      firstDayOfWeek: 'monday',
      defaultReminderEnabled: true,
      dailySummaryEnabled: true,
      timezone: 'UTC',
    });
  }
  return settings;
}

async function updateSettings(installationId, updateData) {
  delete updateData.installationId;
  let settings = await Settings.findOneAndUpdate(
    { installationId },
    { $set: updateData },
    { returnDocument: 'after', upsert: true, runValidators: true }
  );
  return settings;
}

async function resetAllData(installationId) {
  await Promise.all([
    Habit.deleteMany({ installationId }),
    HabitCompletion.deleteMany({ installationId }),
    Notification.deleteMany({ installationId }),
    Settings.deleteMany({ installationId }),
  ]);

  // Re-seed default settings
  return await getSettings(installationId);
}

module.exports = {
  getSettings,
  updateSettings,
  resetAllData,
};
