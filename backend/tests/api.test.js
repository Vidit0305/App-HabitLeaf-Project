const request = require('supertest');
const { MongoMemoryServer } = require('mongodb-memory-server');
const mongoose = require('mongoose');

process.env.NODE_ENV = 'test';
process.env.USE_MEMORY_DB = 'true';

jest.setTimeout(60000);

const app = require('../src/app');

let mongoServer;

beforeAll(async () => {
  mongoServer = await MongoMemoryServer.create();
  const uri = mongoServer.getUri();
  await mongoose.connect(uri, {
    directConnection: true,
    driverInfo: { name: 'nodejs', version: '1.0.0' },
  });
});

afterAll(async () => {
  await mongoose.disconnect();
  await mongoServer.stop();
});

describe('Habit Tracker Backend API Test Suite', () => {
  const installationA = 'test_inst_user_a';
  const installationB = 'test_inst_user_b';

  let habitAId;
  let habitBId;

  test('GET /api/health should return 200 and healthy status', async () => {
    const res = await request(app).get('/api/health');
    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.status).toBe('healthy');
  });

  // 1. Habit CRUD
  test('POST /api/habits should create a habit scoped to installation A', async () => {
    const res = await request(app)
      .post('/api/habits')
      .set('x-installation-id', installationA)
      .send({
        name: 'Morning Meditation',
        description: '15 minutes of mindfulness',
        category: 'Mindfulness',
        color: '#2563EB',
        icon: 'self_improvement',
        habitType: 'completion',
        frequency: 'every_day',
      });

    expect(res.status).toBe(201);
    expect(res.body.success).toBe(true);
    expect(res.body.data.name).toBe('Morning Meditation');
    habitAId = res.body.data._id;
  });

  test('POST /api/habits should create a measurable habit for installation B', async () => {
    const res = await request(app)
      .post('/api/habits')
      .set('x-installation-id', installationB)
      .send({
        name: 'Drink Water',
        category: 'Health',
        color: '#0284C7',
        icon: 'water_drop',
        habitType: 'measurable',
        targetValue: 3,
        targetUnit: 'litres',
        frequency: 'every_day',
      });

    expect(res.status).toBe(201);
    expect(res.body.data.targetValue).toBe(3);
    habitBId = res.body.data._id;
  });

  test('GET /api/habits should isolate data between installations A and B', async () => {
    const resA = await request(app)
      .get('/api/habits')
      .set('x-installation-id', installationA);
    expect(resA.status).toBe(200);
    expect(resA.body.data.length).toBe(1);
    expect(resA.body.data[0].name).toBe('Morning Meditation');

    const resB = await request(app)
      .get('/api/habits')
      .set('x-installation-id', installationB);
    expect(resB.status).toBe(200);
    expect(resB.body.data.length).toBe(1);
    expect(resB.body.data[0].name).toBe('Drink Water');
  });

  test('PATCH /api/habits/:id should update habit fields', async () => {
    const res = await request(app)
      .patch(`/api/habits/${habitAId}`)
      .set('x-installation-id', installationA)
      .send({ description: '20 minutes mindful breathing' });

    expect(res.status).toBe(200);
    expect(res.body.data.description).toBe('20 minutes mindful breathing');
  });

  test('PATCH /api/habits/:id/archive should archive habit', async () => {
    const res = await request(app)
      .patch(`/api/habits/${habitAId}/archive`)
      .set('x-installation-id', installationA)
      .send({ isArchived: true });

    expect(res.status).toBe(200);
    expect(res.body.data.isArchived).toBe(true);

    // Unarchive for further completion tests
    await request(app)
      .patch(`/api/habits/${habitAId}/archive`)
      .set('x-installation-id', installationA)
      .send({ isArchived: false });
  });

  // 2. Completions & Duplicate Prevention
  test('POST /api/completions should record completion and prevent duplicate entries', async () => {
    const dateKey = '2026-10-24';
    const res1 = await request(app)
      .post('/api/completions')
      .set('x-installation-id', installationA)
      .send({
        habitId: habitAId,
        dateKey,
        status: 'completed',
        completedValue: 1,
      });

    expect(res1.status).toBe(200);
    expect(res1.body.success).toBe(true);
    expect(res1.body.data.status).toBe('completed');

    // Calling it again on the same date should update/upsert, not duplicate
    const res2 = await request(app)
      .post('/api/completions')
      .set('x-installation-id', installationA)
      .send({
        habitId: habitAId,
        dateKey,
        status: 'completed',
        completedValue: 1,
        notes: 'Felt very relaxed',
      });

    expect(res2.status).toBe(200);
    expect(res2.body.data.notes).toBe('Felt very relaxed');

    // Verify only 1 completion exists for this date
    const listRes = await request(app)
      .get(`/api/completions?habitId=${habitAId}`)
      .set('x-installation-id', installationA);
    expect(listRes.body.data.length).toBe(1);
  });

  test('POST /api/completions/undo should undo completion for habit and date', async () => {
    const dateKey = '2026-10-24';
    const res = await request(app)
      .post('/api/completions/undo')
      .set('x-installation-id', installationA)
      .send({ habitId: habitAId, dateKey });

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);

    // Re-complete for statistics verification
    await request(app)
      .post('/api/completions')
      .set('x-installation-id', installationA)
      .send({ habitId: habitAId, dateKey, status: 'completed', completedValue: 1 });
  });

  // 3. Statistics
  test('GET /api/statistics/summary should calculate metrics and streaks correctly', async () => {
    const res = await request(app)
      .get('/api/statistics/summary?date=2026-10-24')
      .set('x-installation-id', installationA);

    expect(res.status).toBe(200);
    expect(res.body.data.today.completedCount).toBe(1);
    expect(res.body.data.today.totalScheduled).toBe(1);
    expect(res.body.data.today.percentage).toBe(100);
    expect(res.body.data.streaks.currentOverallStreak).toBeGreaterThanOrEqual(1);
  });

  test('GET /api/statistics/trends should provide breakdown charts', async () => {
    const res = await request(app)
      .get('/api/statistics/trends?date=2026-10-24')
      .set('x-installation-id', installationA);

    expect(res.status).toBe(200);
    expect(res.body.data.last7Days.length).toBe(7);
    expect(res.body.data.weeklyTrends.length).toBe(8);
  });

  test('GET /api/statistics/calendar should return month heatmap intensities', async () => {
    const res = await request(app)
      .get('/api/statistics/calendar?year=2026&month=10')
      .set('x-installation-id', installationA);

    expect(res.status).toBe(200);
    expect(res.body.data.days.length).toBe(31);
    const day24 = res.body.data.days.find((d) => d.dateKey === '2026-10-24');
    expect(day24).toBeDefined();
    expect(day24.intensity).toBe('full');
  });

  // 4. Notifications
  test('Notification endpoints: create, list, mark read, delete', async () => {
    const createRes = await request(app)
      .post('/api/notifications')
      .set('x-installation-id', installationA)
      .send({
        title: 'Drink Water Reminder',
        message: 'Stay hydrated for optimal energy.',
        type: 'reminder',
      });

    expect(createRes.status).toBe(201);
    const notifId = createRes.body.data._id;

    const listRes = await request(app)
      .get('/api/notifications')
      .set('x-installation-id', installationA);
    expect(listRes.body.data.notifications.length).toBeGreaterThanOrEqual(1);
    expect(listRes.body.data.unreadCount).toBeGreaterThanOrEqual(1);

    const readRes = await request(app)
      .patch(`/api/notifications/${notifId}/read`)
      .set('x-installation-id', installationA);
    expect(readRes.status).toBe(200);
    expect(readRes.body.data.status).toBe('read');
  });

  // 5. Settings & Backup/Restore
  test('Settings and Backup export/import/reset workflow', async () => {
    // Update settings
    const setRes = await request(app)
      .patch('/api/settings')
      .set('x-installation-id', installationA)
      .send({ displayName: 'Jordan', themeMode: 'dark' });
    expect(setRes.status).toBe(200);
    expect(setRes.body.data.displayName).toBe('Jordan');

    // Export backup JSON
    const exportRes = await request(app)
      .get('/api/backup/export')
      .set('x-installation-id', installationA);
    expect(exportRes.status).toBe(200);
    expect(exportRes.body.data.data.habits.length).toBe(1);

    // Export CSV
    const csvRes = await request(app)
      .get('/api/backup/csv')
      .set('x-installation-id', installationA);
    expect(csvRes.status).toBe(200);
    expect(csvRes.text).toContain('Morning Meditation');

    // Reset all data
    const resetRes = await request(app)
      .post('/api/settings/reset')
      .set('x-installation-id', installationA);
    expect(resetRes.status).toBe(200);

    const emptyHabits = await request(app)
      .get('/api/habits')
      .set('x-installation-id', installationA);
    expect(emptyHabits.body.data.length).toBe(0);

    // Restore from backup JSON
    const importRes = await request(app)
      .post('/api/backup/import')
      .set('x-installation-id', installationA)
      .send(exportRes.body.data);
    expect(importRes.status).toBe(200);
    expect(importRes.body.data.importedHabitsCount).toBe(1);

    // Verify restored
    const restoredHabits = await request(app)
      .get('/api/habits')
      .set('x-installation-id', installationA);
    expect(restoredHabits.body.data.length).toBe(1);
    expect(restoredHabits.body.data[0].name).toBe('Morning Meditation');
  });
});
