# Insecure LLM Output Handling

OWASP Top 10 for LLMs #2: Insecure Output Handling

LLM outputs should be treated as untrusted. Directly using LLM responses in code execution, database queries, or rendered content can lead to injection attacks.

---

## Vulnerabilities to Detect

### Code Execution from LLM Output

#### eval() with LLM Response
```python
# VULNERABLE - LLM output executed as code
response = llm.generate("Write Python code to calculate factorial")
result = eval(response)  # Arbitrary code execution
```

```javascript
// VULNERABLE
const code = await llm.generate("Create a function to sort arrays");
const func = new Function(code);  // Code injection
func([3, 1, 2]);
```

#### exec() with Generated Code
```python
# VULNERABLE
code = llm.generate(f"Write code to process: {user_data}")
exec(code)  # User influences code generation, code is executed
```

#### subprocess with LLM Output
```python
# VULNERABLE
command = llm.generate(f"Generate shell command to: {user_request}")
subprocess.run(command, shell=True)  # Shell injection via LLM
```

### SQL Injection via LLM

#### LLM Generates SQL
```python
# VULNERABLE
sql = llm.generate(f"Write SQL to find users matching: {user_query}")
cursor.execute(sql)  # SQL injection via LLM output
```

#### Natural Language to SQL
```python
# VULNERABLE - Common in "chat with database" apps
user_question = "Show me all users; DROP TABLE users; --"
sql = nl_to_sql(user_question)  # LLM may generate malicious SQL
db.execute(sql)
```

### XSS via LLM Output

#### Rendering LLM HTML
```javascript
// VULNERABLE
const summary = await llm.generate("Summarize this article in HTML");
document.getElementById('output').innerHTML = summary;
// LLM could output: <script>alert('XSS')</script>
```

#### Markdown without Sanitization
```python
# VULNERABLE
markdown_content = llm.generate(f"Format this as markdown: {user_text}")
html = markdown.render(markdown_content)  # May contain malicious HTML/JS
return html  # Rendered to user
```

#### React dangerouslySetInnerHTML
```jsx
// VULNERABLE
const formatted = await llm.generate("Format this text with HTML");
return <div dangerouslySetInnerHTML={{ __html: formatted }} />;
```

### File System Operations

#### Writing LLM Output to Files
```python
# VULNERABLE
filename = llm.generate(f"Suggest a filename for: {content_description}")
# filename could be "../../../etc/passwd" or similar
with open(filename, 'w') as f:
    f.write(content)
```

#### LLM Generates File Paths
```python
# VULNERABLE
path = llm.generate(f"What file should I read for: {user_query}")
with open(path, 'r') as f:  # Path traversal via LLM
    return f.read()
```

### API/Network Operations

#### LLM Generates URLs
```python
# VULNERABLE - SSRF via LLM
url = llm.generate(f"What API endpoint should I call for: {user_request}")
response = requests.get(url)  # Could hit internal services
```

#### LLM Controls Request Body
```python
# VULNERABLE
request_body = llm.generate(f"Generate API request for: {user_input}")
response = requests.post(api_url, json=json.loads(request_body))
# LLM may generate malicious payloads
```

---

## Secure Patterns

### Sandboxed Code Execution

```python
# SECURE - Use restricted execution environment
from RestrictedPython import compile_restricted, safe_globals

code = llm.generate("Write code to calculate factorial")

# Compile with restrictions
byte_code = compile_restricted(code, '<llm>', 'exec')

# Execute in sandbox with limited builtins
restricted_globals = safe_globals.copy()
restricted_globals['__builtins__'] = {
    'range': range,
    'len': len,
    'int': int,
    'print': print,
    # Only safe builtins
}

exec(byte_code, restricted_globals)
```

```python
# SECURE - Docker sandbox for untrusted code
import docker

def run_code_sandboxed(code: str) -> str:
    client = docker.from_env()
    result = client.containers.run(
        'python:3.11-slim',
        f'python -c "{code}"',
        mem_limit='128m',
        cpu_period=100000,
        cpu_quota=50000,
        network_disabled=True,
        read_only=True,
        remove=True,
        timeout=10
    )
    return result.decode()
```

### Validated SQL Generation

```python
# SECURE - Validate and parameterize LLM SQL
import sqlparse
from sqlalchemy import text

def safe_nl_to_sql(user_question: str, allowed_tables: list) -> str:
    # Generate SQL
    sql = llm.generate(f"""
    Generate a SELECT query for: {user_question}
    Only use tables: {allowed_tables}
    Only use SELECT statements.
    """)

    # Parse and validate
    parsed = sqlparse.parse(sql)
    if len(parsed) != 1:
        raise ValueError("Multiple statements not allowed")

    stmt = parsed[0]
    if stmt.get_type() != 'SELECT':
        raise ValueError("Only SELECT queries allowed")

    # Check for dangerous patterns
    sql_lower = sql.lower()
    dangerous = ['drop', 'delete', 'insert', 'update', 'alter', 'create', ';']
    if any(d in sql_lower for d in dangerous):
        raise ValueError("Dangerous SQL pattern detected")

    # Validate table names
    for token in stmt.tokens:
        if token.ttype is None and str(token) not in allowed_tables:
            # Further table validation logic
            pass

    return sql
```

