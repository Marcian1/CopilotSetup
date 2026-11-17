# Copilot + mxcli for Mendix

A GitHub Copilot setup for Mendix projects edited with [`mxcli`](https://github.com/mendixlabs/mxcli).

## Use it

1. Copy the `.github` folder into the root of your Mendix project (next to the `.mpr`).
2. Open the project in VS Code and use Copilot Chat in **Agent** mode.
3. Work on a git branch. mxcli is alpha software.

Requires `mxcli` on your PATH (`mxcli version`) and a Copilot plan with agent mode and skills.
If the project also has a `.claude/skills` folder (written by `mxcli init`), delete it: VS Code scans it too and the skills would load twice.

## What is in `.github`

| Path | What it does |
|---|---|
| `copilot-instructions.md` | Always loaded: rules, the change loop (check, diff, exec, lint), definition of done, common mistakes |
| `instructions/` | Extra rules loaded only for `*.mdl` and `*.test.mdl` files |
| `skills/` | About 87 skills, loaded on demand when the task matches |

### Slash commands
`/explore` `/create-entity` `/create-crud` `/impact` `/review` `/fix-errors` `/add-tests` `/e2e-test`

### Testing
- `test-app`: quick "does this page render" checks (`mxcli playwright check`).
- `mendix-e2e-strategy`: a full Playwright suite where every test creates its own data and runs on any database.
- `test-microflows`: microflow logic tests (`mxcli test`).

## Tips

- **Pick a strong model yourself** in the Copilot model picker. Auto can route to a small model, which does badly with MDL and long skills.
- **Check the instructions load:** ask "Quote the Definition of done from your instructions."
- **Add a line to "Common mistakes"** in `copilot-instructions.md` every time the agent gets MDL wrong.
- Keep your Unit Testing module tests for important logic; treat `.test.mdl` as experimental.
