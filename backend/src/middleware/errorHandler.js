const { errorResponse } = require('../utils/responseHelper');

function errorHandler(err, req, res, next) { // eslint-disable-line no-unused-vars
  console.error(`[Error] ${req.method} ${req.originalUrl}:`, err);

  if (err.name === 'ValidationError') {
    const messages = Object.values(err.errors).map((e) => e.message);
    return errorResponse(res, 'Validation Error', 400, messages);
  }

  if (err.code === 11000) {
    return errorResponse(res, 'A duplicate record already exists for this entry.', 409);
  }

  if (err.name === 'CastError') {
    return errorResponse(res, `Invalid format for field: ${err.path}`, 400);
  }

  const statusCode = err.statusCode || 500;
  const message = err.message || 'Internal Server Error';
  return errorResponse(res, message, statusCode);
}

module.exports = errorHandler;
