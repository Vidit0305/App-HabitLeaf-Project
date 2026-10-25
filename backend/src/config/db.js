const mongoose = require('mongoose');
const { MongoMemoryServer } = require('mongodb-memory-server');

let memoryServerInstance = null;

async function connectDB() {
  const uri = process.env.MONGODB_URI || 'mongodb://127.0.0.1:27017/habit_tracker_db';
  const forceMemory = process.env.USE_MEMORY_DB === 'true';

  if (!forceMemory) {
    try {
      console.log(`[Database] Attempting connection to MongoDB at: ${uri.replace(/:([^:@]+)@/, ':****@')}`);
      await mongoose.connect(uri, {
        serverSelectionTimeoutMS: 15000,
      });
      console.log('[Database] Successfully connected to external/Atlas MongoDB.');
      return;
    } catch (err) {
      console.error(`[Database] Standard MongoDB connection failed: ${err.message}.`);
      if (process.env.NODE_ENV === 'production') {
        throw err;
      }
      console.warn('[Database] Falling back to embedded MongoDB engine...');
    }
  }

  try {
    console.log('[Database] Starting embedded MongoDB engine (mongodb-memory-server)...');
    memoryServerInstance = await MongoMemoryServer.create();
    const memUri = memoryServerInstance.getUri();
    await mongoose.connect(memUri, {
      directConnection: true,
      driverInfo: { name: 'nodejs', version: '1.0.0' },
    });
    console.log(`[Database] Successfully connected to embedded MongoDB instance at ${memUri}`);
  } catch (memErr) {
    console.error('[Database] Fatal: Failed to initialize embedded MongoDB engine:', memErr);
    throw memErr;
  }
}

async function closeDB() {
  if (mongoose.connection.readyState !== 0) {
    await mongoose.disconnect();
  }
  if (memoryServerInstance) {
    await memoryServerInstance.stop();
    memoryServerInstance = null;
  }
}

module.exports = {
  connectDB,
  closeDB,
};
