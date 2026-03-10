# Router - Code Signal Detection

Maps detected patterns to check files. Scan code for these signals to determine which checks to load.

## Detection Strategy

1. Scan file extensions to identify languages
2. Search for keyword/pattern matches
3. Load checks where ANY pattern matches
4. Multiple checks can trigger from same file

---

## auth.md

**Load when detecting authentication or authorization code.**

### Keywords (case-insensitive)
```
login, logout, signin, signout, signup, register
authenticate, authorize, authentication, authorization
session, cookie, jwt, token, bearer, refresh_token
password, credential, apikey, api_key
```

### Function/Method Patterns
```
isAdmin, is_admin, isAuthenticated, is_authenticated
hasRole, has_role, hasPermission, has_permission
checkAuth, check_auth, verifyToken, verify_token
canAccess, can_access, isOwner, is_owner
requireAuth, require_auth, ensureAuthenticated
```

### Decorators/Annotations
```
@login_required, @authenticated, @protected
@require_login, @auth_required, @roles
@Authorize, @PreAuthorize, @Secured
```

### Middleware Patterns
```
authMiddleware, auth_middleware, passport
requireAuth, protect, guard, authenticate
```

### File Path Patterns
```
**/auth/**
**/authentication/**
**/middleware/auth*
**/guards/**
**/policies/**
**/*auth*.py
**/*auth*.ts
**/*auth*.js
```

---

## injection.md

**Load when detecting database queries, command execution, or HTML rendering.**

### SQL Patterns
```
SELECT, INSERT, UPDATE, DELETE, DROP, TRUNCATE
FROM, WHERE, JOIN, ORDER BY, GROUP BY
execute, query, raw, cursor
.execute(, .query(, .raw(
f"SELECT, f"INSERT, f"UPDATE, f"DELETE
"SELECT" +, "INSERT" +, 'SELECT' +
.format( near SQL keywords
```

### NoSQL Patterns
```
$where, $regex, $ne, $gt, $lt, $in
.find(, .findOne(, .aggregate(
.updateOne(, .updateMany(, .deleteOne(
mongodb, mongoose, pymongo
```

