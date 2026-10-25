const express = require('express');
const router = express.Router();
const habitController = require('../controllers/habitController');

router.get('/', habitController.getHabits);
router.get('/:id', habitController.getHabitById);
router.post('/', habitController.createHabit);
router.patch('/:id', habitController.updateHabit);
router.patch('/:id/archive', habitController.archiveHabit);
router.delete('/:id', habitController.deleteHabit);

module.exports = router;
