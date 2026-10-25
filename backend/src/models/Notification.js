const mongoose = require('mongoose');

const NotificationSchema = new mongoose.Schema(
  {
    installationId: {
      type: String,
      required: true,
      index: true,
      trim: true,
    },
    type: {
      type: String,
      enum: ['reminder', 'delivered', 'missed', 'summary', 'streak_milestone', 'system'],
      default: 'delivered',
    },
    title: {
      type: String,
      required: true,
      trim: true,
    },
    message: {
      type: String,
      required: true,
      trim: true,
    },
    habitId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Habit',
      default: null,
    },
    scheduledAt: {
      type: Date,
      default: null,
    },
    deliveredAt: {
      type: Date,
      default: Date.now,
    },
    readAt: {
      type: Date,
      default: null,
    },
    status: {
      type: String,
      enum: ['scheduled', 'delivered', 'read', 'dismissed', 'failed'],
      default: 'delivered',
    },
  },
  {
    timestamps: true,
  }
);

NotificationSchema.index({ installationId: 1, createdAt: -1 });
NotificationSchema.index({ installationId: 1, status: 1 });

module.exports = mongoose.model('Notification', NotificationSchema);
