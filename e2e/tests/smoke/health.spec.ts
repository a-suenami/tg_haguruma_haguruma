import { test, expect } from '@playwright/test';

test.describe('Health Check', () => {
  test('should return 200 on health check endpoint', async ({ request }) => {
    const response = await request.get('/health_check');

    expect(response.status()).toBe(200);
  });

  test('should load API docs page', async ({ page }) => {
    await page.goto('/api-docs');

    // Swagger UI should be loaded
    await expect(page).toHaveTitle(/Swagger/i);
  });
});
