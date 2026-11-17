---
name: create-crud
description: Build Overview and NewEdit pages with save/delete flow for an existing entity (run on demand with /create-crud).
argument-hint: Module.Entity
disable-model-invocation: true
---
Use `mendix-explore` then `mendix-write-mdl`. The entity is the user's argument (ask if missing). Build CRUD for the existing entity:
a `<Entity>_Overview` page (data grid, New and Edit buttons), a `<Entity>_NewEdit` page (form, Save, Cancel),
and page access for the roles that can read the entity. Reuse an existing layout from the project; run
`mxcli syntax page.create` and `mxcli syntax page.datasource` rather than guessing. Check, diff, exec, lint.
