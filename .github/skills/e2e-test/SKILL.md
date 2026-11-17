---
name: e2e-test
description: Write one self-contained Playwright test for one Mendix page (run on demand with /e2e-test).
argument-hint: Module.Page_Name
disable-model-invocation: true
---
Use the `mendix-e2e-strategy` skill. The page is the user's argument (ask if missing). Write a Playwright (`@playwright/test`) test for it in `tests/<module>/`.
Look up the page's widget names with `mxcli describe` (use `.mx-name-*` selectors; if a needed widget has no name, say so instead of guessing).
The test must create its own data through the test API or existing published services (never SQL, never data that already exists),
use a run ID for unique names, and clean up in the fixture teardown. If the test API or fixtures do not exist yet, build only the smallest piece needed first and tell the user.
Run the test once and report the real result. Do not write more than one test until this one passes.
