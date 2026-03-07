# Excessive LLM Agency

OWASP Top 10 for LLMs #8: Excessive Agency

When LLM agents have too many permissions or access to dangerous tools without proper constraints, attackers can manipulate them to perform unauthorized actions.

---

## Vulnerabilities to Detect

### Overpowered Tool Access

#### Unrestricted Shell Access
```python
# VULNERABLE - Agent can run any shell command
tools = [
    {
        "name": "run_command",
        "description": "Run any shell command",
        "function": lambda cmd: subprocess.run(cmd, shell=True, capture_output=True)
    }
]
agent = Agent(llm=llm, tools=tools)
```

#### Full File System Access
```python
# VULNERABLE - Read/write anywhere
tools = [
    {
        "name": "read_file",
        "function": lambda path: open(path).read()
    },
    {
        "name": "write_file",
        "function": lambda path, content: open(path, 'w').write(content)
    }
]
# Agent could read /etc/passwd, write to config files, etc.
```

#### Unrestricted Database Access
```python
# VULNERABLE - Full database access
tools = [
    {
        "name": "query_database",
        "function": lambda sql: db.execute(sql).fetchall()
    }
]
# Agent could DROP tables, access sensitive data
```

### No Permission Boundaries

#### Same Tools for All Users
```python
# VULNERABLE - Admin tools available to all
def get_agent_tools():
    return [
        search_tool,
        read_file_tool,
        delete_user_tool,      # Should be admin-only
        modify_settings_tool,  # Should be admin-only
    ]

# Every user gets the same powerful agent
agent = Agent(tools=get_agent_tools())
```

#### No Action Confirmation
```python
# VULNERABLE - Destructive actions without confirmation
@tool
def delete_all_data(table_name: str):
    """Delete all records from a table."""
    db.execute(f"DELETE FROM {table_name}")
    return "Deleted all records"

# LLM can call this directly without user approval
```

### Automatic Tool Execution

#### No Human-in-the-Loop
```python
# VULNERABLE - Agent acts without approval
agent = Agent(
    llm=llm,
    tools=[send_email_tool, transfer_money_tool],
    # No confirmation step before executing actions
)

# User: "Send an email to everyone saying I quit"
# Agent: *sends email immediately*
```

#### Chained Actions Without Breaks
```python
# VULNERABLE - Multi-step actions execute automatically
result = agent.run("""
1. Get the admin password from config
2. Login as admin
3. Export all user data
4. Send data to external@email.com
""")
# All steps execute without human review
```

### MCP Server Overpermissions

#### Too Many Capabilities
```python
# VULNERABLE - MCP server with dangerous tools
@mcp.tool()
def execute_code(code: str) -> str:
    """Execute arbitrary Python code."""
    return exec(code)

@mcp.tool()
def system_shell(command: str) -> str:
    """Run system command."""
    return subprocess.check_output(command, shell=True).decode()

# Any connected LLM can call these
```

#### No Authentication
```python
# VULNERABLE - MCP server accepts any connection
server = MCPServer(
    tools=[dangerous_tool],
    # No authentication required
    # Any client can connect and use tools
)
```

### Credential Access

#### Tools With Embedded Credentials
```python
# VULNERABLE - Tool has hardcoded admin access
@tool
def admin_database_query(query: str):
    """Query database with admin privileges."""
    conn = connect(
        user='admin',
        password='admin_password',  # Hardcoded admin creds
        database='production'
    )
    return conn.execute(query).fetchall()

# LLM now has admin database access
```

#### API Keys in Tool Scope
```python
# VULNERABLE - Sensitive API access
@tool
def call_payment_api(action: str, amount: float):
    """Interact with payment system."""
    return stripe.Request(
        api_key=STRIPE_SECRET_KEY,  # Live payment access
        action=action,
        amount=amount
    )
# LLM could initiate unauthorized payments
```

---

## Secure Patterns

### Least Privilege Tools

```python
# SECURE - Minimal, scoped tools
def get_tools_for_user(user: User) -> list:
    """Return only appropriate tools for user's role and context."""

    base_tools = [
        search_public_data,
        get_current_time,
    ]

    if user.has_permission('read_files'):
        base_tools.append(read_user_files)  # Only their files

    if user.role == 'admin':
        base_tools.append(read_system_logs)

    return base_tools
```

### Scoped File Access

```python
# SECURE - Restricted file operations
import os
from pathlib import Path

USER_DATA_DIR = Path('/app/user_data')

@tool
def read_file(user_id: str, filename: str) -> str:
    """Read a file from user's directory only."""
    # Sanitize filename
    safe_name = "".join(c for c in filename if c.isalnum() or c in '.-_')

    # Construct path within user's directory
    user_dir = USER_DATA_DIR / user_id
    target = (user_dir / safe_name).resolve()

    # Verify path is within allowed directory
    if not str(target).startswith(str(user_dir)):
        raise PermissionError("Access denied: path traversal detected")

    if not target.exists():
        raise FileNotFoundError(f"File not found: {safe_name}")

    return target.read_text()
```

### Restricted Database Access

