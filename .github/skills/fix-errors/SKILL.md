---
name: fix-errors
description: Fix mxcli check, lint or build errors with the smallest change (run on demand with /fix-errors).
argument-hint: paste the error text, or a changes/<file>.mdl to check
disable-model-invocation: true
---
Use the `cheatsheet-errors` skill (then `check-syntax` if the error is MDL parsing). The errors are the user's argument; if it is a file, run `mxcli check` on it first.
Look up each code in the skill, run `mxcli syntax <topic>` for the construct involved, and make the smallest fix.
Re-run `mxcli check`, then `mxcli lint`. Stop after 3 failed attempts at the same error and report it with what you tried.
Report: error code, cause, the fix, final check/lint status.
