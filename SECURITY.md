# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| latest  | :white_check_mark: |

## Reporting a Vulnerability

We take security vulnerabilities seriously. If you discover a security issue,
please report it responsibly.

### How to Report

1. **Do not** open a public GitHub issue for security vulnerabilities
2. Use [GitHub Security Advisories](https://docs.github.com/en/code-security/security-advisories/guidance-on-reporting-and-writing/privately-reporting-a-security-vulnerability) to report privately
3. Include as much detail as possible:
   - Description of the vulnerability
   - Steps to reproduce
   - Potential impact
   - Suggested fix (if any)

### What to Expect

- **Acknowledgment**: Within 48 hours of your report
- **Initial Assessment**: Within 7 days
- **Resolution Timeline**: Depends on severity
  - Critical: 24-72 hours
  - High: 7 days
  - Medium: 30 days
  - Low: 90 days

### Disclosure Policy

- We follow coordinated disclosure practices
- We will credit reporters in release notes (unless anonymity is requested)
- We ask that you give us reasonable time to address issues before public disclosure

## Security Best Practices

This repository follows security best practices:

- All GitHub Actions are pinned to full commit SHAs
- Minimal permissions are used in CI/CD workflows
- Dependencies are automatically updated via Dependabot
- Code is scanned with CodeQL (when enabled)
- Dependency vulnerabilities are checked on every PR

## Security Controls

See [docs/security_baseline.md](docs/security_baseline.md) for detailed information about:

- CI/CD security measures
- Dependency management
- Access controls
- Threat model
