# Security Misconfiguration

OWASP #5: Security Misconfiguration

Insecure default configurations, incomplete setups, open cloud storage, misconfigured HTTP headers, verbose errors, and unnecessary features enabled.

---

## Vulnerabilities to Detect

### Debug Mode in Production

#### Flask/Django Debug
```python
# VULNERABLE - Debug in production
app.run(debug=True)
DEBUG = True  # in settings.py
```

#### Express/Node Debug
```javascript
// VULNERABLE - Detailed errors exposed
app.use(errorHandler({ dumpExceptions: true, showStack: true }));
```

#### Stack Traces Exposed
```python
# VULNERABLE - Full traceback to client
@app.errorhandler(Exception)
def handle_error(e):
    return traceback.format_exc(), 500
```

### Missing Security Headers

#### No Content-Security-Policy
```
# MISSING - Allows XSS, clickjacking
Content-Security-Policy: default-src 'self'
```

#### No X-Frame-Options
```
# MISSING - Clickjacking possible
X-Frame-Options: DENY
```

#### No X-Content-Type-Options
```
# MISSING - MIME sniffing attacks
X-Content-Type-Options: nosniff
```

### CORS Misconfiguration

#### Wildcard Origin
```python
# VULNERABLE - Any origin allowed
CORS(app, origins="*")
```

```javascript
// VULNERABLE
app.use(cors({ origin: '*' }));
```

#### Reflecting Origin
```python
# VULNERABLE - Reflects any origin
@app.after_request
def add_cors(response):
    response.headers['Access-Control-Allow-Origin'] = request.headers.get('Origin')
    response.headers['Access-Control-Allow-Credentials'] = 'true'
    return response
# Attacker's origin gets access with credentials
```

#### Credentials with Wildcard
```javascript
// VULNERABLE - Invalid but sometimes misconfigured
res.header('Access-Control-Allow-Origin', '*');
res.header('Access-Control-Allow-Credentials', 'true');
```

### Exposed Admin/Debug Endpoints

#### Debug Routes
```python
# VULNERABLE - Debug endpoint in production
@app.route('/debug/info')
def debug_info():
    return jsonify({
        'env': dict(os.environ),
        'config': app.config
    })
```

#### Unsecured Admin
```javascript
// VULNERABLE - Admin without auth
app.get('/admin/users', (req, res) => {
    return db.users.find({});  // No auth check
});
```

#### Swagger/API Docs Exposed
```python
# VULNERABLE - API docs in production without auth
# /swagger, /api-docs, /graphql accessible
```

### Default Credentials

#### Unchanged Defaults
```python
# VULNERABLE
ADMIN_PASSWORD = "admin"
DATABASE_PASSWORD = "password"
SECRET_KEY = "change-me"
```

#### Default Keys in Config
```yaml
# VULNERABLE
jwt_secret: "your-secret-key"
api_key: "default-api-key"
```

### Unnecessary Features Enabled

#### Directory Listing
```apache
# VULNERABLE - Lists directory contents
Options +Indexes
```

#### Unnecessary HTTP Methods
```
# VULNERABLE - TRACE, TRACK enabled
Allow: GET, POST, PUT, DELETE, TRACE, OPTIONS
```

### Verbose Error Messages

#### Database Errors Exposed
```python
# VULNERABLE
except DatabaseError as e:
    return {"error": str(e)}, 500
# Exposes: "relation 'users' does not exist"
```

#### File Paths Exposed
```javascript
// VULNERABLE
catch (err) {
    res.status(500).json({ error: err.message, stack: err.stack });
}
// Exposes: "/home/app/src/controllers/user.js:42"
```

---

## Secure Patterns

### Production Configuration

```python
# SECURE - Environment-based config
import os

DEBUG = os.environ.get('FLASK_ENV') == 'development'
SECRET_KEY = os.environ['SECRET_KEY']  # Required, no default

if not DEBUG:
    # Production checks
    assert SECRET_KEY != 'change-me'
    assert len(SECRET_KEY) >= 32
```

### Security Headers

```python
# SECURE - Flask-Talisman or manual headers
from flask_talisman import Talisman

Talisman(app,
    content_security_policy={
        'default-src': "'self'",
        'script-src': "'self'",
        'style-src': "'self'"
    },
    force_https=True
)
```

