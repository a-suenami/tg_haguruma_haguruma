import { test as base, Page } from '@playwright/test';

/**
 * Authentication helpers for E2E tests
 * Supports both bypass mode (CI) and real Auth0 login (staging/production)
 */

export interface AuthOptions {
  area: 'admin' | 'ruler';
  tenantId?: string;
}

/**
 * Authenticate using bypass mode (CI environment only)
 * Requires ALLOW_AUTH_BYPASS=true on the server
 */
async function authenticateWithBypass(page: Page, options: AuthOptions): Promise<void> {
  const { area, tenantId } = options;

  let bypassUrl: string;
  if (area === 'admin') {
    if (!tenantId) {
      throw new Error('tenantId is required for admin area authentication');
    }
    bypassUrl = `/test/auth/bypass?area=admin&tenant_id=${tenantId}`;
  } else {
    bypassUrl = '/test/auth/bypass?area=ruler';
  }

  // Navigate and wait for response
  const response = await page.goto(bypassUrl, { waitUntil: 'networkidle' });

  // Check if we got a redirect (successful auth) or an error
  const currentUrl = page.url();
  const expectedPattern = area === 'admin' ? /\/admin/ : /\/ruler/;

  if (!expectedPattern.test(currentUrl)) {
    // Auth bypass failed - get error details
    const status = response?.status() ?? 'unknown';
    const body = await page.content();

    // Try to extract error message from JSON response
    let errorMessage = `Auth bypass failed. Status: ${status}, URL: ${currentUrl}`;
    try {
      const jsonMatch = body.match(/"error"\s*:\s*"([^"]+)"/);
      if (jsonMatch) {
        errorMessage += `, Error: ${jsonMatch[1]}`;
      }
    } catch {
      // Ignore JSON parsing errors
    }

    throw new Error(errorMessage);
  }
}

/**
 * Authenticate using real Auth0 login
 * Requires TEST_USER_EMAIL and TEST_USER_PASSWORD environment variables
 */
async function authenticateWithAuth0(page: Page, options: AuthOptions): Promise<void> {
  const { area, tenantId } = options;

  const email = process.env.TEST_USER_EMAIL;
  const password = process.env.TEST_USER_PASSWORD;

  if (!email || !password) {
    throw new Error('TEST_USER_EMAIL and TEST_USER_PASSWORD must be set for real authentication');
  }

  // Navigate to login page
  if (area === 'admin') {
    if (!tenantId) {
      throw new Error('tenantId is required for admin area authentication');
    }
    // Admin area login - adjust URL pattern as needed
    await page.goto(`/admin/login`);
  } else {
    await page.goto('/ruler/login');
  }

  // Wait for Auth0 login form (Auth0 Universal Login)
  // Note: Adjust selectors based on your Auth0 configuration
  await page.waitForSelector('input[name="username"], input[name="email"], input[type="email"]', {
    timeout: 10000,
  });

  // Fill in credentials
  const emailInput = page.locator('input[name="username"], input[name="email"], input[type="email"]').first();
  await emailInput.fill(email);

  const passwordInput = page.locator('input[name="password"], input[type="password"]').first();
  await passwordInput.fill(password);

  // Submit the form
  const submitButton = page.locator('button[type="submit"], input[type="submit"]').first();
  await submitButton.click();

  // Wait for redirect back to the application
  await page.waitForURL(area === 'admin' ? '**/admin/**' : '**/ruler/**', {
    timeout: 30000,
  });
}

/**
 * Main authentication function
 * Automatically chooses bypass or real auth based on AUTH_BYPASS environment variable
 */
export async function authenticate(page: Page, options: AuthOptions): Promise<void> {
  const useBypass = process.env.AUTH_BYPASS === 'true';

  if (useBypass) {
    await authenticateWithBypass(page, options);
  } else {
    await authenticateWithAuth0(page, options);
  }
}

/**
 * Extended test fixture with authentication helpers
 */
type AuthFixtures = {
  authenticatedAdminPage: Page;
  authenticatedRulerPage: Page;
  authenticate: (options: AuthOptions) => Promise<void>;
};

export const test = base.extend<AuthFixtures>({
  /**
   * Helper function to authenticate with any options
   */
  authenticate: async ({ page }, use) => {
    await use(async (options: AuthOptions) => {
      await authenticate(page, options);
    });
  },

  /**
   * Pre-authenticated page for admin area
   * Requires TEST_TENANT_ID environment variable
   */
  authenticatedAdminPage: async ({ page }, use) => {
    const tenantId = process.env.TEST_TENANT_ID;
    if (!tenantId) {
      throw new Error('TEST_TENANT_ID must be set for admin area tests');
    }
    await authenticate(page, { area: 'admin', tenantId });
    await use(page);
  },

  /**
   * Pre-authenticated page for ruler area
   */
  authenticatedRulerPage: async ({ page }, use) => {
    await authenticate(page, { area: 'ruler' });
    await use(page);
  },
});

export { expect } from '@playwright/test';
