import { test, expect } from '../../fixtures/auth';

test.describe('Admin Area Smoke Tests', () => {
  test('should access admin dashboard after authentication', async ({ authenticatedAdminPage }) => {
    const page = authenticatedAdminPage;

    // Should be on the admin area
    await expect(page).toHaveURL(/\/admin/);

    // Page should have loaded successfully
    await expect(page.locator('body')).toBeVisible();
  });

  test('should display dashboard content', async ({ authenticatedAdminPage }) => {
    const page = authenticatedAdminPage;

    // Wait for page to fully load
    await page.waitForLoadState('networkidle');

    // Dashboard should be visible
    // Adjust these assertions based on your actual UI
    await expect(page.locator('body')).toBeVisible();
  });
});