```javascript
// SECURE - Helmet.js for Express
const helmet = require('helmet');
app.use(helmet());  // Sets secure defaults

// Or manually:
app.use((req, res, next) => {
    res.setHeader('X-Content-Type-Options', 'nosniff');
    res.setHeader('X-Frame-Options', 'DENY');
    res.setHeader('X-XSS-Protection', '1; mode=block');
    res.setHeader('Strict-Transport-Security', 'max-age=31536000; includeSubDomains');
    res.setHeader('Content-Security-Policy', "default-src 'self'");
    next();
});
```

### CORS Configuration

```python
# SECURE - Explicit allowed origins
CORS(app, origins=[
    "https://myapp.com",
    "https://admin.myapp.com"
], supports_credentials=True)
```

```javascript
// SECURE - Whitelist approach
const allowedOrigins = ['https://myapp.com', 'https://admin.myapp.com'];

app.use(cors({
    origin: (origin, callback) => {
        if (!origin || allowedOrigins.includes(origin)) {
            callback(null, true);
        } else {
            callback(new Error('Not allowed by CORS'));
        }
    },
    credentials: true
}));
```

### Error Handling

```python
# SECURE - Generic errors in production
@app.errorhandler(Exception)
def handle_error(e):
    app.logger.error(f"Error: {e}", exc_info=True)  # Log full details

    if app.debug:
        return {"error": str(e)}, 500
    else:
        return {"error": "An internal error occurred"}, 500  # Generic message
```

```javascript
// SECURE - Sanitized error responses
app.use((err, req, res, next) => {
    console.error(err.stack);  // Log full error

    res.status(500).json({
        error: process.env.NODE_ENV === 'production'
            ? 'Internal server error'
            : err.message
    });
});
```

### Protected Admin Routes

```python
# SECURE - Admin routes require auth + role
@app.route('/admin/users')
@login_required
@admin_required
def admin_users():
    return get_all_users()

# Disable debug endpoints in production
if not app.debug:
    @app.route('/debug/<path:path>')
    def block_debug(path):
        abort(404)
```

---

## Configuration Checklist

### Required Headers
```
Content-Security-Policy: default-src 'self'; script-src 'self'; style-src 'self'
X-Frame-Options: DENY
X-Content-Type-Options: nosniff
Strict-Transport-Security: max-age=31536000; includeSubDomains
X-XSS-Protection: 1; mode=block
Referrer-Policy: strict-origin-when-cross-origin
Permissions-Policy: geolocation=(), microphone=(), camera=()
```

### Production Checklist
- [ ] DEBUG = False
- [ ] Secret key from environment, not default
- [ ] HTTPS enforced
- [ ] Security headers set
- [ ] CORS restricted to specific origins
- [ ] Error messages sanitized
- [ ] Stack traces not exposed
- [ ] Admin endpoints protected
- [ ] Debug endpoints disabled/removed
- [ ] Directory listing disabled
- [ ] Unnecessary HTTP methods disabled

---

## Severity Guide

### Critical
- Debug mode in production with sensitive data exposure
- Admin endpoint without authentication
- Credentials/secrets in error messages
- CORS allows any origin with credentials

### High
- Debug mode enabled (stack traces visible)
- Missing Content-Security-Policy
- Wildcard CORS origin
- Default credentials unchanged

### Medium
- Missing X-Frame-Options
- Missing HSTS header
- Verbose database errors
- API documentation exposed without auth

### Low
- Missing X-Content-Type-Options
- Slightly verbose error messages
- Missing Referrer-Policy

---

## Quick Fixes

| Issue | Fix |
|-------|-----|
| Debug mode on | Set `DEBUG=False` in production |
| No security headers | Add `helmet` (Node) or `flask-talisman` (Python) |
| CORS wildcard | Specify explicit allowed origins list |
| Stack traces | Return generic error, log full details server-side |
| Default secret | Generate: `python -c "import secrets; print(secrets.token_hex(32))"` |
| Exposed admin | Add `@login_required` and `@admin_required` decorators |
| No CSP | Start with `default-src 'self'` and expand as needed |
