const mongoose = require('mongoose');

const SettingsSchema = new mongoose.Schema(
  {
    installationId: {
      type: String,
      required: true,
      unique: true,
      index: true,
      trim: true,
    },
    displayName: {
      type: String,
      default: 'Alex',
      trim: true,
      maxlength: 50,
    },
    avatarReference: {
      type: String,
      default: 'avatar_1',
      trim: true,
    },
    themeMode: {
      type: String,
      enum: ['light', 'dark', 'system'],
      default: 'system',
    },
    timeFormat: {
      type: String,
      enum: ['12h', '24h'],
      default: '12h',
    },
    firstDayOfWeek: {
      type: String,
      enum: ['monday', 'sunday'],
      default: 'monday',
    },
    defaultReminderEnabled: {
      type: Boolean,
      default: true,
    },
    dailySummaryEnabled: {
      type: Boolean,
      default: true,
    },
    timezone: {
      type: String,
      default: 'UTC',
    },
  },
  {
    timestamps: true,
  }
);

module.exports = mongoose.model('Settings', SettingsSchema);
