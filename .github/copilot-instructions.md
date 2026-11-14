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

## Conventions
- Names: entities PascalCase singular; microflows `ACT_` (button), `SUB_` (helper), `DS_` (data source), `VAL_` (validation); pages `Entity_Overview` / `Entity_NewEdit`.
- Every persistent entity needs access rules and every page needs allowed roles.
- Microflow variables start with `$`. Escape a single quote by doubling it.
- Say which module you will touch before changing anything outside it.
- Custom code (widgets, Java, JS) has its own rules in `.github/instructions/`; use the matching skill in `.github/skills/`.
