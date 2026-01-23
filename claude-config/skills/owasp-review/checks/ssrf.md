# Server-Side Request Forgery (SSRF)

OWASP #10: Server-Side Request Forgery

SSRF occurs when an attacker can make the server perform requests to unintended locations, potentially accessing internal services, cloud metadata, or sensitive resources.

---

## Vulnerabilities to Detect

### User-Controlled URLs

#### Direct URL from User Input
```python
# VULNERABLE - User controls entire URL
url = request.args.get('url')
response = requests.get(url)
return response.content
```

```javascript
// VULNERABLE
const url = req.query.url;
const response = await fetch(url);
```

#### URL in Request Body
```python
# VULNERABLE - URL from POST body
data = request.json
image_url = data['image_url']
image = requests.get(image_url).content
```

### URL Parameters for Redirects

#### Open Redirect with Server Fetch
```python
# VULNERABLE - Redirect URL fetched server-side
@app.route('/proxy')
def proxy():
    target = request.args.get('target')
    return requests.get(target).text
```

#### Webhook URLs
```python
# VULNERABLE - User provides webhook URL
webhook_url = user_settings['webhook_url']
requests.post(webhook_url, json=event_data)
# Attacker sets webhook to internal service
```

### Partial URL Control

#### Path Injection
```python
# VULNERABLE - User controls path
base_url = "https://api.example.com"
endpoint = request.args.get('endpoint')
response = requests.get(f"{base_url}/{endpoint}")
# endpoint = "../../internal-service" or "@attacker.com"
```

#### Hostname from User
```python
# VULNERABLE - User controls subdomain/host
subdomain = request.args.get('tenant')
url = f"https://{subdomain}.internal.corp/api"
# subdomain = "evil.com#" or "internal-admin"
```

### File Protocol Access

#### file:// URLs
```python
# VULNERABLE - May allow file:// protocol
url = request.args.get('url')
response = urllib.request.urlopen(url)
# url = "file:///etc/passwd"
```

### Cloud Metadata Access

#### AWS Metadata
```python
# VULNERABLE - Can access metadata service
url = request.args.get('url')
# url = "http://169.254.169.254/latest/meta-data/iam/security-credentials/"
response = requests.get(url)
# Returns AWS credentials
```

### DNS Rebinding

#### No DNS Validation
```python
# VULNERABLE - DNS can change between check and use
url = request.args.get('url')
parsed = urlparse(url)
# Check: example.com resolves to public IP
if is_public_ip(socket.gethostbyname(parsed.hostname)):
    # By request time, DNS may point to 127.0.0.1
    response = requests.get(url)
```

---

## Secure Patterns

### URL Allowlisting

```python
# SECURE - Only allowed domains
ALLOWED_DOMAINS = {'api.example.com', 'cdn.example.com'}

def fetch_url(url: str) -> bytes:
    parsed = urlparse(url)

    if parsed.hostname not in ALLOWED_DOMAINS:
        raise ValueError(f"Domain not allowed: {parsed.hostname}")

    if parsed.scheme not in ('http', 'https'):
        raise ValueError(f"Scheme not allowed: {parsed.scheme}")

    return requests.get(url).content
```

### IP Address Validation

```python
# SECURE - Block internal IPs
import ipaddress
import socket

def is_safe_url(url: str) -> bool:
    parsed = urlparse(url)

    # Only allow http/https
    if parsed.scheme not in ('http', 'https'):
        return False

    # Resolve hostname
    try:
        ip = socket.gethostbyname(parsed.hostname)
        ip_obj = ipaddress.ip_address(ip)
    except (socket.gaierror, ValueError):
        return False

    # Block private/internal IPs
    if ip_obj.is_private or ip_obj.is_loopback or ip_obj.is_link_local:
        return False

    # Block cloud metadata IPs
    if ip in ('169.254.169.254', '169.254.170.2'):
        return False

    return True

def safe_fetch(url: str) -> bytes:
    if not is_safe_url(url):
        raise ValueError("URL not allowed")
    return requests.get(url, allow_redirects=False).content
```

### Redirect Handling

