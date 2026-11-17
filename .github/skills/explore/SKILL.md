---
name: explore
description: Summarise the Mendix app or one module cheaply (run on demand with /explore).
argument-hint: whole app, or a module name
disable-model-invocation: true
---
Use the `mendix-explore` skill. Give a short overview of the scope in the user's argument (default: the whole app).
Start with `mxcli structure -d 1`. Only go deeper on modules that matter for the overview.
Finish with: main entities, key microflows, main pages, and anything odd. Max 15 lines.
