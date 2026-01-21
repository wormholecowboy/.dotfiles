# Authentication & Access Control

OWASP #1: Broken Access Control
OWASP #7: Identification and Authentication Failures

This is the most critical check. Auth vulnerabilities directly lead to unauthorized access.

---

## Vulnerabilities to Detect

### Authentication Failures

#### Weak Password Policy
- No minimum length requirement
- No complexity requirements
- Common passwords allowed
- No breach database check

#### Credential Stuffing / Brute Force
- No rate limiting on login
- No account lockout
- No CAPTCHA after failures
- No exponential backoff

#### Credential Enumeration
- Different error messages for valid/invalid users
- Timing differences in response
- Password reset reveals existence

#### Insecure Password Storage
- Plaintext passwords
- Weak hashing (MD5, SHA1 without salt)
- Missing or weak salt
- Low iteration count

#### Session Fixation
- Session ID not regenerated on login
- Session accepted from URL parameter
- Predictable session IDs

#### Missing MFA
- No MFA option on sensitive accounts
- MFA bypass possible
- Weak MFA implementation (SMS only)

#### Insecure "Remember Me"
- Predictable tokens
- No expiration
- Token not invalidated on password change

#### Password Reset Flaws
- Weak reset tokens
- No token expiration
- Token reusable
- Reset link in URL (logged)

---

### Authorization Failures

#### Missing Access Checks
- Endpoint accessible without auth
- Function callable by any authenticated user
- Admin routes without role verification

#### IDOR (Insecure Direct Object Reference)
- Resource accessed by ID without ownership check
- User can access other users' data by changing ID
- No tenant isolation in multi-tenant apps

#### Privilege Escalation
- Vertical: user → admin
- Horizontal: user A → user B's data
- Via parameter tampering
- Via mass assignment

#### Client-Side Only Authorization
- Role check only in UI
- API doesn't verify permissions
- Hidden UI elements as security

#### Inconsistent Enforcement
- Checked on some endpoints, not others
- GET protected but POST not
- UI enforces, API doesn't

#### Mass Assignment
- User can set own role via request body
- Admin fields writable by users
- No allowlist for updateable fields

#### Path Traversal Past Auth
- ../admin bypasses route protection
- Parameter manipulation
- Encoded path traversal (%2e%2e)

---

### Session Management

#### Long/No Session Expiry
- Sessions never expire
- Very long timeout (days/weeks)
- No idle timeout

#### Session Persists After Logout
- Token still valid after logout
- Session not destroyed server-side
- Can replay old session

#### Tokens in URL
- Session ID in query parameter
- Leaked via Referer header
- Logged in access logs

#### Insecure Cookie Flags
- Missing `Secure` flag (sent over HTTP)
- Missing `HttpOnly` (accessible to JS)
- Missing `SameSite` (CSRF vulnerable)

#### JWT Vulnerabilities
- `alg: none` accepted
- Weak signing secret
- No expiration (`exp` claim)
- Sensitive data in payload
- `decode()` instead of `verify()`

---

## Anti-Patterns (Flag These)

### Direct Object Access Without Ownership

```python
# VULNERABLE - No ownership check
@app.get("/api/documents/{doc_id}")
def get_document(doc_id: str):
    return db.documents.find_one({"_id": doc_id})
```

```javascript
// VULNERABLE - Anyone can access any order
app.get('/api/orders/:id', async (req, res) => {
  const order = await Order.findById(req.params.id);
  res.json(order);
});
```

### Client-Side Authorization

```javascript
// VULNERABLE - Server never checks
if (user.role === 'admin') {
  showAdminPanel();
  // Admin API calls made directly, server trusts them
}
```

```tsx
// VULNERABLE - Role only in React state
{isAdmin && <AdminDashboard />}
// AdminDashboard makes API calls server doesn't protect
```

### Credential Enumeration

```python
# VULNERABLE - Reveals valid users
def login(email, password):
    user = get_user(email)
    if not user:
        return "User not found"  # Attacker learns this email doesn't exist
    if not check_password(password, user.password):
        return "Wrong password"  # Attacker learns email exists
```

### IDOR via Parameter

```python
# VULNERABLE - No ownership verification
@app.get("/api/users/{user_id}/profile")
def get_profile(user_id: int):
    return db.query(User).filter(User.id == user_id).first()
    # Attacker changes user_id to access any profile
```

### JWT Without Verification

```javascript
// VULNERABLE - decode != verify
const jwt = require('jsonwebtoken');
const payload = jwt.decode(token);  // Does NOT verify signature!
req.user = payload;
```

```python
# VULNERABLE - No algorithm restriction
payload = jwt.decode(token, SECRET_KEY)
# May accept alg:none if not explicitly forbidden
```

### Mass Assignment

```python
# VULNERABLE - User controls all fields
@app.put("/api/users/{user_id}")
def update_user(user_id: int, data: dict):
    user = get_user(user_id)
    for key, value in data.items():
        setattr(user, key, value)  # Can set role='admin'
    db.commit()
```

```javascript
// VULNERABLE - Spread operator copies everything
app.patch('/user', async (req, res) => {
  await User.updateOne({ _id: req.user.id }, { ...req.body });
  // req.body could contain { role: 'admin' }
});
```

### Role from Untrusted Source

