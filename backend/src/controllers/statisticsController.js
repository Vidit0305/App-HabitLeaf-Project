const statisticsService = require('../services/statisticsService');
const { successResponse, errorResponse } = require('../utils/responseHelper');
const { formatDateKey } = require('../utils/dateHelper');

async function getSummary(req, res, next) {
  try {
    const todayKey = req.query.date || formatDateKey(new Date());
    const summary = await statisticsService.getSummary(req.installationId, todayKey);
    return successResponse(res, summary, 'Statistics summary retrieved');
  } catch (err) {
    next(err);
  }
}

async function getTrends(req, res, next) {
  try {
    const timeframe = req.query.timeframe || 'weekly';
    const dateKey = req.query.date || formatDateKey(new Date());
    const trends = await statisticsService.getTrends(req.installationId, timeframe, dateKey);
    return successResponse(res, trends, 'Statistics trends retrieved');
  } catch (err) {
    next(err);
  }
}

async function getCalendarHeatmap(req, res, next) {
  try {
    const now = new Date();
    const year = req.query.year || now.getFullYear();
    const month = req.query.month || now.getMonth() + 1;
    const calendar = await statisticsService.getCalendarHeatmap(req.installationId, year, month);
    return successResponse(res, calendar, 'Calendar consistency heatmap retrieved');
  } catch (err) {
    next(err);
  }
}

async function getHabitStatistics(req, res, next) {
  try {
    const stats = await statisticsService.getHabitStatistics(req.installationId, req.params.id);
    if (!stats) {
      return errorResponse(res, 'Habit not found', 404);
    }
    return successResponse(res, stats, 'Habit statistics retrieved');
  } catch (err) {
    next(err);
  }
}

module.exports = {
  getSummary,
  getTrends,
  getCalendarHeatmap,
  getHabitStatistics,
};
