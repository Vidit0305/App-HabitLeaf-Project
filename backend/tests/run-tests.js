/**
 * Native Node.js Test Runner
 * Runs the backend test suite directly without Jest VM sandbox quirks
 */
const { MongoMemoryServer } = require('mongodb-memory-server');
const mongoose = require('mongoose');
const request = require('supertest');

process.env.NODE_ENV = 'test';
process.env.USE_MEMORY_DB = 'true';

const app = require('../src/app');

async function runTests() {
  console.log('--- Starting Backend Integration Tests ---');
  let mongoServer;
  let passed = 0;
  let failed = 0;

  function assert(condition, message) {
    if (!condition) {
      throw new Error(`Assertion failed: ${message}`);
    }
  }

  try {
    console.log('[Setup] Starting embedded MongoDB...');
    mongoServer = await MongoMemoryServer.create();
    const uri = mongoServer.getUri();
    await mongoose.connect(uri, { directConnection: true });
    console.log('[Setup] Connected to embedded MongoDB successfully.');

    const instA = 'test_installation_alpha';
    const instB = 'test_installation_beta';
    let habitAId;
    let habitBId;

    // Test 1: Health check
    try {
      const res = await request(app).get('/api/health');
      assert(res.status === 200, 'Health endpoint status 200');
      assert(res.body.success === true, 'Health success true');
      console.log('✓ Health check passed');
      passed++;
    } catch (e) {
      console.error('✗ Health check failed:', e.message);
      failed++;
    }

    // Test 2: Create habit A
    try {
      const res = await request(app)
        .post('/api/habits')
        .set('x-installation-id', instA)
        .send({
          name: 'Read 20 Pages',
          category: 'Learning',
          habitType: 'measurable',
          targetValue: 20,
          targetUnit: 'pages',
          frequency: 'every_day',
          startDate: '2026-10-01',
          color: '#2563EB',
          icon: 'menu_book',
        });
      assert(res.status === 201, 'Habit created status 201');
      assert(res.body.data.name === 'Read 20 Pages', 'Habit name match');
      habitAId = res.body.data._id;
      console.log('✓ Create habit A passed');
      passed++;
    } catch (e) {
      console.error('✗ Create habit A failed:', e.message);
      failed++;
    }

    // Test 3: Create habit B (different installation)
    try {
      const res = await request(app)
        .post('/api/habits')
        .set('x-installation-id', instB)
        .send({
          name: 'Morning Workout',
          category: 'Fitness',
          habitType: 'completion',
          frequency: 'every_day',
          color: '#10B981',
          icon: 'fitness_center',
        });
      assert(res.status === 201, 'Habit B created status 201');
      habitBId = res.body.data._id;
      console.log('✓ Create habit B passed');
      passed++;
    } catch (e) {
      console.error('✗ Create habit B failed:', e.message);
      failed++;
    }

    // Test 4: Installation scoping data isolation
    try {
      const resA = await request(app).get('/api/habits').set('x-installation-id', instA);
      const resB = await request(app).get('/api/habits').set('x-installation-id', instB);
      assert(resA.body.data.length === 1 && resA.body.data[0].name === 'Read 20 Pages', 'Inst A habits isolated');
      assert(resB.body.data.length === 1 && resB.body.data[0].name === 'Morning Workout', 'Inst B habits isolated');
      console.log('✓ Installation scoping data isolation passed');
      passed++;
    } catch (e) {
      console.error('✗ Data isolation failed:', e.message);
      failed++;
    }

    // Test 5: Habit update & archive
    try {
      const patchRes = await request(app)
        .patch(`/api/habits/${habitAId}`)
        .set('x-installation-id', instA)
        .send({ description: 'Read Atomic Habits' });
      assert(patchRes.body.data.description === 'Read Atomic Habits', 'Description updated');

      const archiveRes = await request(app)
        .patch(`/api/habits/${habitAId}/archive`)
        .set('x-installation-id', instA)
        .send({ isArchived: true });
      assert(archiveRes.body.data.isArchived === true, 'Habit archived');

      // Unarchive
      await request(app)
        .patch(`/api/habits/${habitAId}/archive`)
        .set('x-installation-id', instA)
        .send({ isArchived: false });
      console.log('✓ Habit update & archive passed');
      passed++;
    } catch (e) {
      console.error('✗ Habit update & archive failed:', e.message);
      failed++;
    }

    // Test 6: Habit completion & duplicate prevention
    try {
      const dateKey = '2026-10-24';
      const comp1 = await request(app)
        .post('/api/completions')
        .set('x-installation-id', instA)
        .send({
          habitId: habitAId,
          dateKey,
          status: 'completed',
          completedValue: 20,
        });
      assert(comp1.status === 200, 'Completion created');

      const comp2 = await request(app)
        .post('/api/completions')
        .set('x-installation-id', instA)
        .send({
          habitId: habitAId,
          dateKey,
          status: 'completed',
          completedValue: 20,
          notes: 'Finished chapter 4',
        });
      assert(comp2.status === 200, 'Completion upserted');
      assert(comp2.body.data.notes === 'Finished chapter 4', 'Notes saved');

      const allComps = await request(app)
        .get(`/api/completions?habitId=${habitAId}`)
        .set('x-installation-id', instA);
      assert(allComps.body.data.length === 1, 'Duplicate completion prevented (only 1 record exists)');
      console.log('✓ Habit completion & duplicate prevention passed');
      passed++;
    } catch (e) {
      console.error('✗ Habit completion test failed:', e.message);
      failed++;
    }

    // Test 7: Statistics summary & trends
    try {
      const sumRes = await request(app)
        .get('/api/statistics/summary?date=2026-10-24')
        .set('x-installation-id', instA);
      assert(sumRes.status === 200, 'Summary status 200');
      assert(sumRes.body.data.today.completedCount === 1, 'Today completedCount is 1');
      assert(sumRes.body.data.today.percentage === 100, 'Today percentage is 100%');
      assert(sumRes.body.data.streaks.currentOverallStreak >= 1, 'Streak is at least 1');

      const trendsRes = await request(app)
        .get('/api/statistics/trends?date=2026-10-24')
        .set('x-installation-id', instA);
      assert(trendsRes.body.data.last7Days.length === 7, '7 days breakdown returned');
      assert(trendsRes.body.data.weeklyTrends.length === 8, '8 weeks breakdown returned');

      const calRes = await request(app)
        .get('/api/statistics/calendar?year=2026&month=10')
        .set('x-installation-id', instA);
      assert(calRes.body.data.days.length === 31, 'Calendar heatmap contains 31 days');
      const d24 = calRes.body.data.days.find((d) => d.dateKey === '2026-10-24');
      assert(d24 && d24.intensity === 'full', 'Date 2026-10-24 has full intensity');

      console.log('✓ Statistics summary, trends, and calendar heatmap passed');
      passed++;
    } catch (e) {
      console.error('✗ Statistics test failed:', e.message);
      failed++;
    }

    // Test 8: Notifications
    try {
      const notifCreate = await request(app)
        .post('/api/notifications')
        .set('x-installation-id', instA)
        .send({
          title: 'Evening Reminder',
          message: 'Time for evening reading.',
          type: 'reminder',
        });
      assert(notifCreate.status === 201, 'Notification created');
      const nId = notifCreate.body.data._id;

      const notifList = await request(app)
        .get('/api/notifications')
        .set('x-installation-id', instA);
      assert(notifList.body.data.notifications.length >= 1, 'Notification in list');
      assert(notifList.body.data.unreadCount >= 1, 'Unread count updated');

      const readRes = await request(app)
        .patch(`/api/notifications/${nId}/read`)
        .set('x-installation-id', instA);
      assert(readRes.body.data.status === 'read', 'Notification marked read');

      console.log('✓ Notifications workflow passed');
      passed++;
    } catch (e) {
      console.error('✗ Notifications test failed:', e.message);
      failed++;
    }

    // Test 9: Settings, Export, Reset, Import
    try {
      const setRes = await request(app)
        .patch('/api/settings')
        .set('x-installation-id', instA)
        .send({ displayName: 'Taylor', themeMode: 'dark' });
      assert(setRes.body.data.displayName === 'Taylor', 'Display name updated');

      const expJson = await request(app)
        .get('/api/backup/export')
        .set('x-installation-id', instA);
      assert(expJson.body.data.data.habits.length === 1, 'Export contains habit');

      const expCsv = await request(app)
        .get('/api/backup/csv')
        .set('x-installation-id', instA);
      assert(expCsv.text.includes('Read 20 Pages'), 'CSV export includes habit name');

      const resetRes = await request(app)
        .post('/api/settings/reset')
        .set('x-installation-id', instA);
      assert(resetRes.status === 200, 'Reset data success');

      const postResetHabits = await request(app)
        .get('/api/habits')
        .set('x-installation-id', instA);
      assert(postResetHabits.body.data.length === 0, 'Habits wiped after reset');

      const impRes = await request(app)
        .post('/api/backup/import')
        .set('x-installation-id', instA)
        .send(expJson.body.data);
      assert(impRes.status === 200, 'Import restored data');

      const restoredHabits = await request(app)
        .get('/api/habits')
        .set('x-installation-id', instA);
      assert(restoredHabits.body.data.length === 1, 'Restored habit present');
      assert(restoredHabits.body.data[0].name === 'Read 20 Pages', 'Restored habit name matches');

      console.log('✓ Settings, export, reset, and import backup passed');
      passed++;
    } catch (e) {
      console.error('✗ Settings & backup test failed:', e.message);
      failed++;
    }

  } finally {
    if (mongoose.connection.readyState !== 0) {
      await mongoose.disconnect();
    }
    if (mongoServer) {
      await mongoServer.stop();
    }
  }

  console.log(`\n========================================`);
  console.log(` Tests Finished: ${passed} Passed, ${failed} Failed`);
  console.log(`========================================`);

  if (failed > 0) {
    process.exit(1);
  } else {
    process.exit(0);
  }
}

runTests().catch((err) => {
  console.error('Test runner fatal error:', err);
  process.exit(1);
});
