---
description: (Experimental) Generate .test.mdl tests for a microflow
agent: agent
---
Use the `mendix-testing` skill. Write `tests/${input:name:MicroflowName}.test.mdl` for the microflow `${input:microflow:Module.Microflow}`.
Read it with `mxcli describe`, then cover: the normal path, each branch, empty input, validation failure, error handler.
One `@test` per block, each block ends with a line containing only `/`. Run `mxcli check` on the file and fix errors.
Only run `mxcli test` if I say a runtime is available. This feature is alpha: say clearly what was and was not verified.
Existing Unit Testing module tests are not replaced by this.
