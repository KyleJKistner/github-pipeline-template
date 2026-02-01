# Contributing

Thank you for your interest in contributing! This guide will help you get started.

## Quick Start

```bash
# Clone the repository
git clone https://github.com/your-org/your-repo.git
cd your-repo

# Set up development environment
make bootstrap

# Run the CI pipeline locally
make ci
```

## Development Workflow

### 1. Create a Branch

Create a feature branch from `main`:

```bash
git checkout main
git pull origin main
git checkout -b feat/your-feature-name
```

Branch naming convention:
- `feat/description` - New features
- `fix/description` - Bug fixes
- `docs/description` - Documentation
- `chore/description` - Maintenance

### 2. Make Changes

Write your code following our [style guide](docs/style_guide.md).

Run checks locally before pushing:

```bash
make ci
```

This runs the same checks as the CI pipeline:
1. Format check (`make fmt-check`)
2. Lint (`make lint`)
3. Test (`make test`)
4. Build (`make build`)

### 3. Commit Changes

We don't enforce commit message format for individual commits, but we recommend keeping them clear and atomic.

### 4. Create a Pull Request

**Important**: PR titles must follow [Conventional Commits](https://www.conventionalcommits.org/) format because we use squash merges.

Format: `<type>(<scope>): <description>`

Examples:
- `feat(auth): add OAuth2 login support`
- `fix(api): handle null response gracefully`
- `docs: update installation instructions`
- `refactor(utils): simplify date formatting`

Types:
| Type | Description | Version Bump |
|------|-------------|--------------|
| `feat` | New feature | MINOR |
| `fix` | Bug fix | PATCH |
| `docs` | Documentation | PATCH |
| `style` | Formatting | PATCH |
| `refactor` | Code restructuring | PATCH |
| `perf` | Performance | PATCH |
| `test` | Tests | PATCH |
| `build` | Build system | PATCH |
| `ci` | CI config | PATCH |
| `chore` | Maintenance | PATCH |

For breaking changes, add `!` after the type: `feat!: remove deprecated API`

### 5. Code Review

- All PRs require at least one approval
- Address review feedback
- Keep discussions constructive

### 6. Merge

Once approved and CI passes:
- Squash merge is used
- PR title becomes the commit message
- Branch is automatically deleted

## Available Commands

| Command | Description |
|---------|-------------|
| `make bootstrap` | Set up development environment |
| `make fmt` | Apply code formatting |
| `make fmt-check` | Check formatting without changes |
| `make lint` | Run linter and type checker |
| `make test` | Run tests with coverage |
| `make build` | Build artifacts |
| `make ci` | Run full CI pipeline |
| `make clean` | Remove generated files |
| `make help` | Show all commands |

## Testing

See [docs/testing_policy.md](docs/testing_policy.md) for testing requirements.

Key points:
- Minimum 80% code coverage
- Write tests for new features
- Bug fixes should include regression tests

Run tests:

```bash
make test
```

View coverage report:

```bash
# After running tests
open artifacts/coverage/index.html  # or html/index.html for Python
```

## Code Style

See [docs/style_guide.md](docs/style_guide.md) for detailed guidelines.

Key points:
- Use the project formatter (`make fmt`)
- Follow naming conventions
- Handle errors explicitly
- Never commit secrets

## Documentation

- Update docs when adding features
- Use clear, concise language
- Include code examples where helpful
- Keep README.md up to date

## Release Process

See [docs/release_process.md](docs/release_process.md) for how releases work.

Key points:
- Releases are automated via Release Please
- Version bumps are determined by PR titles
- CHANGELOG.md is auto-generated

## Security

See [SECURITY.md](SECURITY.md) for security policy.

Key points:
- Report vulnerabilities privately
- Never commit secrets or credentials
- Keep dependencies updated

## Getting Help

- Check existing issues and discussions
- Create a new issue if needed
- Be specific about your environment and problem

## Code of Conduct

Please read our [Code of Conduct](CODE_OF_CONDUCT.md). We are committed to providing a welcoming and inclusive environment.
