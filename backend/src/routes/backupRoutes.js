const express = require('express');
const router = express.Router();
const backupController = require('../controllers/backupController');

router.get('/export', backupController.exportJsonBackup);
router.get('/csv', backupController.exportCsv);
router.post('/import', backupController.importBackup);

module.exports = router;
