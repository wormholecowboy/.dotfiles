# Hardcoded Secrets

Detecting credentials, API keys, tokens, and sensitive data committed to code.

---

## Patterns to Detect

### API Key Formats

#### AWS
```
AKIA[0-9A-Z]{16}          # Access Key ID
[A-Za-z0-9/+=]{40}        # Secret Access Key (when near AWS context)
```

#### GitHub
```
ghp_[A-Za-z0-9]{36}       # Personal Access Token
gho_[A-Za-z0-9]{36}       # OAuth Access Token
ghu_[A-Za-z0-9]{36}       # User-to-Server Token
ghs_[A-Za-z0-9]{36}       # Server-to-Server Token
ghr_[A-Za-z0-9]{36}       # Refresh Token
```

#### Stripe
```
sk_live_[A-Za-z0-9]{24,}  # Live Secret Key
sk_test_[A-Za-z0-9]{24,}  # Test Secret Key
rk_live_[A-Za-z0-9]{24,}  # Restricted Key
pk_live_[A-Za-z0-9]{24,}  # Publishable Key (less sensitive)
```

#### Slack
```
xox[baprs]-[A-Za-z0-9-]+  # Bot, App, Personal, or Refresh Token
```

#### Google
```
AIza[A-Za-z0-9_-]{35}     # API Key
[0-9]+-[A-Za-z0-9_]{32}\.apps\.googleusercontent\.com  # OAuth Client ID
```

#### OpenAI / Anthropic
```
sk-[A-Za-z0-9]{48,}       # OpenAI API Key
sk-ant-[A-Za-z0-9-]{90,}  # Anthropic API Key
```

#### SendGrid
```
SG\.[A-Za-z0-9_-]{22}\.[A-Za-z0-9_-]{43}  # API Key
```

#### Twilio
```
SK[a-f0-9]{32}            # API Key SID
[A-Za-z0-9]{32}           # Auth Token (when near Twilio context)
```

### Generic Patterns

#### Connection Strings
```python
# VULNERABLE
DATABASE_URL = "postgres://user:password@host:5432/db"
MONGO_URI = "mongodb://admin:secret@localhost:27017/mydb"
REDIS_URL = "redis://:password@localhost:6379/0"
```

#### Password Variables
```python
# VULNERABLE
password = "secretpassword123"
db_password = "admin123"
ADMIN_PASS = "changeme"
```

#### Private Keys
```
-----BEGIN RSA PRIVATE KEY-----
-----BEGIN OPENSSH PRIVATE KEY-----
-----BEGIN EC PRIVATE KEY-----
-----BEGIN PGP PRIVATE KEY BLOCK-----
```

#### JWT Secrets
```python
# VULNERABLE
JWT_SECRET = "my-super-secret-jwt-key"
jwt.encode(payload, "hardcoded-secret", algorithm="HS256")
```

---

## Anti-Patterns (Flag These)

### Hardcoded in Source

```python
# VULNERABLE
AWS_ACCESS_KEY = "AKIAIOSFODNN7EXAMPLE"
AWS_SECRET_KEY = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"

client = boto3.client(
    's3',
    aws_access_key_id=AWS_ACCESS_KEY,
    aws_secret_access_key=AWS_SECRET_KEY
)
```

```javascript
// VULNERABLE
const stripe = require('stripe')('sk_live_EXAMPLE_NOT_A_REAL_KEY');
```

### Config Files with Secrets

```yaml
# VULNERABLE - config.yaml
database:
  host: localhost
  user: admin
  password: supersecret123

api:
  key: sk-1234567890abcdef
```

```json
// VULNERABLE - config.json
{
  "apiKey": "AIzaSyD-1234567890abcdefghijklmnop",
  "dbPassword": "production_password_123"
}
```

### .env Files Committed

```bash
# VULNERABLE - .env should be in .gitignore
DATABASE_URL=postgres://user:realpassword@prod-db:5432/app
STRIPE_SECRET_KEY=sk_live_xxxxxxxxxxxx
JWT_SECRET=production-jwt-secret-key
```

### Inline in Code

```python
# VULNERABLE
def send_email():
    sg = sendgrid.SendGridAPIClient(api_key='SG.xxxx.yyyy')

def connect_db():
    return psycopg2.connect(
        host="db.example.com",
        password="productionpass123"  # Hardcoded
    )
```

### Comments with Secrets

```python
# VULNERABLE
# Old API key: sk-old1234567890
# TODO: Remove this - temp password is "admin123"
```

