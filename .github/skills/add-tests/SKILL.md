---
name: add-tests
description: Generate .test.mdl tests for one microflow (experimental, run on demand with /add-tests).
argument-hint: Module.Microflow to test
disable-model-invocation: true
---
Use the `test-microflows` skill. The microflow to test is the user's argument (ask if missing). Write `tests/<MicroflowName>.test.mdl`.
Read the microflow with `mxcli describe`, then cover: the normal path, each branch, empty input, validation failure, error handler.
One `@test` per block, each block ends with a line containing only `/`. Run `mxcli check` on the file and fix errors.
Only run `mxcli test` if the user says a runtime is available. This feature is alpha: say clearly what was and was not verified.
Existing Unit Testing module tests are not replaced by this.
