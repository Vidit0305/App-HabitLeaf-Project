const habitService = require('../services/habitService');
const { successResponse, errorResponse } = require('../utils/responseHelper');

async function getHabits(req, res, next) {
  try {
    const habits = await habitService.getHabits(req.installationId, req.query);
    return successResponse(res, habits, 'Habits retrieved successfully');
  } catch (err) {
    next(err);
  }
}

async function getHabitById(req, res, next) {
  try {
    const habit = await habitService.getHabitById(req.installationId, req.params.id);
    if (!habit) {
      return errorResponse(res, 'Habit not found', 404);
    }
    return successResponse(res, habit, 'Habit details retrieved');
  } catch (err) {
    next(err);
  }
}

async function createHabit(req, res, next) {
  try {
    const habit = await habitService.createHabit(req.installationId, req.body);
    return successResponse(res, habit, 'Habit created successfully', 201);
  } catch (err) {
    next(err);
  }
}

async function updateHabit(req, res, next) {
  try {
    const habit = await habitService.updateHabit(req.installationId, req.params.id, req.body);
    if (!habit) {
      return errorResponse(res, 'Habit not found', 404);
    }
    return successResponse(res, habit, 'Habit updated successfully');
  } catch (err) {
    next(err);
  }
}

async function archiveHabit(req, res, next) {
  try {
    const isArchived = req.body.isArchived !== undefined ? req.body.isArchived : true;
    const habit = await habitService.archiveHabit(req.installationId, req.params.id, isArchived);
    if (!habit) {
      return errorResponse(res, 'Habit not found', 404);
    }
    const msg = isArchived ? 'Habit archived successfully' : 'Habit unarchived successfully';
    return successResponse(res, habit, msg);
  } catch (err) {
    next(err);
  }
}

async function deleteHabit(req, res, next) {
  try {
    const habit = await habitService.deleteHabit(req.installationId, req.params.id);
    if (!habit) {
      return errorResponse(res, 'Habit not found', 404);
    }
    return successResponse(res, habit, 'Habit and history deleted permanently');
  } catch (err) {
    next(err);
  }
}

module.exports = {
  getHabits,
  getHabitById,
  createHabit,
  updateHabit,
  archiveHabit,
  deleteHabit,
};