### Test Fixtures with Real Secrets

```python
# VULNERABLE - test_auth.py
def test_api_call():
    # Using real production key in tests!
    response = client.get('/api', headers={
        'Authorization': 'Bearer sk_live_real_key_here'
    })
```

---

## Secure Patterns

### Environment Variables

```python
# SECURE
import os

AWS_ACCESS_KEY = os.environ['AWS_ACCESS_KEY_ID']
AWS_SECRET_KEY = os.environ['AWS_SECRET_ACCESS_KEY']

# With validation
def get_required_env(name: str) -> str:
    value = os.environ.get(name)
    if not value:
        raise RuntimeError(f"Required environment variable {name} not set")
    return value

DATABASE_URL = get_required_env('DATABASE_URL')
```

### Secrets Manager

```python
# SECURE - AWS Secrets Manager
import boto3
import json

def get_secret(secret_name: str) -> dict:
    client = boto3.client('secretsmanager')
    response = client.get_secret_value(SecretId=secret_name)
    return json.loads(response['SecretString'])

db_creds = get_secret('prod/database')
password = db_creds['password']
```

```python
# SECURE - HashiCorp Vault
import hvac

client = hvac.Client(url='https://vault.example.com')
secret = client.secrets.kv.read_secret_version(path='database/creds')
password = secret['data']['data']['password']
```

### .env with .gitignore

```bash
# .gitignore
.env
.env.local
.env.*.local
*.pem
*.key
```

```python
# SECURE - Load from .env file (not committed)
from dotenv import load_dotenv
import os

load_dotenv()  # Loads .env file
API_KEY = os.environ['API_KEY']
```

### Placeholder in Committed Config

```yaml
# config.yaml (committed)
database:
  host: ${DATABASE_HOST}
  user: ${DATABASE_USER}
  password: ${DATABASE_PASSWORD}  # From environment
```

```python
# SECURE - Config references environment
import os
import yaml

with open('config.yaml') as f:
    config = yaml.safe_load(f)

# Expand environment variables
def expand_env(value):
    if isinstance(value, str) and value.startswith('${') and value.endswith('}'):
        env_var = value[2:-1]
        return os.environ.get(env_var, '')
    return value
```

---

## Detection Workflow

1. **Scan for known patterns**
   - API key prefixes (AKIA, ghp_, sk_, etc.)
   - Connection string formats
   - Private key headers

2. **Check variable names**
   - password, passwd, pwd, secret
   - api_key, apiKey, API_KEY
   - token, auth_token, access_token
   - credential, private_key

3. **Check file types**
   - .env files in repo
   - config.json, config.yaml with values
   - *.pem, *.key files

4. **Entropy analysis**
   - High-entropy strings near sensitive variable names
   - Long random-looking strings in quotes

---

## False Positive Handling

### Likely False Positives
- Example/placeholder values: `"your-api-key-here"`, `"changeme"`, `"xxxxxxxx"`
- Test fixtures with obvious fake data
- Documentation examples
- Environment variable references: `os.environ['KEY']`, `process.env.KEY`

### Verify By
- Checking if value is a real key format
- Checking if file is in .gitignore
- Checking if value matches placeholder patterns
- Checking entropy (real keys have high entropy)

---

## Severity Guide

### Critical
- Production API keys (AWS, Stripe live, etc.)
- Database credentials for production
- Private keys (RSA, SSH, PGP)
- JWT signing secrets

### High
- Test/staging API keys (still sensitive)
- Internal service credentials
- OAuth client secrets

### Medium
- API keys for non-sensitive services
- Read-only tokens
- Expired credentials (still bad practice)

### Low
- Publishable keys (meant to be public)
- Example/placeholder values that look real
- Keys in test files with obvious test data

---

## Quick Fixes

| Issue | Fix |
|-------|-----|
| Hardcoded in source | Move to `os.environ['VAR']` |
| Config file with secrets | Use `${VAR}` placeholders, load from env |
| .env committed | Add `.env` to `.gitignore`, rotate exposed secrets |
| Private key in repo | Remove, add to `.gitignore`, regenerate key |
| Test with real keys | Use fake values or test-specific keys |

## Post-Detection Actions

1. **If secret was committed:**
   - Rotate the secret immediately
   - Remove from git history: `git filter-branch` or BFG Repo-Cleaner
   - Add to .gitignore
   - Audit for unauthorized use

2. **Prevention:**
   - Use pre-commit hooks (detect-secrets, gitleaks)
   - CI/CD secret scanning
   - Regular repository audits
