# Mendix project (edited with mxcli)

The Mendix model lives in a binary `.mpr`. Never open or edit `.mpr`, `mprcontents/`, `deployment/`,
`.mendix-cache/` or `.ai-context/`. Read and change the model only with `mxcli` (on PATH) using MDL,
a SQL-like text language. `mxcli` auto-detects the single `.mpr` in the working folder; otherwise pass `-p <file>.mpr`.

## Spend few tokens
- Look before you read: `mxcli structure -d 1`, then `mxcli -c "list entities in <Module>"`, then ONE `mxcli describe <Module.Element>`.
- Relationships: `mxcli context <Module.Element>`, `mxcli impact`, `mxcli refs`, `mxcli search "<text>"`. Do not describe things one by one to find them.
- Syntax: run `mxcli syntax <topic>` (domain-model, microflow, page, security, navigation, workflow, integration, errors) and drill down with more words. Do not guess syntax and do not read big reference files.
- Summarise command output; do not paste it back.

## Changing the model (always this order)
1. Write a small `.mdl` script. First line `mdl 1;`, every statement ends with `;`.
2. `mxcli check script.mdl -p <app>.mpr` and fix every error.
3. `mxcli diff script.mdl -p <app>.mpr` and read what would change.
4. `mxcli exec script.mdl -p <app>.mpr`, then `mxcli describe` the result. Running it again must change nothing.
5. `mxcli lint` for conventions and security.

mxcli is alpha quality: stay on a git branch, keep scripts small (one concern each), never batch unrelated changes.

## Definition of done (do not say "done" before this)
- `mxcli check` passes, the second `exec` changes nothing, and `mxcli lint` shows no new findings.
- If a step fails, fix and rerun from step 2. After 3 failed attempts at the same error, stop and report the error and what you tried; do not improvise around it.
- Final answer: what changed (a few lines), the check/lint result, anything left undone. Never claim a check passed that you did not run.
- Before a large change, confirm `git status` is clean on a working branch; commit after each small script so a bad `exec` can be reverted.

## Common mistakes (add a line each time MDL goes wrong)
- Guessing syntax or keywords: run `mxcli syntax <topic>` instead.
- `AS` in attribute declarations (`Name: String(200)` is correct).
- `CREATE OR MODIFY` on an existing element: it drops anything the statement omits. Use `ALTER`.
- Unqualified names: always `Module.Element`.
- Missing `mdl 1;` header or a missing `;`.
- Inventing roles or modules: look them up first.
- Reading or editing `.mpr` / `mprcontents/` directly.

## Conventions
- Names: entities PascalCase singular; microflows `ACT_` (button), `SUB_` (helper), `DS_` (data source), `VAL_` (validation); pages `Entity_Overview` / `Entity_NewEdit`.
- Every persistent entity needs access rules and every page needs allowed roles.
- Microflow variables start with `$`. Escape a single quote by doubling it.
- Say which module you will touch before changing anything outside it.

## MDL and test files (these also load as scoped rules, repeated here in case they do not)
- `.mdl` files: `mdl 1;` on line 1, each statement ends with `;`, qualified names, re-runnable (`IF NOT EXISTS`), `mxcli fmt` before showing.
- `.test.mdl`: one `@test` per block, block ends with a line containing only `/`; validate with `mxcli check` first.

## Skills
Skills load on demand from their descriptions; read ONE, and only the line range you need (each opens with a "Find it fast" table). Syntax questions: `mxcli syntax <path>` first.
- Start here: `mendix-explore` (understand), `mendix-write-mdl` (change loop), `mendix-review` (before commit). Security: read `manage-security`'s System-module ceiling first. Project notes: `docs/brain/project.md` via `project-brain` if it exists.
- Browser tests: `test-app` for quick page checks, `mendix-e2e-strategy` for a full Playwright suite with self-supplied data. Logic tests: `test-microflows`.
- Rare skills (migrations, bootstrap, narrated demos, BSON debugging, live Studio Pro edit) are not auto-loaded: invoke them by name with `/`.
- Slash commands: `/explore /create-entity /create-crud /impact /review /fix-errors /add-tests /e2e-test`.
