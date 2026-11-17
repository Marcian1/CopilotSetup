---
name: impact
description: Show what breaks if a Mendix element is renamed or deleted (run on demand with /impact).
argument-hint: Module.Element
disable-model-invocation: true
---
Use `mendix-explore`. For the element in the user's argument (ask if missing) run `mxcli impact` and `mxcli refs`.
Answer in a table: referencing element, type, what would break. End with a safe plan (rename with `mxcli rename`, not by hand).
Do not change anything.
