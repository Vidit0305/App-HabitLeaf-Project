const express = require('express');
const router = express.Router();
const completionController = require('../controllers/completionController');

router.get('/', completionController.getCompletions);
router.get('/date/:date', completionController.getCompletionsByDate);
router.post('/', completionController.upsertCompletion);
router.post('/undo', completionController.undoCompletion);
router.patch('/:id', completionController.updateCompletion);
router.delete('/:id', completionController.deleteCompletion);

module.exports = router;