### OS Command Patterns
```
exec, spawn, system, popen
subprocess, child_process, shell
os.system, os.popen, os.exec
commands.getoutput, commands.getstatusoutput
shell=True, shell: true
`${, `$(  (backtick interpolation)
```

### XSS/HTML Patterns
```
innerHTML, outerHTML, document.write
dangerouslySetInnerHTML, v-html, [innerHTML]
|safe, {% autoescape off %}, {{!
.html(, .append( with user input
```

### Template Injection
```
render_template_string, Template(
Jinja2, Mako, Tornado templates with user input
eval(, exec( with template content
```

---

## crypto.md

**Load when detecting cryptographic operations.**

### Import Patterns
```
crypto, hashlib, bcrypt, argon2, scrypt
CryptoJS, node-forge, crypto-js
javax.crypto, java.security
openssl, pycryptodome, cryptography
```

### Weak Algorithm Signals
```
md5, MD5, sha1, SHA1
DES, 3DES, RC4, RC2
ECB (mode), AES-ECB
```

### Key/Secret Patterns
```
secretKey, secret_key, privateKey, private_key
encryptionKey, encryption_key, masterKey
iv, IV, nonce, salt
key =, key=, KEY =
```

### Certificate Patterns
```
verify=False, verify_ssl=False
CERT_NONE, ssl.CERT_NONE
InsecureRequestWarning, disable_warnings
```

---

## config.md

**Load when detecting configuration or environment handling.**

### Environment Patterns
```
DEBUG, debug, NODE_ENV, FLASK_ENV
development, production, verbose
process.env, os.environ, getenv
.env, dotenv, config.
```

### CORS Patterns
```
Access-Control-Allow-Origin
cors(, CORS(, corsOptions
origin:, allowedOrigins, credentials:
```

### Header Patterns
```
X-Frame-Options, X-Content-Type-Options
Content-Security-Policy, CSP
Strict-Transport-Security, HSTS
X-XSS-Protection
```

### Exposed Endpoints
```
/debug, /admin, /test, /dev
/swagger, /api-docs, /graphql
stack trace, traceback, error details
```

---

## ssrf.md

**Load when detecting HTTP clients or URL construction.**

### HTTP Client Patterns
```
fetch, axios, requests, http.get, https.get
urllib, urllib3, httpx, aiohttp
got, superagent, request(
HttpClient, WebClient, RestTemplate
```

### URL Construction Patterns
```
url =, uri =, endpoint =
new URL(, URL(, urlparse
+ "http, + "https, f"http
.format( with URL
```

### Redirect Patterns
```
redirect=, url=, next=, callback=
returnUrl, return_url, goto, target
Location header with user input
```

### Internal Network Signals
```
localhost, 127.0.0.1, 0.0.0.0
169.254., 10., 192.168., 172.16.
::1, internal, intranet
```

---

## secrets.md

**Load when detecting potential hardcoded secrets.**

### API Key Prefixes
```
sk-, pk_, sk_live, sk_test
AKIA (AWS), ghp_ (GitHub), xox (Slack)
rk_live, rk_test (Stripe)
AIza (Google), SG. (SendGrid)
```

### Credential Keywords
```
api_key, apiKey, API_KEY, apikey
password, passwd, pwd, secret
token, auth_token, access_token
credential, private_key, secret_key
```

### Connection Strings
```
://.*:.*@ (user:pass in URL)
mongodb://, postgres://, mysql://
redis://, amqp://, elasticsearch://
jdbc:, sqlserver://
```

### File Patterns
```
.env (contents, not just existence)
config.json, secrets.json, credentials.json
*.pem, *.key, *.p12, *.pfx
```

---

## deps.md

**Load when package/dependency files are in scope.**

### File Detection
```
package.json, package-lock.json, yarn.lock
requirements.txt, Pipfile, Pipfile.lock, poetry.lock
Cargo.toml, Cargo.lock
go.mod, go.sum
Gemfile, Gemfile.lock
pom.xml, build.gradle
composer.json, composer.lock
```

### Action
When detected, check against known vulnerability databases:
- npm audit / yarn audit
- pip-audit, safety
- cargo audit
- govulncheck
- bundler-audit

---

## llm-injection.md

**Load when detecting LLM API usage or prompt construction.**

### LLM Library Imports
```
openai, anthropic, cohere, google.generativeai
langchain, llama_index, haystack
ollama, replicate, huggingface
transformers, sentence_transformers
```

### API Patterns
```
chat.completions, messages.create
.generate(, .complete(, .invoke(
ChatCompletion, Completion
client.chat, client.messages
```

### Prompt Construction
```
prompt =, system_message =, user_message =
messages.append, messages +=
f"You are, f"<system>, "role":
{user_input} in prompt string
template.format( with user input
```

### Agent/Chain Patterns
```
AgentExecutor, create_agent, initialize_agent
LLMChain, ConversationChain, RetrievalQA
.run(, .ainvoke(, .stream(
```

---

## llm-output.md

**Load when detecting LLM response handling.**

### Code Execution with LLM Output
```
eval(, exec(, Function(
vm.runInContext, vm.runInNewContext
compile(, ast.literal_eval with response
subprocess with LLM output
```

### HTML/Rendering
```
innerHTML with LLM response
dangerouslySetInnerHTML
markdown render without sanitize
.html( with AI output
```

### File Operations
```
writeFile, fs.write, open().write
with LLM response content
save(, dump( with AI output
```

### Database Operations
```
.execute(, .query( with LLM response
raw SQL from AI output
```

---

## llm-agency.md

**Load when detecting AI agent tool definitions.**

### Tool Definition Patterns
```
tools=, functions=, function_call
@tool, @function, def tool_
ToolDefinition, FunctionDefinition
available_functions, tool_choice
```

### Agent Frameworks
```
autogen, crewai, semantic-kernel
langchain.agents, AgentExecutor
swarm, agency, multi-agent
```

### MCP Patterns
```
mcp.server, @mcp.tool
MCPServer, Tool(, Resource(
stdio_server, sse_server
```

### Dangerous Tool Signals
File system access:
```
read_file, write_file, delete_file
list_directory, create_directory
```

Shell access:
```
run_command, execute_shell, bash
terminal, subprocess, os.system
```

Network access:
```
http_request, fetch_url, download
send_email, api_call
```

Database access:
```
query_database, execute_sql
db_read, db_write
```

---

## llm-data.md

**Load when detecting prompt/response logging or data handling.**

### Logging Patterns
```
console.log, print, logger.
logging., log.info, log.debug
with prompt, response, completion content
```

### Large Context Signals
```
file content → prompt
database results → prompt
user data → system message
entire document in context
```

### PII Indicators
```
email, phone, ssn, social_security
credit_card, cc_number, cvv
address, date_of_birth, dob
in prompt construction
```

### Storage Patterns
```
save prompt, store conversation
log_messages, persist chat
without scrubbing/masking
```

---

## Priority Order

When multiple checks trigger, prioritize analysis in this order:

1. **auth.md** - Access control is foundational
2. **injection.md** - High impact, common vulnerability
3. **llm-injection.md** - Critical for AI systems
4. **secrets.md** - Immediate exposure risk
5. **llm-agency.md** - Agent permission scope
6. **ssrf.md** - Network boundary issues
7. **crypto.md** - Data protection
8. **llm-output.md** - Output handling
9. **config.md** - Misconfiguration
10. **llm-data.md** - Data leakage
11. **deps.md** - Supply chain (defer to tools)
