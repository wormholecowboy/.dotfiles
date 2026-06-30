---
name: handoff
description: Create a handoff file prompting another agent to continue the work
disable-model-invocation: true
---

- Create a handoff file that explains to another agent what we need to do. It should be a prompt the other agent can red and execute
- Include any validation the other agent should do
- Place the file at the root of the Git repo and prepend it with `HANDOFF-`

Extra user context: $ARGUMENTS
