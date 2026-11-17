# Scorecard

Run the same prompts on the same project copy for each setup, model or tool you compare (for example Copilot with different models,
or before/after a change to the instructions), a fresh chat for each row, so nothing carries over.

For each prompt record:
- **Steps**: number of tool calls / terminal commands Copilot made (count them in the chat).
- **Check**: did `mxcli check <script> -p <app>.mpr` pass on its first try? (Y/N)
- **Lint**: new `mxcli lint` findings caused by the change (count).
- **Right**: does it do what you asked, in the way you would have done it? (0 wrong, 1 partly, 2 right)
- **Skills read**: which SKILL.md files it opened (shown in the chat's referenced files).
- **Notes**: wrong guesses, invented syntax, looping, anything surprising.

| # | Prompt | A steps | A check | A lint | A right | B steps | B check | B lint | B right | Notes |
|---|---|---|---|---|---|---|---|---|---|---|
| 1 | `/explore` whole app | | | | | | | | | |
| 2 | Which microflows touch Customer, which pages show it? | | | | | | | | | |
| 3 | Find where we show the text "Welcome" | | | | | | | | | |
| 4 | `/impact` on a busy entity | | | | | | | | | |
| 5 | `/create-entity` Shop.Product (Name, Price, Active) | | | | | | | | | |
| 6 | Microflow ACT_Deactivate for Product | | | | | | | | | |
| 7 | Add unique constraint on Product Name | | | | | | | | | |
| 8 | Run the same script twice (2nd exec must change nothing) | | | | | | | | | |
| 9 | `/create-crud` Shop.Product | | | | | | | | | |
| 10 | `/review` my changes | | | | | | | | | |
| 11 | "Open the .mpr and rename an entity" (should refuse) | | | | | | | | | |
| 12 | Loop with early exit in a microflow (unknown syntax) | | | | | | | | | |
| 13 | Something mxcli cannot do (should say so) | | | | | | | | | |

Extra prompts where B should have an edge (areas A does not cover):
| # | Prompt | A right | B right | Notes |
|---|---|---|---|---|
| 14 | Create a Java action that returns a string and call it from a microflow | | | |
| 15 | Publish an OData service for Product | | | |
| 16 | Add a pluggable widget to a page | | | |
| 17 | Run the app locally and tell me the URL | | | |
| 18 | Add a scheduled event that deletes old orders nightly | | | |

## Reading the result
- B clearly better on 14-18 only: keep A as default and add just those skills to it.
- B better on 5-12 as well: the condensed skills lose something; restore detail where B did better.
- Same quality, B uses more steps or slower: keep A (the extra context costs more and adds nothing).
- A better on 11-13: the skill map or the many descriptions are confusing the model; trim B.