```python
# VULNERABLE - Role from JWT payload (client-controlled if not verified)
@app.get("/admin")
def admin_panel():
    role = request.headers.get('X-User-Role')  # User sets this!
    if role == 'admin':
        return admin_data()
```

### Insecure Session Handling

```python
# VULNERABLE - Session ID in URL
redirect(f"/dashboard?session={session_id}")
# Leaked via Referer, browser history, logs
```

```javascript
// VULNERABLE - Cookie without security flags
res.cookie('session', sessionId);
// Missing: secure, httpOnly, sameSite
```

---

## Secure Patterns (Prefer These)

### Ownership Check

```python
# SECURE - Always verify ownership
@app.get("/api/documents/{doc_id}")
def get_document(doc_id: str, current_user: User = Depends(get_current_user)):
    doc = db.documents.find_one({"_id": doc_id})
    if not doc:
        raise HTTPException(404)
    if doc["owner_id"] != current_user.id:
        raise HTTPException(403, "Not authorized")
    return doc
```

```javascript
// SECURE - Filter by authenticated user
app.get('/api/orders/:id', authenticate, async (req, res) => {
  const order = await Order.findOne({
    _id: req.params.id,
    userId: req.user.id  // Ownership enforced in query
  });
  if (!order) return res.status(404).json({ error: 'Not found' });
  res.json(order);
});
```

### Consistent Auth Response

```python
# SECURE - Identical message prevents enumeration
def login(email, password):
    user = get_user(email)
    if not user or not check_password(password, user.password_hash):
        # Same message and timing for both cases
        time.sleep(random.uniform(0.1, 0.3))  # Prevent timing attack
        return {"error": "Invalid email or password"}
    return {"token": generate_token(user)}
```

### JWT with Full Verification

```javascript
// SECURE - Verify with algorithm allowlist
const jwt = require('jsonwebtoken');

const payload = jwt.verify(token, SECRET_KEY, {
  algorithms: ['HS256'],  // Explicitly allow only this algorithm
  issuer: 'myapp',
  audience: 'myapp-users',
});
```

```python
# SECURE - Explicit algorithm, require exp
payload = jwt.decode(
    token,
    SECRET_KEY,
    algorithms=["HS256"],  # Reject 'none' and others
    options={"require": ["exp", "iat"]}  # Require expiration
)
```

### Server-Side Role Enforcement

```python
# SECURE - Decorator enforces server-side
def require_role(role):
    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            user = get_current_user()
            if not user or user.role != role:
                raise HTTPException(403, "Forbidden")
            return func(*args, **kwargs)
        return wrapper
    return decorator

@app.post("/api/admin/users")
@require_role("admin")
def create_user(data: UserCreate):
    # Only admins reach here
    pass
```

### Safe Update with Allowlist

```python
# SECURE - Explicit allowlist of fields
ALLOWED_UPDATE_FIELDS = {"name", "email", "avatar_url"}

@app.put("/api/users/{user_id}")
def update_user(user_id: int, data: dict, current_user: User):
    if user_id != current_user.id:
        raise HTTPException(403)

    # Only update allowed fields
    update_data = {k: v for k, v in data.items() if k in ALLOWED_UPDATE_FIELDS}
    db.query(User).filter(User.id == user_id).update(update_data)
    db.commit()
```

### Secure Session Cookie

```javascript
// SECURE - All flags set
res.cookie('session', sessionId, {
  httpOnly: true,   // Not accessible via JavaScript
  secure: true,     // Only sent over HTTPS
  sameSite: 'lax',  // CSRF protection
  maxAge: 3600000,  // 1 hour expiry
  path: '/',
});
```

### Session Regeneration on Login

```python
# SECURE - New session ID after authentication
def login(credentials):
    user = authenticate(credentials)
    if user:
        session.regenerate()  # Invalidate old session ID
        session['user_id'] = user.id
        return success_response()
```

---

## Severity Guide

### Critical
- No authentication on sensitive endpoints
- Authentication bypass possible
- Privilege escalation to admin
- Passwords stored plaintext or weak hash
- JWT `alg: none` accepted

### High
- IDOR without ownership checks
- Mass assignment allows role change
- JWT weak secret or missing expiry
- Session doesn't invalidate on logout
- Missing rate limit on login (brute force possible)

### Medium
- Credential enumeration possible
- Weak password policy
- Long session timeout (>24h)
- Missing MFA on admin accounts
- SameSite cookie not set

### Low
- Missing `Secure` flag on non-sensitive cookie
- Verbose auth error messages (internal only)
- Session timeout > 8h but < 24h

---

## Quick Fixes

| Issue | Fix |
|-------|-----|
| Missing ownership check | Add `if resource.owner_id != user.id: raise 403` |
| No rate limiting | Add rate limiter: `slowapi`, `express-rate-limit` |
| Weak password hash | Use bcrypt/argon2 with cost ≥ 10 |
| JWT decode vs verify | Replace `decode()` with `verify()` + algorithms allowlist |
| Session fixation | Call `session.regenerate()` on login |
| IDOR | Filter queries: `WHERE owner_id = :current_user_id` |
| Mass assignment | Use explicit allowlist, never spread/merge directly |
| Missing cookie flags | Add `httpOnly`, `secure`, `sameSite` |
| Credential enumeration | Return identical response for all auth failures |
