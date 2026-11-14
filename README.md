# Copilot + mxcli for Mendix

A lean GitHub Copilot setup for Mendix projects edited through `mxcli`
(MDL scripts instead of hand-editing the binary `.mpr`).

```
.github/
  copilot-instructions.md        always loaded, ~500 tokens
  instructions/mdl.instructions.md   loaded only when a *.mdl file is in play
  skills/mendix-explore|write-mdl|review/SKILL.md   loaded on demand (~55-token description each)
  prompts/*.prompt.md            slash commands: /explore /create-entity /create-crud /impact /review
apply.ps1                        copy the setup into any Mendix project
```

## Use it

1. Put a Mendix project in this folder (or run `.\apply.ps1 -Project C:\path\to\App` to install into another one).
2. Open the folder in VS Code, Copilot Chat, **Agent** mode.
3. Work on a git branch. mxcli prints an "alpha quality" warning on every run.

Requires `mxcli` on PATH (`mxcli version`) and a GitHub Copilot plan with agent mode and skills support.
Skills and prompt files need a recent VS Code; if `/explore` does not appear, update VS Code and Copilot Chat.

## Why it is cheap

| Choice | Effect |
|---|---|
| Always-on file is ~500 tokens | Every request pays for it, so it only holds rules and the command ladder |
| Knowledge in skills, not instructions | Copilot sees ~55 tokens per skill and reads the body only when the task matches |
| `mxcli syntax <path>` instead of bundled references | The stock `mxcli init` writes ~1.6 MB of `.ai-context/` and 25-150 KB skills; a syntax page is 0.6-1 KB, always matches the installed version, and cannot go stale |
| Wide-to-narrow exploration (`structure -d 1` -> `list` -> one `describe`) | Avoids dumping a whole module to answer one question |
| `context`, `impact`, `refs`, `search` | One call returns relationships that would otherwise take many `describe` calls |
| Never read `.mpr`, `mprcontents/`, `deployment/` | Binary and generated files are the biggest token sinks |
| check -> diff -> exec in small scripts | Errors surface in short messages before the write; no long repair loops |
| Short prompt files with `${input:...}` | Same task, same wording, no re-explaining |

Billing note: Copilot plans mostly meter by request and by model multiplier, not by raw tokens, so fewer agent
steps and a cheaper model for read-only work (`/explore`, `/impact`, `/review`) matter as much as short context.
Check your plan's rules. Reserve the stronger model for `/create-crud` and anything multi-module.

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
- Custom code (pluggable widgets, Java, JS actions) is out of scope for this version.
- Hooks, custom agents and the live Studio Pro MCP mode (`--mcp`) are not included.
