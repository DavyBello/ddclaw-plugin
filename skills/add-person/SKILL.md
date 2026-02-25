---
name: ddclaw:add-person
description: Add a new person to context/people/
argument-hint: <firstname-lastname>
---

Create a new person folder for $ARGUMENTS:

1. Create folder `context/people/$ARGUMENTS/`
2. Copy `context/people/_TEMPLATE.md` to `context/people/$ARGUMENTS/README.md`
3. Ask me for key details:
   - Role/Title
   - Team
   - Reporting relationship
   - Anything notable about working style
4. Fill in what I provide, leave the rest empty
5. Show me the created file
