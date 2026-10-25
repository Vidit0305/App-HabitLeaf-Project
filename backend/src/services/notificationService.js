const Notification = require('../models/Notification');

async function getNotifications(installationId, options = {}) {
  const query = { installationId };
  if (options.status) {
    query.status = options.status;
  }

  const limit = parseInt(options.limit, 10) || 50;
  const skip = parseInt(options.skip, 10) || 0;

  const notifications = await Notification.find(query)
    .sort({ createdAt: -1 })
    .skip(skip)
    .limit(limit)
    .populate('habitId', 'name icon color category');

  const total = await Notification.countDocuments(query);
  const unreadCount = await Notification.countDocuments({
    installationId,
    status: { $in: ['scheduled', 'delivered'] },
  });

  return {
    notifications,
    total,
    unreadCount,
  };
}

async function createNotification(installationId, data) {
  const notification = new Notification({
    ...data,
    installationId,
  });
  return await notification.save();
}

async function markAsRead(installationId, notificationId) {
  return await Notification.findOneAndUpdate(
    { _id: notificationId, installationId },
    { $set: { status: 'read', readAt: new Date() } },
    { returnDocument: 'after' }
  );
}

async function markAllAsRead(installationId) {
  return await Notification.updateMany(
    {
      installationId,
      status: { $in: ['scheduled', 'delivered'] },
    },
    {
      $set: { status: 'read', readAt: new Date() },
    }
  );
}

async function deleteNotification(installationId, notificationId) {
  return await Notification.findOneAndDelete({ _id: notificationId, installationId });
}

async function clearAllNotifications(installationId) {
  return await Notification.deleteMany({ installationId });
}

module.exports = {
  getNotifications,
  createNotification,
  markAsRead,
  markAllAsRead,
  deleteNotification,
  clearAllNotifications,
};
