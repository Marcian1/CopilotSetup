---
applyTo: "**/*.test.mdl,**/*.test.md"
---
Test file rules (mxcli test, alpha):
- One `@test` per block; a block ends with a line containing only `/`. A second `@test` in one block is silently dropped.
- Validate with `mxcli check <file>` before running anything. Bad `@expect` / `@verify` shows as MDL-TEST01.
- Test the microflow, not the page. Assert on returned values and committed data, not log text.
- Flows using `[%CurrentUser%]` fail under test: pass the user as a parameter.
- Do not `head()` a `retrieve ... first` result.
- Full details: the `test-microflows` skill.