```python
# SECURE - Use ORM instead of raw SQL
def natural_language_query(question: str):
    # LLM generates structured filter, not SQL
    filters = llm.generate(f"""
    Convert to JSON filters: {question}
    Format: {{"field": "name", "op": "contains", "value": "john"}}
    """)

    filters = json.loads(filters)
    query = User.query

    for f in filters:
        if f['field'] not in ALLOWED_FIELDS:
            continue
        if f['op'] == 'contains':
            query = query.filter(getattr(User, f['field']).contains(f['value']))
        elif f['op'] == 'equals':
            query = query.filter(getattr(User, f['field']) == f['value'])

    return query.all()
```

### Sanitized HTML Output

```javascript
// SECURE - Sanitize before rendering
import DOMPurify from 'dompurify';

const llmOutput = await llm.generate("Format this as HTML");
const sanitized = DOMPurify.sanitize(llmOutput, {
    ALLOWED_TAGS: ['p', 'b', 'i', 'em', 'strong', 'ul', 'ol', 'li', 'br'],
    ALLOWED_ATTR: []  // No attributes allowed
});
document.getElementById('output').innerHTML = sanitized;
```

```python
# SECURE - Server-side sanitization
import bleach

def render_llm_content(content: str) -> str:
    llm_html = llm.generate(f"Format as HTML: {content}")

    sanitized = bleach.clean(
        llm_html,
        tags=['p', 'b', 'i', 'em', 'strong', 'ul', 'ol', 'li', 'br', 'h1', 'h2', 'h3'],
        attributes={},
        strip=True
    )
    return sanitized
```

```jsx
// SECURE - Use markdown renderer with sanitization
import ReactMarkdown from 'react-markdown';
import rehypeSanitize from 'rehype-sanitize';

function LLMContent({ content }) {
    return (
        <ReactMarkdown rehypePlugins={[rehypeSanitize]}>
            {content}
        </ReactMarkdown>
    );
}
```

### Safe File Operations

```python
# SECURE - Validate file paths
import os
from pathlib import Path

ALLOWED_DIRECTORY = Path('/app/user_files')

def safe_write_file(suggested_name: str, content: str):
    # Sanitize filename
    safe_name = "".join(c for c in suggested_name if c.isalnum() or c in '.-_')
    if not safe_name:
        safe_name = 'output.txt'

    # Ensure within allowed directory
    target = ALLOWED_DIRECTORY / safe_name
    target = target.resolve()

    if not str(target).startswith(str(ALLOWED_DIRECTORY)):
        raise ValueError("Path traversal detected")

    with open(target, 'w') as f:
        f.write(content)
```

### Validated Network Operations

```python
# SECURE - Allowlist URLs from LLM
ALLOWED_API_HOSTS = {'api.example.com', 'data.example.com'}

def safe_fetch(llm_suggested_url: str) -> dict:
    from urllib.parse import urlparse

    parsed = urlparse(llm_suggested_url)

    if parsed.scheme not in ('http', 'https'):
        raise ValueError("Invalid scheme")

    if parsed.hostname not in ALLOWED_API_HOSTS:
        raise ValueError(f"Host not allowed: {parsed.hostname}")

    response = requests.get(llm_suggested_url)
    return response.json()
```

---

## Output Validation Patterns

### Structured Output Validation

```python
# SECURE - Validate LLM output against schema
from pydantic import BaseModel, validator
import json

class LLMResponse(BaseModel):
    action: str
    parameters: dict

    @validator('action')
    def validate_action(cls, v):
        allowed = ['search', 'summarize', 'translate']
        if v not in allowed:
            raise ValueError(f"Action must be one of {allowed}")
        return v

def process_llm_output(raw_output: str):
    try:
        data = json.loads(raw_output)
        validated = LLMResponse(**data)
        return validated
    except (json.JSONDecodeError, ValueError) as e:
        raise ValueError(f"Invalid LLM output: {e}")
```

### Content Type Validation

```python
# SECURE - Ensure output matches expected type
def get_number_from_llm(prompt: str) -> int:
    response = llm.generate(prompt)

    # Strip and validate
    clean = response.strip()
    if not clean.isdigit():
        raise ValueError("LLM did not return a valid number")

    return int(clean)
```

---

## Severity Guide

### Critical
- `eval()` / `exec()` with LLM output
- `subprocess` with LLM-generated commands
- LLM generates unrestricted SQL that is executed
- File write to LLM-suggested path without validation

### High
- innerHTML with unsanitized LLM HTML
- LLM generates URLs used for server-side requests
- Database queries built from LLM output

### Medium
- Markdown rendering without sanitization
- LLM output used in API request bodies
- File reads from LLM-suggested paths

### Low
- LLM output logged without sanitization
- LLM output displayed as plain text (not HTML)

---

## Quick Fixes

| Issue | Fix |
|-------|-----|
| eval() with LLM output | Use RestrictedPython or Docker sandbox |
| LLM SQL execution | Validate query type, allowlist tables, use ORM |
| innerHTML with LLM | Use DOMPurify: `DOMPurify.sanitize(output)` |
| subprocess with LLM | Never. Use specific APIs instead of shell |
| File path from LLM | Sanitize filename, resolve and check against allowed directory |
| URL from LLM | Allowlist hosts, validate scheme |
