---
description: Fix mxcli check / lint / build errors with the smallest change
agent: agent
---
Use the `mendix-errors` skill (then `check-syntax` if the error is MDL parsing). Take the errors from `${input:errors:paste the error text, or write "run check on changes/<file>.mdl"}`.
Look up each code in the skill, run `mxcli syntax <topic>` for the construct involved, and make the smallest fix.
Re-run `mxcli check`, then `mxcli lint`. Stop after 3 failed attempts at the same error and report it with what you tried.
Report: error code, cause, the fix, final check/lint status.
