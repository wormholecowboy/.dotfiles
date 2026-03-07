# Cryptographic Failures

OWASP #2: Cryptographic Failures

Failures related to cryptography that expose sensitive data. Includes weak algorithms, improper key management, and missing encryption.

---

## Vulnerabilities to Detect

### Weak Hashing Algorithms

#### MD5 for Security Purposes
```python
# VULNERABLE - MD5 is broken for security
import hashlib
password_hash = hashlib.md5(password.encode()).hexdigest()
```

#### SHA1 for Passwords
```python
# VULNERABLE - SHA1 is weak, no salt
hash = hashlib.sha1(password.encode()).hexdigest()
```

#### Unsalted Hashes
```python
# VULNERABLE - Same password = same hash
hash = hashlib.sha256(password.encode()).hexdigest()
# Rainbow table attack possible
```

### Weak Encryption

#### DES / 3DES / RC4
```python
# VULNERABLE - DES is broken
from Crypto.Cipher import DES
cipher = DES.new(key, DES.MODE_ECB)
```

#### ECB Mode
```python
# VULNERABLE - ECB reveals patterns
cipher = AES.new(key, AES.MODE_ECB)
# Identical plaintext blocks → identical ciphertext blocks
```

#### Short Keys
```python
# VULNERABLE - Key too short
key = b'shortkey'  # 8 bytes = 64 bits, easily brute-forced
cipher = AES.new(key, AES.MODE_CBC, iv)
```

### Improper Key Management

#### Hardcoded Keys
```python
# VULNERABLE
SECRET_KEY = "my-secret-key-12345"
ENCRYPTION_KEY = b'0123456789abcdef'
```

#### Keys in Source Code
```javascript
// VULNERABLE
const JWT_SECRET = "super-secret-jwt-key";
const API_KEY = "sk-1234567890abcdef";
```

#### Predictable IVs/Nonces
```python
# VULNERABLE - Static IV
iv = b'0000000000000000'
cipher = AES.new(key, AES.MODE_CBC, iv)
```

### Insecure Random

#### Using `random` for Security
```python
# VULNERABLE - random is not cryptographically secure
import random
token = ''.join(random.choices('abcdef0123456789', k=32))
```

#### Predictable Seeds
```python
# VULNERABLE
random.seed(time.time())  # Predictable seed
session_id = random.randint(0, 999999)
```

### Certificate Issues

#### Disabled Verification
```python
# VULNERABLE
requests.get(url, verify=False)
ssl_context.check_hostname = False
ssl_context.verify_mode = ssl.CERT_NONE
```

#### Self-Signed Acceptance
```javascript
// VULNERABLE
process.env.NODE_TLS_REJECT_UNAUTHORIZED = '0';
```

### Missing Encryption

#### Sensitive Data Unencrypted
```python
# VULNERABLE - PII stored plaintext
user.ssn = request.form['ssn']
user.credit_card = request.form['cc_number']
db.session.commit()  # Stored unencrypted
```

#### HTTP for Sensitive Data
```python
# VULNERABLE - Credentials over HTTP
requests.post("http://api.example.com/login", data=credentials)
```

---

## Secure Patterns

### Password Hashing

```python
# SECURE - bcrypt with cost factor
import bcrypt

def hash_password(password: str) -> bytes:
    salt = bcrypt.gensalt(rounds=12)  # Cost factor 12
    return bcrypt.hashpw(password.encode(), salt)

def verify_password(password: str, hash: bytes) -> bool:
    return bcrypt.checkpw(password.encode(), hash)
```

```python
# SECURE - Argon2 (recommended)
from argon2 import PasswordHasher

ph = PasswordHasher(
    time_cost=3,       # iterations
    memory_cost=65536, # 64MB
    parallelism=4
)

hash = ph.hash(password)
ph.verify(hash, password)  # Raises on mismatch
```

### Symmetric Encryption

```python
# SECURE - AES-GCM (authenticated encryption)
from cryptography.hazmat.primitives.ciphers.aead import AESGCM
import os

key = os.urandom(32)  # 256-bit key
nonce = os.urandom(12)  # 96-bit nonce (never reuse!)

aesgcm = AESGCM(key)
ciphertext = aesgcm.encrypt(nonce, plaintext, associated_data)
plaintext = aesgcm.decrypt(nonce, ciphertext, associated_data)
```

```python
# SECURE - Fernet (high-level, safe defaults)
from cryptography.fernet import Fernet

key = Fernet.generate_key()  # Store securely!
f = Fernet(key)

token = f.encrypt(b"secret data")
plaintext = f.decrypt(token)
```

### Secure Random

```python
# SECURE - secrets module for tokens
import secrets

token = secrets.token_hex(32)  # 64 character hex string
token = secrets.token_urlsafe(32)  # URL-safe base64
session_id = secrets.token_bytes(32)
```

```javascript
// SECURE - crypto.randomBytes
const crypto = require('crypto');
const token = crypto.randomBytes(32).toString('hex');
```

### Key Management

```python
# SECURE - Keys from environment or secrets manager
import os

SECRET_KEY = os.environ.get('SECRET_KEY')
if not SECRET_KEY:
    raise RuntimeError("SECRET_KEY not configured")

# Or use a secrets manager
from aws_secretsmanager import get_secret
SECRET_KEY = get_secret('app/secret-key')
```

### Certificate Validation

```python
# SECURE - Always verify certificates
response = requests.get(url)  # verify=True is default

# If custom CA needed:
response = requests.get(url, verify='/path/to/ca-bundle.crt')
```

---

## Anti-Patterns Summary

| Anti-Pattern | Secure Alternative |
|--------------|-------------------|
| MD5/SHA1 for passwords | bcrypt, Argon2, scrypt |
| Unsalted hash | Use algorithms with built-in salt |
| DES, 3DES, RC4 | AES-256-GCM |
| ECB mode | GCM, CBC with HMAC |
| Hardcoded keys | Environment variables, secrets manager |
| Static IV/nonce | Random IV per encryption |
| `random` module | `secrets` module |
| `verify=False` | Always verify certificates |
| Short keys (<128 bit) | 256-bit keys for symmetric |

---

## Severity Guide

### Critical
- Passwords stored in plaintext or MD5/SHA1 without salt
- Hardcoded encryption keys for sensitive data
- Certificate verification disabled in production
- Sensitive data transmitted over HTTP

### High
- Weak encryption (DES, RC4, ECB mode)
- Predictable tokens/session IDs using `random`
- Short encryption keys (<128 bits)
- Static/reused IVs

### Medium
- SHA256 for passwords (should use bcrypt/argon2)
- Low bcrypt cost factor (<10)
- Missing encryption on moderately sensitive data

### Low
- Self-signed certificates in development
- Slightly outdated but still secure algorithms

---

## Quick Fixes

| Issue | Fix |
|-------|-----|
| MD5/SHA1 passwords | Migrate to `bcrypt.hashpw()` or `argon2.hash()` |
| Hardcoded key | Move to `os.environ['KEY']` or secrets manager |
| `random` for tokens | Replace with `secrets.token_hex()` |
| ECB mode | Use GCM: `AES.new(key, AES.MODE_GCM)` |
| `verify=False` | Remove parameter (verify=True is default) |
| Static IV | Generate: `iv = os.urandom(16)` per encryption |
| Short key | Use 32 bytes: `key = os.urandom(32)` |
