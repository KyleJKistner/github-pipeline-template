# Pull Request Checklist Details

This document provides detailed guidance for the PR checklist items.

## PR Title Format

Your PR title MUST follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <description>
```

### Valid Types

| Type | When to Use |
|------|-------------|
| `feat` | New feature or capability |
| `fix` | Bug fix |
| `docs` | Documentation only |
| `style` | Formatting, no code change |
| `refactor` | Code restructuring, no behavior change |
| `perf` | Performance improvement |
| `test` | Adding or updating tests |
| `build` | Build system or dependencies |
| `ci` | CI/CD configuration |
| `chore` | Maintenance tasks |

### Examples

- `feat(auth): add password reset flow`
- `fix(api): handle null response gracefully`
- `docs: update installation instructions`
- `refactor(utils): simplify date formatting`

## Code Quality

### Style Guide Compliance

- [ ] Code follows naming conventions
- [ ] No commented-out code
- [ ] No debug statements (console.log, print, etc.)
- [ ] Error handling is appropriate
- [ ] No hardcoded values that should be configurable

### Self-Review Questions

Before requesting review, ask yourself:

1. Would I understand this code in 6 months?
2. Is there any duplicated logic that should be extracted?
3. Are edge cases handled?
4. Are error messages helpful?
5. Is the code testable?

## Testing Requirements

### What to Test

- [ ] Happy path scenarios
- [ ] Edge cases and boundary conditions
- [ ] Error handling paths
- [ ] Integration points (if applicable)

### Coverage

- New code should be covered by tests
- Bug fixes should include a test that would have caught the bug
- Aim for 80%+ coverage on new code

## Documentation

### When to Update Docs

- [ ] New feature? Update relevant docs
- [ ] API change? Update API documentation
- [ ] Configuration change? Update setup docs
- [ ] Breaking change? Update migration guide

### What to Document

- Public APIs and their parameters
- Configuration options
- Environment variables
- Setup or installation steps

## Security Considerations

### Before Submitting

- [ ] No secrets, API keys, or credentials in code
- [ ] No sensitive data in logs or error messages
- [ ] Input validation for user-provided data
- [ ] Dependencies are from trusted sources
- [ ] No new dependencies with known vulnerabilities

## Breaking Changes

If your change is breaking:

1. Use `!` in the type: `feat!: remove deprecated API`
2. Include `BREAKING CHANGE:` in the PR body
3. Document migration steps
4. Consider deprecation period if possible

## Large PRs

If your PR is large (>500 lines changed):

- Consider splitting into smaller PRs
- Provide extra context in description
- Highlight the most critical parts for review
- Offer to walk through changes with reviewer