```python
# SECURE - Validate after redirects
def safe_fetch_with_redirects(url: str, max_redirects: int = 5) -> bytes:
    for _ in range(max_redirects):
        if not is_safe_url(url):
            raise ValueError(f"Redirect to unsafe URL: {url}")

        response = requests.get(url, allow_redirects=False)

        if response.status_code in (301, 302, 303, 307, 308):
            url = response.headers.get('Location')
            if not url:
                raise ValueError("Redirect without Location header")
            continue

        return response.content

    raise ValueError("Too many redirects")
```

### DNS Rebinding Protection

```python
# SECURE - Pin IP after resolution
import socket
import requests
from urllib.parse import urlparse

def fetch_with_pinned_dns(url: str) -> bytes:
    parsed = urlparse(url)

    # Resolve once and validate
    ip = socket.gethostbyname(parsed.hostname)
    if not is_safe_ip(ip):
        raise ValueError(f"Unsafe IP: {ip}")

    # Make request directly to IP with Host header
    ip_url = url.replace(parsed.hostname, ip)

    return requests.get(
        ip_url,
        headers={'Host': parsed.hostname},
        verify=True  # Still verify SSL with hostname
    ).content
```

### Request Restrictions

```python
# SECURE - Restrict request capabilities
import requests

def restricted_fetch(url: str) -> bytes:
    if not is_safe_url(url):
        raise ValueError("URL not allowed")

    response = requests.get(
        url,
        allow_redirects=False,  # Handle redirects manually
        timeout=10,             # Prevent slow responses
        stream=True,            # Don't load huge responses
    )

    # Limit response size
    max_size = 10 * 1024 * 1024  # 10MB
    content = response.raw.read(max_size + 1)
    if len(content) > max_size:
        raise ValueError("Response too large")

    return content
```

### Webhook Validation

```python
# SECURE - Validate webhook URLs
def set_webhook(user_id: str, webhook_url: str):
    # Must be HTTPS
    parsed = urlparse(webhook_url)
    if parsed.scheme != 'https':
        raise ValueError("Webhook must use HTTPS")

    # Must not be internal
    if not is_safe_url(webhook_url):
        raise ValueError("Internal URLs not allowed")

    # Verify ownership (optional but recommended)
    # Send verification request with challenge
    challenge = secrets.token_urlsafe(32)
    try:
        response = requests.post(
            webhook_url,
            json={'challenge': challenge},
            timeout=5
        )
        if response.json().get('challenge') != challenge:
            raise ValueError("Webhook verification failed")
    except Exception:
        raise ValueError("Could not verify webhook URL")

    save_webhook(user_id, webhook_url)
```

---

## Internal Services to Protect

### Cloud Metadata
```
169.254.169.254  - AWS, GCP, Azure metadata
169.254.170.2    - AWS ECS metadata
fd00:ec2::254    - AWS IPv6 metadata
```

### Internal Networks
```
127.0.0.0/8      - Loopback
10.0.0.0/8       - Private (Class A)
172.16.0.0/12    - Private (Class B)
192.168.0.0/16   - Private (Class C)
::1              - IPv6 loopback
fc00::/7         - IPv6 private
```

### Common Internal Services
```
localhost:6379   - Redis
localhost:5432   - PostgreSQL
localhost:3306   - MySQL
localhost:27017  - MongoDB
localhost:9200   - Elasticsearch
localhost:8500   - Consul
```

---

## Severity Guide

### Critical
- Attacker can access cloud metadata (credentials exposure)
- Full URL control to any internal service
- Access to internal admin panels
- File:// protocol allowed

### High
- Access to internal network services
- DNS rebinding possible
- Unrestricted redirect following

### Medium
- Partial URL control (path only)
- Limited protocol options
- Webhook URLs to internal services

### Low
- SSRF with limited impact (port scan only)
- Validated domains but potential bypass

---

## Quick Fixes

| Issue | Fix |
|-------|-----|
| User-controlled URL | Allowlist specific domains |
| No IP validation | Block private/loopback/link-local ranges |
| Following redirects | `allow_redirects=False`, validate each hop |
| Cloud metadata access | Block 169.254.169.254 explicitly |
| file:// allowed | Enforce `scheme in ('http', 'https')` |
| DNS rebinding | Resolve once, pin IP, validate before use |
| Webhook URLs | Require HTTPS, block internal IPs, verify ownership |
