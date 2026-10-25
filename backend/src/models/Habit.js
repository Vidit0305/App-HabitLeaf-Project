const mongoose = require('mongoose');

const HabitSchema = new mongoose.Schema(
  {
    installationId: {
      type: String,
      required: true,
      index: true,
      trim: true,
    },
    name: {
      type: String,
      required: [true, 'Habit name is required'],
      trim: true,
      maxlength: 100,
    },
    description: {
      type: String,
      trim: true,
      maxlength: 300,
      default: '',
    },
    icon: {
      type: String,
      default: 'check_circle',
      trim: true,
    },
    color: {
      type: String,
      default: '#10B981', // Emerald green
      trim: true,
    },
    category: {
      type: String,
      default: 'Health',
      trim: true,
    },
    habitType: {
      type: String,
      enum: ['completion', 'measurable'],
      default: 'completion',
    },
    targetValue: {
      type: Number,
      default: 1,
      min: [0.1, 'Target must be positive'],
    },
    targetUnit: {
      type: String,
      default: 'times',
      trim: true,
    },
    frequency: {
      type: String,
      enum: ['every_day', 'selected_weekdays'],
      default: 'every_day',
    },
    selectedWeekdays: {
      type: [Number], // 1 = Monday ... 7 = Sunday
      default: [1, 2, 3, 4, 5, 6, 7],
    },
    startDate: {
      type: Date,
      default: Date.now,
    },
    endDate: {
      type: Date,
      default: null,
    },
    reminderEnabled: {
      type: Boolean,
      default: false,
    },
    reminderTime: {
      type: String,
      default: '09:00',
    },
    reminderWeekdays: {
      type: [Number],
      default: [],
    },
    isArchived: {
      type: Boolean,
      default: false,
      index: true,
    },
    notes: {
      type: String,
      default: '',
    },
  },
  {
    timestamps: true,
  }
);

HabitSchema.index({ installationId: 1, isArchived: 1 });
HabitSchema.index({ installationId: 1, category: 1 });

module.exports = mongoose.model('Habit', HabitSchema);
