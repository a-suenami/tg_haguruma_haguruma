import { test, expect } from '../../fixtures/auth';

test.describe('Ruler Area Smoke Tests', () => {
  test('should access ruler dashboard after authentication', async ({ authenticatedRulerPage }) => {
    const page = authenticatedRulerPage;

    // Should be on the ruler area root (tenants index)
    await expect(page).toHaveURL(/\/ruler/);

    // Page should have loaded successfully (check for common elements)
    // Adjust selectors based on your actual UI
    await expect(page.locator('body')).toBeVisible();
  });

  test('should display tenant list', async ({ authenticatedRulerPage }) => {
    const page = authenticatedRulerPage;

    // Navigate to tenants page (should be the root)
    await page.goto('/ruler');

    // Wait for page to load
    await page.waitForLoadState('networkidle');

    // Should see the tenants page content
    // Adjust these assertions based on your actual UI
    await expect(page.locator('body')).toBeVisible();
  });
});
