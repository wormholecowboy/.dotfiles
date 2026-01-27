# Injection Vulnerabilities

OWASP #3: Injection

Injection flaws occur when untrusted data is sent to an interpreter as part of a command or query. Covers SQL, NoSQL, OS command, XSS, and template injection.

---

## SQL Injection

### Vulnerabilities

#### String Concatenation in Queries
```python
# VULNERABLE
query = "SELECT * FROM users WHERE id = " + user_id
query = f"SELECT * FROM users WHERE name = '{username}'"
query = "SELECT * FROM users WHERE name = '%s'" % username
```

#### ORM Raw Queries with Interpolation
```python
# VULNERABLE
User.objects.raw(f"SELECT * FROM users WHERE name = '{name}'")
db.execute(text(f"SELECT * FROM products WHERE category = '{cat}'"))
```

#### Dynamic Table/Column Names
```python
# VULNERABLE
query = f"SELECT * FROM {table_name} WHERE {column} = ?"
# table_name and column could be injected
```

### Secure Patterns

```python
# SECURE - Parameterized queries
cursor.execute("SELECT * FROM users WHERE id = ?", (user_id,))
cursor.execute("SELECT * FROM users WHERE name = %s", (username,))

# SECURE - ORM parameters
User.objects.filter(name=username)
db.query(User).filter(User.name == username).first()

# SECURE - SQLAlchemy with bound parameters
stmt = text("SELECT * FROM users WHERE name = :name")
result = db.execute(stmt, {"name": username})
```

---

## NoSQL Injection

### Vulnerabilities

#### Operator Injection
```javascript
// VULNERABLE - User can inject operators
const query = { username: req.body.username };
// If req.body.username = { $ne: "" }, returns all users
db.users.find(query);
```

#### $where Injection
```javascript
// VULNERABLE - JavaScript execution
db.users.find({ $where: `this.name == '${username}'` });
```

#### JSON Query Construction
```python
# VULNERABLE
query = json.loads(user_input)
collection.find(query)  # User controls entire query
```

### Secure Patterns

```javascript
// SECURE - Validate and type-check input
const username = String(req.body.username);  // Force string type
if (typeof username !== 'string') throw new Error('Invalid input');
db.users.find({ username: username });

// SECURE - Sanitize operators
const sanitize = (obj) => {
  for (const key in obj) {
    if (key.startsWith('$')) delete obj[key];  // Remove operators
  }
  return obj;
};
```

---

## OS Command Injection

### Vulnerabilities

#### shell=True with User Input
```python
# VULNERABLE
subprocess.call(f"grep {pattern} /var/log/app.log", shell=True)
os.system(f"convert {filename} output.png")
```

#### Backtick/Command Substitution
```javascript
// VULNERABLE
exec(`ls ${userPath}`, callback);  // User controls path
```

#### Unsafe Functions
```python
# VULNERABLE
os.popen(user_command)
commands.getoutput(user_input)
eval(user_expression)
```

### Secure Patterns

```python
# SECURE - Array arguments, no shell
subprocess.run(["grep", pattern, "/var/log/app.log"], shell=False)
subprocess.run(["convert", filename, "output.png"])

# SECURE - Validate input
import shlex
if not re.match(r'^[\w\-\.]+$', filename):
    raise ValueError("Invalid filename")

# SECURE - Use library instead of shell
import pathlib
files = list(pathlib.Path(directory).glob("*.txt"))  # Instead of `ls *.txt`
```

---

## XSS (Cross-Site Scripting)

### Vulnerabilities

#### innerHTML with User Content
```javascript
// VULNERABLE
element.innerHTML = userContent;
document.getElementById('output').innerHTML = data.message;
```

#### React dangerouslySetInnerHTML
```jsx
// VULNERABLE
<div dangerouslySetInnerHTML={{ __html: userContent }} />
```

#### Template Without Escaping
```python
# VULNERABLE - Jinja2 without escaping
return render_template_string(f"<h1>{user_input}</h1>")

# VULNERABLE - Marked safe
return Markup(user_input)
```

```javascript
// VULNERABLE - Vue v-html
<div v-html="userContent"></div>
```

#### document.write
```javascript
// VULNERABLE
document.write(location.search);  // Reflected XSS from URL
```

### Secure Patterns

```javascript
// SECURE - textContent instead of innerHTML
element.textContent = userContent;

// SECURE - DOM API
const text = document.createTextNode(userContent);
element.appendChild(text);
```

```jsx
// SECURE - React auto-escapes by default
<div>{userContent}</div>  // This is safe
```

```python
# SECURE - Auto-escaping enabled (Jinja2 default)
return render_template("page.html", content=user_input)

# SECURE - Explicit escape
from markupsafe import escape
return f"<h1>{escape(user_input)}</h1>"
```

---

## Template Injection (SSTI)

### Vulnerabilities

#### User Input in Template String
```python
# VULNERABLE - Server-Side Template Injection
template = f"Hello {user_input}"  # If user_input = "{{7*7}}" → "Hello 49"
return render_template_string(template)
```

```python
# VULNERABLE - Jinja2 from user string
template = Template(user_controlled_string)
template.render()
```

### Secure Patterns

```python
# SECURE - Pass data as context, not in template
return render_template("greeting.html", name=user_input)
# greeting.html: <h1>Hello {{ name }}</h1>

# SECURE - Sandbox environment
from jinja2.sandbox import SandboxedEnvironment
env = SandboxedEnvironment()
template = env.from_string(user_template)
```

---

## Anti-Patterns Summary

| Type | Anti-Pattern | Secure Alternative |
|------|--------------|-------------------|
| SQL | String concat/f-string | Parameterized queries |
| SQL | `%` or `.format()` | ORM methods |
| NoSQL | Unvalidated JSON query | Type validation |
| NoSQL | `$where` with user input | Avoid $where |
| OS | `shell=True` | `shell=False` + array args |
| OS | `os.system()`, `os.popen()` | `subprocess.run()` with list |
| XSS | `innerHTML` | `textContent` |
| XSS | `dangerouslySetInnerHTML` | Default React escaping |
| XSS | `v-html` | `{{ }}` interpolation |
| SSTI | `render_template_string(user)` | `render_template()` with context |

---

## Severity Guide

### Critical
- SQL injection with data exfiltration possible
- OS command injection (RCE)
- SSTI leading to code execution

### High
- SQL injection (blind or limited)
- NoSQL injection affecting auth
- Stored XSS
- OS command with limited scope

### Medium
- Reflected XSS
- NoSQL injection (data access)
- SQL injection in non-sensitive table

### Low
- Self-XSS (only affects attacker)
- Injection in logging (no execution)

---

## Quick Fixes

| Issue | Fix |
|-------|-----|
| SQL string concat | Use parameterized: `cursor.execute("SELECT * FROM t WHERE x = ?", (val,))` |
| NoSQL operator injection | Force type: `String(input)`, reject objects with `$` keys |
| OS command with shell=True | Use `subprocess.run([cmd, arg], shell=False)` |
| innerHTML | Replace with `textContent` or DOM API |
| dangerouslySetInnerHTML | Use DOMPurify to sanitize: `DOMPurify.sanitize(html)` |
| Template injection | Never put user input in template string; use context variables |
