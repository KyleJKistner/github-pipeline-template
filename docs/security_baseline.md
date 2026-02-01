# Security Baseline

This document outlines security controls and practices for this project.

## Threat Model

### Assets to Protect

| Asset | Sensitivity | Protection |
|-------|------------|------------|
| Source code | Medium | Access controls, signed commits |
| CI/CD secrets | High | GitHub Secrets, least privilege |
| Dependencies | Medium | Dependabot, vulnerability scanning |
| Release artifacts | High | Signed releases, provenance |

### Threat Actors

| Actor | Motivation | Mitigation |
|-------|-----------|------------|
| External attackers | Data theft, disruption | Access controls, vulnerability scanning |
| Supply chain attacks | Compromise via dependencies | Dependency review, pinned versions |
| Malicious contributors | Code injection via PRs | PR review, branch protection |
| Compromised maintainer | Unauthorized releases | Required reviews, signed commits |

### Attack Vectors

1. **Malicious PR** - Attacker submits PR with malicious code
   - Mitigation: Required reviews, CI checks, CODEOWNERS

2. **Dependency confusion** - Attacker publishes malicious package
   - Mitigation: Dependency review, lockfiles, scoped packages

3. **CI/CD exploitation** - Attacker exploits workflow vulnerabilities
   - Mitigation: Minimal permissions, pinned actions, no secrets in logs

4. **Stolen credentials** - Attacker obtains maintainer credentials
   - Mitigation: 2FA, signed commits, branch protection

## CI/CD Security

### Workflow Permissions

**Principle**: Least privilege by default.

```yaml
# Default to minimal permissions
permissions:
  contents: read

jobs:
  build:
    runs-on: ubuntu-latest
    # Elevate only what's needed for this job
    permissions:
      contents: read
      packages: write  # Only if publishing packages
```

### Action Pinning

**All actions MUST be pinned to full SHA**, not tags:

```yaml
# Good - immutable reference
- uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v4.2.2

# Bad - mutable tag
- uses: actions/checkout@v4
```

**Why**: Tags can be moved to point to different code. SHAs are immutable.

### Dangerous Patterns to Avoid

| Pattern | Risk | Alternative |
|---------|------|-------------|
| `pull_request_target` + checkout PR | Code execution from forks | Use `pull_request` or careful isolation |
| Secrets in logs | Credential exposure | Use `add-mask`, avoid echo |
| `${{ github.event.*.body }}` | Script injection | Use environment variables |
| Broad `permissions: write-all` | Excessive access | Specify only needed permissions |

### Fork PR Security

For workflows triggered by fork PRs:

1. Never checkout untrusted code with secrets available
2. Use `pull_request` (not `pull_request_target`) when possible
3. If `pull_request_target` is needed, only checkout trusted code (main branch)

## Dependency Management

### Dependabot Configuration

Dependabot is configured to:
- Update GitHub Actions weekly
- Update npm/pip dependencies weekly
- Group minor updates to reduce PR noise
- Use Conventional Commit prefixes

### Dependency Review

Every PR is scanned for:
- Known vulnerabilities (fail on HIGH severity)
- License compliance (block GPL-3.0, AGPL-3.0)

### Lockfiles

- **Always commit lockfiles** (package-lock.json, pnpm-lock.yaml, etc.)
- CI uses `npm ci` / `pnpm install --frozen-lockfile` for reproducibility
- Review lockfile changes in PRs

### Vulnerability Response

| Severity | Response Time | Action |
|----------|--------------|--------|
| Critical | 24 hours | Immediate patch or mitigation |
| High | 7 days | Prioritize fix |
| Medium | 30 days | Schedule fix |
| Low | 90 days | Address when convenient |

## Code Scanning

### CodeQL (When Enabled)

CodeQL scans for:
- Security vulnerabilities
- Code quality issues
- Best practice violations

**Enabled by default** for public repositories.

**For private repositories**: Set `vars.CODEQL_ENABLED=true` (requires GitHub Advanced Security license).

### What Gets Scanned

- All pushes to main
- All pull requests
- Weekly scheduled scan (catches new vulnerability patterns)

## Secrets Management

### GitHub Secrets

- Store all sensitive values in GitHub Secrets
- Use environment-scoped secrets for deployment credentials
- Rotate secrets periodically

### Never Commit Secrets

If secrets are accidentally committed:

1. **Immediately** rotate the compromised credentials
2. Remove from git history (use `git filter-branch` or BFG)
3. Force push (requires temporary bypass of branch protection)
4. Audit for unauthorized access

### Secret Scanning

GitHub automatically scans for:
- API keys
- Tokens
- Passwords
- Private keys

Enable push protection to block commits containing secrets.

## Branch Protection

### Required Settings for `main`

| Setting | Value | Rationale |
|---------|-------|-----------|
| Require PR | Yes | No direct pushes |
| Required approvals | 1+ | Peer review |
| Dismiss stale approvals | Yes | Re-review after changes |
| Require status checks | Yes | CI must pass |
| Require up-to-date | Yes | Test against latest main |
| Require linear history | Yes | Clean git history |
| Restrict force push | Yes | Prevent history rewriting |
| Restrict deletion | Yes | Prevent accidental deletion |

### Optional but Recommended

| Setting | Benefit |
|---------|---------|
| Require signed commits | Verify committer identity |
| Require CODEOWNERS review | Ensure domain experts review |
| Include administrators | No bypassing for anyone |

## Incident Response

### If a Vulnerability is Discovered

1. **Assess** - Determine severity and scope
2. **Contain** - Limit exposure (disable feature, revoke access)
3. **Fix** - Develop and test patch
4. **Deploy** - Release fix through normal (expedited) process
5. **Communicate** - Notify affected parties per disclosure policy
6. **Review** - Post-incident analysis and improvements

### Security Contact

Report vulnerabilities to: `[security-email@example.com]`

See [SECURITY.md](../SECURITY.md) for full disclosure policy.

## Audit Checklist

Periodic security review:

- [ ] All actions pinned to SHA
- [ ] Minimal workflow permissions
- [ ] Dependabot enabled and running
- [ ] Branch protection configured
- [ ] No secrets in logs or code
- [ ] CodeQL enabled (if applicable)
- [ ] CODEOWNERS file current
- [ ] Security policy up to date
