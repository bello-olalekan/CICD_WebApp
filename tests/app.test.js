// tests/app.test.js
const request = require('supertest');
const app = require('../app');

describe('API Endpoints', () => {
  test('GET /api/status returns correct response', async () => {
    const response = await request(app).get('/api/status');
    expect(response.statusCode).toBe(200);
    expect(response.body).toHaveProperty('status', 'ok');
    expect(response.body).toHaveProperty('timestamp');
  });
});

// In your test file
let server;

beforeAll(() => {
  // Start your server
  server = app.listen(3000);
});

afterAll((done) => {
  // Close the server
  server.close(done);
});