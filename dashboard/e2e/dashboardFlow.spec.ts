import { test, expect } from '@playwright/test';

test.describe('Dashboard E2E Flow', () => {
    test('User can login and view Heatmap', async ({ page }) => {
        // Navigate to Login
        await page.goto('http://localhost:5173/login');

        // Fill credentials using standard text locators or placeholders
        await page.fill('input[type="email"]', 'admin@heritage.et');
        await page.fill('input[type="password"]', 'password123');
        await page.click('button[type="submit"]');

        // Assert that we are redirected to the analytics overview after authentication
        await expect(page).toHaveURL(/.*\/analytics/);

        // Assert Overview stat cards exist
        await expect(page.locator('text=Total Scans')).toBeVisible();

        // Navigate to Heatmap
        await page.click('text=Heatmap');

        // Expect the map container to exist
        await expect(page.locator('.leaflet-container')).toBeVisible();

        // Check if the attribution exists representing map tiles loaded
        await expect(page.locator('text=OpenStreetMap')).toBeVisible();
    });
});
