const mongoose = require('mongoose');

const HabitCompletionSchema = new mongoose.Schema(
  {
    installationId: {
      type: String,
      required: true,
      index: true,
      trim: true,
    },
    habitId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Habit',
      required: true,
      index: true,
    },
    dateKey: {
      type: String, // Format: YYYY-MM-DD
      required: true,
      match: [/^\d{4}-\d{2}-\d{2}$/, 'dateKey must be in YYYY-MM-DD format'],
      index: true,
    },
    status: {
      type: String,
      enum: ['completed', 'partial', 'skipped'],
      default: 'completed',
    },
    completedValue: {
      type: Number,
      default: 1,
      min: 0,
    },
    targetValueSnapshot: {
      type: Number,
      default: 1,
    },
    habitNameSnapshot: {
      type: String,
      default: '',
    },
    scheduledAt: {
      type: Date,
      default: null,
    },
    completedAt: {
      type: Date,
      default: Date.now,
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

// Unique compound index: only 1 completion entry per habit per dateKey for a given installation
HabitCompletionSchema.index({ installationId: 1, habitId: 1, dateKey: 1 }, { unique: true });
HabitCompletionSchema.index({ installationId: 1, dateKey: 1 });

module.exports = mongoose.model('HabitCompletion', HabitCompletionSchema);
