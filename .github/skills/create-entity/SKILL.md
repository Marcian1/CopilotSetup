---
name: create-entity
description: Add an entity with attributes and security via a checked MDL script (run on demand with /create-entity).
argument-hint: Module.Entity with attributes, e.g. Shop.Product Name String(200), Active Boolean
disable-model-invocation: true
---
Use the `mendix-write-mdl` skill. Create the entity and attributes given as the user's argument (ask if missing; default attributes: `Name String(200), Active Boolean`).
Include access rules for the roles that already exist in that module (look them up, do not invent roles).
Follow the loop: script in `changes/`, check, diff, exec, describe, lint. Report only the result and lint status.
