import { defineConfig, devices } from '@playwright/test';

/**
 * Playwright configuration for E2E tests
 * @see https://playwright.dev/docs/test-configuration
 */
export default defineConfig({
  testDir: './tests',

  /* Run tests in files in parallel */
  fullyParallel: true,

  /* Fail the build on CI if you accidentally left test.only in the source code */
  forbidOnly: !!process.env.CI,

  /* Retry on CI only */
  retries: process.env.CI ? 2 : 0,

  /* Opt out of parallel tests on CI */
  workers: process.env.CI ? 1 : undefined,

  /* Reporter to use */
  reporter: [
    ['html', { outputFolder: 'playwright-report' }],
    ['list'],
  ],

  /* Shared settings for all the projects below */
  use: {
    /* Base URL to use in actions like `await page.goto('/')` */
    baseURL: process.env.BASE_URL || 'http://localhost:3000',

    /* Collect trace when retrying the failed test */
    trace: 'on-first-retry',

    /* Capture screenshot on failure */
    screenshot: 'only-on-failure',

    /* Video recording on failure */
    video: 'on-first-retry',
  },

  /* Configure projects for different environments */
  projects: [
    /* CI environment - auth bypass enabled */
    {
      name: 'ci',
      use: {
        ...devices['Desktop Chrome'],
      },
      testMatch: /.*\.spec\.ts/,
    },

    /* Staging environment - real auth */
    {
      name: 'staging',
      use: {
        ...devices['Desktop Chrome'],
        baseURL: process.env.STAGING_URL || 'https://staging.example.com',
      },
      testMatch: /.*\.spec\.ts/,
    },

    /* Production environment - smoke tests only */
    {
      name: 'production',
      use: {
        ...devices['Desktop Chrome'],
        baseURL: process.env.PRODUCTION_URL || 'https://example.com',
      },
      testMatch: /smoke\/.*\.spec\.ts/,
    },
  ],

  /* Run your local dev server before starting the tests (CI only) */
  webServer: process.env.CI ? {
    command: 'bin/rails server -p 3000',
    url: 'http://localhost:3000/health_check',
    reuseExistingServer: !process.env.CI,
    timeout: 120 * 1000,
  } : undefined,
});
