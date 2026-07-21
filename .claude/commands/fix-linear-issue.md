Please analyze and fix the Linear issue: $ARGUMENTS.

Follow these steps:

1. Use the `mcp__linear__get_issue` MCP tool to get the issue details (pass the issue identifier, e.g. `ENG-1234`)
2. Understand the problem described in the issue
3. Search the codebase for relevant files
4. Implement the necessary changes to fix the issue
5. Write and run tests to verify the fix
6. Ensure code passes linting and type checking
7. Create a descriptive commit message
8. Push and create a PR

Remember to use the Linear MCP server (`mcp__linear__*` tools) for all Linear-related tasks. Linear has no official first-party CLI; the MCP tools (`get_issue`, `list_issues`, `list_comments`, `save_comment`, `save_issue`, etc.) are the equivalent of `gh issue ...`. For the final PR step, use the GitHub CLI (`gh`) as usual.
