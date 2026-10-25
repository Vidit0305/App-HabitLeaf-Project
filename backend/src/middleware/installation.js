/**
 * Installation Scoping Middleware
 * Enforces per-installation data scoping for no-login personal privacy.
 * Uses 'x-installation-id' header or falls back to 'default_personal_user'.
 */
function installationMiddleware(req, res, next) {
  let installationId = req.headers['x-installation-id'];
  if (!installationId || typeof installationId !== 'string' || installationId.trim() === '') {
    installationId = 'default_personal_user';
  }
  req.installationId = installationId.trim();
  res.setHeader('x-installation-id', req.installationId);
  next();
}

module.exports = installationMiddleware;
