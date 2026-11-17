---
name: mendix-e2e-strategy
description: Plan and write a full end-to-end test suite for a Mendix app with Playwright (@playwright/test) where every test creates its own data and runs on any database. Covers test layers, data-creation options, a guarded test API, run IDs and cleanup, folder layout, module tests vs journeys, and Mendix-specific Playwright rules. Use when asked to test the app fully, set up Playwright tests, make tests database independent, or write an E2E test for a page.
---
# Mendix E2E strategy with Playwright

For "does this page render?" use `mxcli playwright check` (skill `test-app`). For microflow logic use `mxcli test` or the Unit Testing module (skill `test-microflows`). This skill is for the real suite: `@playwright/test` (TypeScript), run with `npx playwright test`.

## The one rule
A test creates the data it needs, uses it, and removes it. It never assumes a row already exists. Never write SQL and never seed with `demo-data` for tests: that skips microflows and validations and ties the suite to one database type.

## Layers (do not mix)
| Layer | Tool | Covers |
|---|---|---|
| Logic | `mxcli test` / Unit Testing module | validations, branches, calculations. Playwright cannot replace these |
| Smoke | `mxcli playwright check` | every page renders, no error banner |
| Module tests (most) | Playwright | one module's screens and rules |
| Journeys (5 to 10) | Playwright, tagged `@journey @critical` | a real flow across modules, start to end |

## Where test data comes from (in this order)
1. **A guarded test API in the app** (published REST or OData): `POST /test/<thing>` creates via the real microflows, `DELETE /test/run/<runId>` removes everything tagged with that run ID. Playwright's `request` fixture calls it: one fast HTTP call, real logic.
2. **The UI**, only for the flow under test. Slow and brittle, so never for prerequisites.
3. **Never** the database directly.

Test API rules (the app, built with mxcli; review the output, mxcli is alpha):
- Guard every endpoint with a constant `EnableTestApi` (default `false`; `true` only in dev/test). When off, return 404.
- Require a secret header from a constant, never a hard-coded value. Never deploy the endpoints enabled to production.
- Store the run ID on created objects (a `TestRunId` attribute, or encode it in the name) so cleanup is exact.
- Unsure whether mxcli can publish the service? Run `mxcli syntax integration` (and `mxcli syntax odata` / `rest`) and try ONE small endpoint with `mxcli check`. If it cannot, build the endpoints once in Studio Pro and let mxcli do the rest.
- If the app already has published REST or OData services, use those first; add endpoints only where tests are slow.

## Make data unique and clean
- One run ID per test run: `const runId = process.env.RUN_ID ?? Date.now().toString(36)`. Add a short random suffix per object: `Customer_${runId}_a8f3`. Parallel tests then never collide.
- Create data in a fixture and delete it in the fixture teardown, even when the test fails.
- Baseline data (user roles, config constants, lookup lists) is seeded **once per run** in a Playwright `setup` project, not in each test.
- Complex data: write scenario helpers (`createSupplierWithOpenRequest()`) on top of the small ones.

## Layout
```
tests/
  helpers/        api.ts (test-API client), data.ts (create/cleanup), pages/ (page objects)
  fixtures.ts     test.extend: runId, api, auto-cleanup
  auth.setup.ts   logs in once per role, saves storageState
  <module>/       one folder per Mendix module, owned by that module's team
  journeys/       the few cross-module flows
playwright.config.ts
```
Share setup, not tests. A module's tests create what they need through the API, never by clicking through another module's screens, so an unrelated bug cannot fail them. Test an external system (e.g. Content Server) in its own module folder, and use it once in a journey; mock it elsewhere (skill `mock-rest-apis`).

## Config and login
```ts
// playwright.config.ts
export default defineConfig({
  testDir: './tests',
  fullyParallel: true,
  use: { baseURL: process.env.BASE_URL ?? 'http://localhost:8080', trace: 'retain-on-failure' },
  projects: [
    { name: 'setup', testMatch: /auth\.setup\.ts/ },
    { name: 'app', dependencies: ['setup'], use: { storageState: '.auth/user.json' } },
  ],
});
```
Log in once in `auth.setup.ts`, save `storageState`, one file per role. Credentials come from environment variables, never from the repo. Do not log in through the UI in each test.
```ts
setup('login', async ({ page }) => {
  await page.goto('/login.html');
  await page.locator('#usernameInput').fill(process.env.MX_USER!);
  await page.locator('#passwordInput').fill(process.env.MX_PASSWORD!);
  await page.locator('#loginButton').click();
  await page.waitForURL((u) => !u.pathname.includes('login'));   // wait for the app, then save the session
  await page.context().storageState({ path: '.auth/user.json' });
});
```
Add `.auth/` to `.gitignore`. Reference selectors, dropdowns and date pickers are custom Mendix widgets, not native `<select>`/`<input type=date>`: click the widget, then pick the option by role or text; do not use `selectOption`.

```ts
// fixtures.ts
export const test = base.extend<{ runId: string; api: Api }>({
  runId: async ({}, use) => use(`${process.env.RUN_ID ?? 'r'}${Math.random().toString(36).slice(2, 6)}`),
  api: async ({ request, runId }, use) => {
    const api = new Api(request, runId);
    await use(api);
    await api.cleanup();          // runs even when the test fails
  },
});

// tests/orders/create-order.spec.ts
test('create an order', { tag: '@orders' }, async ({ page, api }) => {
  const customer = await api.createCustomer();       // own data, via the test API
  await page.goto('/p/Order_NewEdit');
  await page.locator('.mx-name-txtCustomerName input').fill(customer.name);   // widget name + inner input
  await page.locator('.mx-name-btnSave').click();
  await expect(page.locator('.mx-name-dgOrders')).toContainText(customer.name);
});
```
Run a subset: `npx playwright test tests/orders` or `--grep @journey`.

## Mendix-specific rules
- Select by widget name: `page.locator('.mx-name-<widgetName>')`. Name every widget in MDL (skill `create-page`); never select by layout, position or caption text. Item in a navigation list: `.mx-name-text_<item>`. Data grid data rows: `[role=row]:has([role=gridcell])`.
- Never `waitForLoadState('networkidle')`: Mendix keeps a long-polling request open. Wait for an element (`expect(locator).toBeVisible()`).
- Use Playwright's auto-waiting and web-first `expect`. No `waitForTimeout`.
- With security off, `/p/<Page>` URLs redirect home; navigate through named widgets. With security on, direct URLs work after login.
- Top-navigation clicks can be intercepted by `div.mx-placeholder`; dispatch the click event on that element.
- Assert persisted data through the UI or the test API, not SQL.

## Database independence, honestly
Tests that go through the app run on any supported database. Still, sorting, case-sensitive search and some XPath can differ by database type. Run the suite on your real target database in CI now and then, even if you develop on the built-in one.

## Working with the agent
1. Build the test API and the fixtures first (one endpoint, one helper), then write ONE test for ONE screen and get it passing.
2. Only then repeat the pattern per page or module. Use the `/e2e-test` prompt.
3. Reproduce a failure with `npx playwright test --trace on`, then `npx playwright show-trace`. Prefer text output (list reporter) over screenshots to save tokens.
4. Do not claim the suite passes unless you ran it; report what was and was not run.

## Related skills
`test-app` (smoke checks), `test-microflows` (logic), `mock-rest-apis`, `create-page` (widget names), `rest-client`, `odata-data-sharing`, `manage-security` (roles for test users), `run-local`.