```python
# SECURE - Read-only, limited tables
ALLOWED_TABLES = {'products', 'categories', 'public_reviews'}

@tool
def query_database(table: str, filters: dict) -> list:
    """Query allowed tables with filters (no raw SQL)."""

    if table not in ALLOWED_TABLES:
        raise PermissionError(f"Table not accessible: {table}")

    # Build query safely using ORM
    model = get_model_for_table(table)
    query = model.query

    for field, value in filters.items():
        if field not in model.QUERYABLE_FIELDS:
            continue
        query = query.filter(getattr(model, field) == value)

    return [row.to_dict() for row in query.limit(100).all()]
```

### Human-in-the-Loop

```python
# SECURE - Require confirmation for sensitive actions
class ConfirmationRequired(Exception):
    def __init__(self, action: str, details: dict):
        self.action = action
        self.details = details

@tool
def send_email(to: str, subject: str, body: str) -> str:
    """Send email - requires user confirmation."""
    raise ConfirmationRequired(
        action="send_email",
        details={"to": to, "subject": subject, "body": body}
    )

def agent_loop(user_input: str):
    try:
        result = agent.run(user_input)
        return result
    except ConfirmationRequired as conf:
        # Show user what agent wants to do
        approved = prompt_user_confirmation(conf.action, conf.details)
        if approved:
            return execute_confirmed_action(conf)
        else:
            return "Action cancelled by user"
```

### Action Allowlisting

```python
# SECURE - Explicit action types
from enum import Enum
from pydantic import BaseModel

class AllowedAction(Enum):
    SEARCH = "search"
    SUMMARIZE = "summarize"
    TRANSLATE = "translate"

class AgentAction(BaseModel):
    action: AllowedAction
    parameters: dict

@tool
def execute_action(action_json: str) -> str:
    """Execute a validated action."""
    try:
        action = AgentAction.parse_raw(action_json)
    except ValidationError as e:
        return f"Invalid action: {e}"

    if action.action == AllowedAction.SEARCH:
        return search(action.parameters.get('query', ''))
    elif action.action == AllowedAction.SUMMARIZE:
        return summarize(action.parameters.get('text', ''))
    # etc.
```

### MCP Server Security

```python
# SECURE - Authenticated, scoped MCP server
from mcp import MCPServer, authenticate

@mcp.tool()
def read_document(doc_id: str, ctx: Context) -> str:
    """Read a document the user has access to."""
    user = ctx.authenticated_user

    doc = Document.get(doc_id)
    if not doc:
        raise ValueError("Document not found")

    if not user.can_access(doc):
        raise PermissionError("Access denied")

    return doc.content

server = MCPServer(
    tools=[read_document],
    authentication=authenticate,  # Require auth
    rate_limit=100,  # Limit calls
)
```

### Audit Logging

```python
# SECURE - Log all agent actions
import logging

agent_logger = logging.getLogger('agent_actions')

def logged_tool(func):
    @wraps(func)
    def wrapper(*args, **kwargs):
        agent_logger.info(f"Tool called: {func.__name__}", extra={
            'tool': func.__name__,
            'args': args,
            'kwargs': kwargs,
            'user': get_current_user().id,
            'timestamp': datetime.utcnow().isoformat()
        })
        try:
            result = func(*args, **kwargs)
            agent_logger.info(f"Tool completed: {func.__name__}")
            return result
        except Exception as e:
            agent_logger.error(f"Tool failed: {func.__name__}", exc_info=True)
            raise
    return wrapper

@logged_tool
@tool
def sensitive_operation(param: str) -> str:
    # All calls are logged
    pass
```

---

## Red Flags

1. **Shell/command execution** tool available to LLM
2. **Unrestricted file system** access (read/write anywhere)
3. **Raw SQL execution** from LLM
4. **No user-based tool scoping** - same tools for all
5. **No confirmation** for destructive/external actions
6. **Credentials embedded** in tools
7. **No rate limiting** on agent actions
8. **No audit logging** of tool usage

---

## Severity Guide

### Critical
- Unrestricted shell execution tool
- Full file system write access
- Database admin access via tool
- Payment/financial tools without limits
- No authentication on MCP server

### High
- Read access to sensitive files/data
- Email/messaging without confirmation
- User data modification tools
- API calls with elevated credentials

### Medium
- Overly broad read permissions
- Missing audit logging
- No rate limiting on tools
- Tools available regardless of user role

### Low
- Missing confirmation on non-destructive actions
- Verbose tool error messages
- No tool usage analytics

---

## Quick Fixes

| Issue | Fix |
|-------|-----|
| Shell access tool | Remove entirely, or replace with specific safe commands |
| Unrestricted file access | Scope to user directory, validate paths |
| Raw SQL tool | Use ORM with allowlisted tables/operations |
| Same tools for all users | Implement `get_tools_for_user(user)` |
| No confirmation | Add `ConfirmationRequired` for sensitive actions |
| Embedded credentials | Use service accounts with minimal permissions |
| No logging | Wrap all tools with audit logging decorator |
| No rate limits | Add per-user, per-tool rate limiting |
