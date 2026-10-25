const settingsService = require('../services/settingsService');
const { successResponse, errorResponse } = require('../utils/responseHelper');

async function getSettings(req, res, next) {
  try {
    const settings = await settingsService.getSettings(req.installationId);
    return successResponse(res, settings, 'Settings retrieved');
  } catch (err) {
    next(err);
  }
}

async function updateSettings(req, res, next) {
  try {
    const settings = await settingsService.updateSettings(req.installationId, req.body);
    return successResponse(res, settings, 'Settings updated');
  } catch (err) {
    next(err);
  }
}

async function resetAllData(req, res, next) {
  try {
    const settings = await settingsService.resetAllData(req.installationId);
    return successResponse(res, settings, 'All application data wiped and reset successfully');
  } catch (err) {
    next(err);
  }
}

module.exports = {
  getSettings,
  updateSettings,
  resetAllData,
};
