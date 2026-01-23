# Vulnerable Dependencies

OWASP #6: Vulnerable and Outdated Components

Detecting known vulnerabilities in third-party libraries and frameworks.

---

## Detection Triggers

### Package Files

| Language | Files |
|----------|-------|
| JavaScript/Node | package.json, package-lock.json, yarn.lock, pnpm-lock.yaml |
| Python | requirements.txt, Pipfile, Pipfile.lock, poetry.lock, pyproject.toml |
| Ruby | Gemfile, Gemfile.lock |
| Go | go.mod, go.sum |
| Rust | Cargo.toml, Cargo.lock |
| Java | pom.xml, build.gradle, build.gradle.kts |
| PHP | composer.json, composer.lock |
| .NET | *.csproj, packages.config, paket.dependencies |

---

## Audit Commands

### JavaScript/Node

```bash
# npm
npm audit
npm audit --json  # Machine-readable output
npm audit fix     # Auto-fix where possible

# yarn
yarn audit
yarn audit --json

# pnpm
pnpm audit
```

### Python

```bash
# pip-audit (recommended)
pip install pip-audit
pip-audit

# safety
pip install safety
safety check -r requirements.txt

# Using pipenv
pipenv check
```

### Ruby

```bash
# bundler-audit
gem install bundler-audit
bundle audit check --update

# Or use bundle
bundle audit
```

### Go

```bash
# govulncheck (official)
go install golang.org/x/vuln/cmd/govulncheck@latest
govulncheck ./...

# nancy (for Sonatype OSS Index)
nancy sleuth -p Gopkg.lock
```

### Rust

```bash
# cargo-audit
cargo install cargo-audit
cargo audit

# cargo-deny (more comprehensive)
cargo install cargo-deny
cargo deny check
```

### Java

```bash
# OWASP Dependency-Check
mvn org.owasp:dependency-check-maven:check

# Gradle
gradle dependencyCheckAnalyze

# Snyk
snyk test
```

### PHP

```bash
# local-php-security-checker
local-php-security-checker

# Composer
composer audit
```

---

## Vulnerability Databases

| Database | URL | Coverage |
|----------|-----|----------|
| NVD | nvd.nist.gov | All |
| GitHub Advisory | github.com/advisories | Multi-language |
| npm Advisory | npmjs.com/advisories | JavaScript |
| PyPI Advisory | pypi.org/security | Python |
| RustSec | rustsec.org | Rust |
| OSV | osv.dev | Multi-language |

---

## Automated Scanning

### GitHub Dependabot

```yaml
# .github/dependabot.yml
version: 2
updates:
  - package-ecosystem: "npm"
    directory: "/"
    schedule:
      interval: "weekly"
    open-pull-requests-limit: 10

  - package-ecosystem: "pip"
    directory: "/"
    schedule:
      interval: "weekly"
```

### Snyk

```bash
# Install
npm install -g snyk

# Authenticate
snyk auth

# Test project
snyk test

# Monitor continuously
snyk monitor
```

### Trivy

```bash
# Scan filesystem
trivy fs .

# Scan with severity filter
trivy fs --severity HIGH,CRITICAL .

# Output formats
trivy fs --format json .
trivy fs --format sarif .
```

---

## What to Look For

### Severity Levels

**Critical (CVSS 9.0-10.0)**
- Remote code execution
- Authentication bypass
- SQL injection in ORM

**High (CVSS 7.0-8.9)**
- Denial of service
- Information disclosure
- Privilege escalation

**Medium (CVSS 4.0-6.9)**
- XSS vulnerabilities
- Open redirects
- Session issues

**Low (CVSS 0.1-3.9)**
- Minor information leaks
- Theoretical attacks

### Common Vulnerable Packages

#### JavaScript
- `lodash` < 4.17.21 - Prototype pollution
- `minimist` < 1.2.6 - Prototype pollution
- `axios` < 0.21.1 - SSRF
- `node-fetch` < 2.6.1 - Redirect handling
- `express` < 4.17.3 - Open redirect
- `jsonwebtoken` < 9.0.0 - Algorithm confusion

#### Python
- `pyyaml` < 5.4 - Arbitrary code execution
- `jinja2` < 2.11.3 - Sandbox escape
- `django` - Various (check version)
- `flask` < 2.0 - Various
- `pillow` - Image processing vulns
- `requests` < 2.20.0 - CRLF injection

#### Ruby
- `rails` - Various (version dependent)
- `nokogiri` - XML processing issues
- `rack` - Header injection

---

## Remediation Steps

### 1. Identify Vulnerable Package
```bash
npm audit
# Found: lodash@4.17.15 - Prototype Pollution (High)
```

### 2. Check Fix Availability
```bash
npm audit fix --dry-run
# Would update lodash to 4.17.21
```

### 3. Update Package
```bash
# Direct dependency
npm update lodash

# Or specific version
npm install lodash@4.17.21
```

### 4. Handle Transitive Dependencies
```bash
# If vulnerable package is a transitive dependency
npm ls lodash  # Find what depends on it

# Force resolution (npm)
# In package.json:
{
  "overrides": {
    "lodash": "4.17.21"
  }
}

# yarn
# In package.json:
{
  "resolutions": {
    "lodash": "4.17.21"
  }
}
```

### 5. If No Fix Available
- Check if vulnerable code path is used
- Consider alternative package
- Implement workaround
- Accept risk with documentation

---

## Report Format

```markdown
## Dependency Vulnerabilities

### Critical

#### CVE-2021-44228 - log4j Remote Code Execution
- **Package:** log4j-core
- **Installed:** 2.14.1
- **Fixed in:** 2.17.0
- **Description:** Remote code execution via JNDI lookup in log messages
- **Action:** Upgrade immediately

### High

#### CVE-2022-0235 - node-fetch SSRF
- **Package:** node-fetch
- **Installed:** 2.6.0
- **Fixed in:** 2.6.7
- **Description:** Improper handling of redirects can lead to SSRF
- **Action:** Update package

### Medium

(List medium severity findings)

### Summary
- Critical: 1
- High: 3
- Medium: 5
- Low: 12
- Total packages: 847
- Direct dependencies with vulnerabilities: 2
- Transitive dependencies with vulnerabilities: 7
```

---

## Severity Guide

### Critical
- Known exploited vulnerabilities (KEV)
- RCE in commonly used paths
- Auth bypass in auth libraries

### High
- RCE with specific conditions
- SQL injection in ORMs
- Significant data exposure

### Medium
- XSS in UI libraries
- DoS vulnerabilities
- Privilege escalation (limited)

### Low
- Theoretical vulnerabilities
- Requires local access
- Minimal impact

---

## Quick Fixes

| Issue | Fix |
|-------|-----|
| Outdated direct dep | `npm update <pkg>` or `pip install --upgrade <pkg>` |
| Outdated transitive | Use `overrides` / `resolutions` in package.json |
| No fix available | Evaluate risk, consider alternative, document decision |
| Many outdated | Run `npm audit fix` or `pip-audit --fix` |

## Prevention

1. **Enable Dependabot** on GitHub repositories
2. **Run audits in CI/CD** - fail builds on high/critical
3. **Regular update schedule** - weekly minor, monthly major
4. **Lock files committed** - reproducible builds
5. **Review before merge** - understand what's changing
