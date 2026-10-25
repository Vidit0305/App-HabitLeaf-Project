const express = require('express');
const router = express.Router();
const statisticsController = require('../controllers/statisticsController');

router.get('/summary', statisticsController.getSummary);
router.get('/trends', statisticsController.getTrends);
router.get('/calendar', statisticsController.getCalendarHeatmap);
router.get('/habits/:id', statisticsController.getHabitStatistics);

module.exports = router;
