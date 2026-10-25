const notificationService = require('../services/notificationService');
const { successResponse, errorResponse } = require('../utils/responseHelper');

async function getNotifications(req, res, next) {
  try {
    const result = await notificationService.getNotifications(req.installationId, req.query);
    return successResponse(res, result, 'Notifications retrieved');
  } catch (err) {
    next(err);
  }
}

async function createNotification(req, res, next) {
  try {
    const { title, message } = req.body;
    if (!title || !message) {
      return errorResponse(res, 'title and message are required', 400);
    }
    const notif = await notificationService.createNotification(req.installationId, req.body);
    return successResponse(res, notif, 'Notification created', 201);
  } catch (err) {
    next(err);
  }
}

async function markAsRead(req, res, next) {
  try {
    const notif = await notificationService.markAsRead(req.installationId, req.params.id);
    if (!notif) {
      return errorResponse(res, 'Notification not found', 404);
    }
    return successResponse(res, notif, 'Notification marked as read');
  } catch (err) {
    next(err);
  }
}

async function markAllAsRead(req, res, next) {
  try {
    const result = await notificationService.markAllAsRead(req.installationId);
    return successResponse(res, result, 'All notifications marked as read');
  } catch (err) {
    next(err);
  }
}

async function deleteNotification(req, res, next) {
  try {
    const notif = await notificationService.deleteNotification(req.installationId, req.params.id);
    if (!notif) {
      return errorResponse(res, 'Notification not found', 404);
    }
    return successResponse(res, notif, 'Notification deleted');
  } catch (err) {
    next(err);
  }
}

async function clearAllNotifications(req, res, next) {
  try {
    const result = await notificationService.clearAllNotifications(req.installationId);
    return successResponse(res, result, 'All notifications cleared');
  } catch (err) {
    next(err);
  }
}

module.exports = {
  getNotifications,
  createNotification,
  markAsRead,
  markAllAsRead,
  deleteNotification,
  clearAllNotifications,
};
