---
name: ddclaw:add-project
description: Add a new project to context/projects/
disable-model-invocation: false
argument-hint: <project-name>
---

Create a new project folder for "$ARGUMENTS":

1. Create folder `context/projects/$ARGUMENTS/`
2. Copy `context/projects/_TEMPLATE.md` to `context/projects/$ARGUMENTS/README.md`
3. Ask me for:
   - One-line description
   - Status (active/paused/blocked)
   - Key people involved
   - Current priority items
4. Fill in what I provide, leave the rest empty
5. Add the project to `context/projects/README.md` under the appropriate status section (Active/Blocked/Paused) in alphabetical order, format: `- \`$ARGUMENTS/\` — <one-line description>`
6. Show me the created file
