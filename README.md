# Copilot + mxcli for Mendix

A GitHub Copilot setup for Mendix projects edited through `mxcli`
(MDL scripts instead of hand-editing the binary `.mpr`).

```
.github/
  copilot-instructions.md          always loaded: rules, change loop, definition of done, common mistakes, skill map
  instructions/*.instructions.md   loaded only for matching files (*.mdl, *.test.mdl, custom code)
  skills/<~88 skills>/SKILL.md     loaded on demand (stock mxcli skills adapted for Copilot)
  prompts/*.prompt.md              slash commands: /explore /create-entity /create-crud /impact /review /fix-errors /add-tests
apply.ps1                          copy this setup into any Mendix project
scripts/build-full-skills.ps1      regenerates the skills from a project that ran `mxcli init`
SCORECARD.md                       test sheet
```

The skills are the stock mxcli skills, adapted for Copilot: BOM removed (it can stop VS Code recognising a skill),
`./mxcli` changed to `mxcli`, `sed -n` hints changed to "read only the line range", the Claude-only plugin left out,
and a skill map added to the instructions. Re-run `scripts/build-full-skills.ps1` after `mxcli init --sync-skills`
to refresh them. (An earlier lean variant with 13 condensed skills was replaced by this full set.)

## Use it

1. Put a Mendix project in this folder (or run `.\apply.ps1 -Project C:\path\to\App` to install into another one).
2. Open the folder in VS Code, Copilot Chat, **Agent** mode.
3. Work on a git branch. mxcli prints an "alpha quality" warning on every run.

Requires `mxcli` on PATH (`mxcli version`) and a GitHub Copilot plan with agent mode and skills support.
Skills and prompt files need a recent VS Code; if `/explore` does not appear, update VS Code and Copilot Chat.


## Pick the model yourself

mxcli work is hard for small models: MDL is niche, skills are long, and the agent must react to `mxcli check` errors.
Copilot's **Auto** mode can route to a cheaper model. For anything that changes the model, pick a strong model
manually in the Copilot Chat model picker (if your plan or admin policy allows it). Keep Auto or a cheaper model for
read-only work (`/explore`, `/impact`, `/review`). Model names and tiers change often; check GitHub's supported-models
page for your plan.

To confirm the instructions are loaded, ask: "Quote the Definition of done from your instructions." If it cannot,
the file is not reaching the model.

To compare tools or models fairly, run the same task from `SCORECARD.md` on the same project copy with each one.

## Keep improving it

- Add a line to **Common mistakes** in `.github/copilot-instructions.md` every time the agent gets MDL wrong.
- Encode team conventions as lint rules (`write-lint-rules` skill) instead of making the instructions longer.
- Keep your Unit Testing module tests for important logic; treat `/add-tests` (`.test.mdl`) as an experiment on a copy.
- Not included, optional: devcontainer, the mxcli VS Code extension, Playwright (`mxcli playwright`), the Mendix deploy MCP server.

## Why it is cheap

- The always-on file holds only rules and the command ladder; knowledge lives in skills that load on demand.
- `mxcli syntax <path>` replaces bundled references: always matches the installed version and is small.
- Wide-to-narrow exploration (`structure -d 1`, `list`, one `describe`) and `context` / `impact` / `refs` / `search`
  avoid dumping whole modules.
- Never reading `.mpr`, `mprcontents/`, `deployment/` avoids the biggest token sinks.
- check, diff, exec in small scripts surface errors before the write.

Copilot plans mostly meter by request and model multiplier, not raw tokens, so fewer agent steps matter as much as
short context. Check your plan's rules.

To measure instead of guess: run the same prompt before and after, compare the number of tool calls in the chat,
and look for a chat debug / "Show Chat Debug View" style command in the VS Code Command Palette (name varies by
version) to see what context was actually sent.

## Test prompts

Needs a project with at least one module. Run them in order; the first four change nothing.

**Read only**
1. `/explore` (scope: the whole app). Expect: `structure -d 1` first, a short summary, no `.mpr` reads.
2. "Which microflows touch the Customer entity, and which pages show it?" Expect: `context` or `refs`, not many `describe`s.
3. "Find where we show the text 'Welcome'." Expect: `mxcli search`.
4. `/impact` on an entity you use a lot. Expect: a table and a safe-rename plan, no changes.

**Small writes (do these on a branch)**
5. `/create-entity` Shop.Product with Name, Price, Active. Expect: `changes/*.mdl` starting `mdl 1;`, check, diff, exec, a lint result, access rules.
6. "Add a microflow ACT_Deactivate that sets Active to false on a Product and commits." Expect: it runs `mxcli syntax microflow.create` (or similar), not a guess.
7. "Add a unique constraint on Product Name." Expect: `ALTER`, not `CREATE OR MODIFY`.
8. Run the same script twice. Expect: the second `exec` reports no change.

**Bigger**
9. `/create-crud` for Shop.Product. Expect: overview and edit pages, access for existing roles, lint clean.
10. "Review my changes" or `/review`. Expect: `diff-local` plus `lint`, findings by severity, a commit verdict.

**Guardrail checks (should refuse or redirect)**
11. "Open ATLAS.mpr and change the entity name." Expect: refuses and uses MDL or `mxcli rename`.
12. "Add a microflow, but I do not know MDL syntax for loops." Expect: `mxcli syntax microflow.control-flow`.
13. Ask for something mxcli cannot do (for example "install a Marketplace module"). Expect: it says so or points to
    `mxcli marketplace`, rather than inventing commands.

## Known limits

- Built and checked against `mxcli` v0.28.0 (alpha). Command names and flags can change between releases; if a skill
  disagrees with `mxcli <cmd> --help`, trust the help and update the skill.
- Not exercised inside Copilot yet: syntax and commands were verified in a terminal, the Copilot behaviour was not.
- Skills come from the Claude-side skills that ship with mxcli v0.28.0, so they are long (median ~3.6k tokens); on a small model
  or a tight context they may be truncated or ignored. Always-on cost is higher than a lean setup (~7k tokens).
- Hooks, custom agents and the live Studio Pro MCP mode (`--mcp`) are not included.
