const backupService = require('../services/backupService');
const { successResponse, errorResponse } = require('../utils/responseHelper');

async function exportJsonBackup(req, res, next) {
  try {
    const backup = await backupService.exportJsonBackup(req.installationId);
    return successResponse(res, backup, 'Backup exported successfully');
  } catch (err) {
    next(err);
  }
}

async function exportCsv(req, res, next) {
  try {
    const csvData = await backupService.exportCsv(req.installationId);
    res.setHeader('Content-Type', 'text/csv');
    res.setHeader('Content-Disposition', 'attachment; filename="habit_tracker_completions.csv"');
    return res.status(200).send(csvData);
  } catch (err) {
    next(err);
  }
}

async function importBackup(req, res, next) {
  try {
    const result = await backupService.importJsonBackup(req.installationId, req.body);
    return successResponse(res, result, 'Backup imported and data restored successfully');
  } catch (err) {
    next(err);
  }
}

module.exports = {
  exportJsonBackup,
  exportCsv,
  importBackup,
};
