const completionService = require('../services/completionService');
const { successResponse, errorResponse } = require('../utils/responseHelper');

async function getCompletions(req, res, next) {
  try {
    const completions = await completionService.getCompletions(req.installationId, req.query);
    return successResponse(res, completions, 'Completions retrieved');
  } catch (err) {
    next(err);
  }
}

async function getCompletionsByDate(req, res, next) {
  try {
    const dateKey = req.params.date;
    const completions = await completionService.getCompletionsByDate(req.installationId, dateKey);
    return successResponse(res, completions, `Completions for date ${dateKey}`);
  } catch (err) {
    next(err);
  }
}

async function upsertCompletion(req, res, next) {
  try {
    const { habitId, dateKey } = req.body;
    if (!habitId || !dateKey) {
      return errorResponse(res, 'habitId and dateKey are required', 400);
    }
    const completion = await completionService.upsertCompletion(req.installationId, req.body);
    return successResponse(res, completion, 'Habit completion recorded', 200);
  } catch (err) {
    next(err);
  }
}

async function updateCompletion(req, res, next) {
  try {
    const completion = await completionService.updateCompletion(
      req.installationId,
      req.params.id,
      req.body
    );
    if (!completion) {
      return errorResponse(res, 'Completion record not found', 404);
    }
    return successResponse(res, completion, 'Completion updated');
  } catch (err) {
    next(err);
  }
}

async function deleteCompletion(req, res, next) {
  try {
    const completion = await completionService.deleteCompletion(req.installationId, req.params.id);
    if (!completion) {
      return errorResponse(res, 'Completion record not found', 404);
    }
    return successResponse(res, completion, 'Completion undone/deleted');
  } catch (err) {
    next(err);
  }
}

async function undoCompletion(req, res, next) {
  try {
    const { habitId, dateKey } = req.body;
    if (!habitId || !dateKey) {
      return errorResponse(res, 'habitId and dateKey are required', 400);
    }
    const completion = await completionService.undoCompletionByHabitAndDate(
      req.installationId,
      habitId,
      dateKey
    );
    return successResponse(res, completion, 'Completion undone successfully');
  } catch (err) {
    next(err);
  }
}

module.exports = {
  getCompletions,
  getCompletionsByDate,
  upsertCompletion,
  updateCompletion,
  deleteCompletion,
  undoCompletion,
};
