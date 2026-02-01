# Project Name

<!-- Brief description of the project -->

A brief description of what this project does and why it exists.

## Features

- Feature 1
- Feature 2
- Feature 3

## Quick Start

```bash
# Clone the repository
git clone https://github.com/your-org/your-repo.git
cd your-repo

# Set up development environment
make bootstrap

# Run the CI pipeline
make ci
```

## Installation

### Prerequisites

- **Node.js 20+** or **Python 3.11+** (depending on project type)
- **Make** (included on most Unix systems)

### Setup

```bash
# Install dependencies
make bootstrap
```

## Usage

<!-- Add usage examples here -->

```bash
# Example command
npm start
# or
python main.py
```

## Development

### Available Commands

```bash
make bootstrap    # Set up development environment
make fmt          # Apply code formatting
make fmt-check    # Check formatting (no changes)
make lint         # Run linter and type checker
make test         # Run tests with coverage
make build        # Build artifacts
make ci           # Run full CI pipeline
make clean        # Remove generated files
make help         # Show all commands
```

### Running Tests

```bash
make test
```

Coverage reports are generated in `artifacts/coverage/`.

### Code Style

This project uses automated formatting and linting. Run `make fmt` before committing.

See [docs/style_guide.md](docs/style_guide.md) for detailed guidelines.

## Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

### Branch Naming

- `feat/description` - New features
- `fix/description` - Bug fixes
- `docs/description` - Documentation
- `chore/description` - Maintenance

### PR Titles

PR titles must follow [Conventional Commits](https://www.conventionalcommits.org/):

```
feat(scope): add new feature
fix(scope): resolve bug
docs: update readme
```

## Releases

This project uses [Release Please](https://github.com/googleapis/release-please) for automated releases.

- Merging to `main` updates the release PR
- Merging the release PR creates a new release
- Version bumps are determined by commit types

See [docs/release_process.md](docs/release_process.md) for details.

## AI Code Review

This project uses [Greptile](https://greptile.com) for AI-powered code review.

To skip AI review on a PR, add the `skip-ai-review` label.

## Documentation

| Document | Description |
|----------|-------------|
| [Style Guide](docs/style_guide.md) | Coding standards and conventions |
| [Testing Policy](docs/testing_policy.md) | Test requirements and coverage |
| [Release Process](docs/release_process.md) | How releases work |
| [Security Baseline](docs/security_baseline.md) | Security practices |
| [ADRs](docs/adr/) | Architecture Decision Records |

## Security

Please see [SECURITY.md](SECURITY.md) for:
- Security policy
- How to report vulnerabilities
- Supported versions

## License

This project is licensed under the MIT License - see [LICENSE](LICENSE) for details.

## Acknowledgments

- List any acknowledgments here

---

## Template Usage

This repository was created using the [GitHub Pipeline Template](https://github.com/your-org/github-pipeline-template).

### Customizing the Template

After creating a repository from this template:

1. **Update this README** - Replace placeholder text with your project details

2. **Configure CODEOWNERS** - Edit `.github/CODEOWNERS` with your GitHub usernames

3. **Choose your language** - The template auto-detects Node.js or Python:
   - For Node.js: Add `package.json`
   - For Python: Add `pyproject.toml` or `requirements.txt`

4. **Update LICENSE** - Replace `[year]` and `[fullname]` placeholders

5. **Configure Release Please** - Edit `.github/workflows/release-please.yml`:
   - For Node.js: `release-type: node`
   - For Python: `release-type: python`
   - For generic: `release-type: simple`

6. **Set up branch protection** - See below

### Required GitHub Settings

After creating your repository:

#### Merge Methods
- [ ] Disable merge commits
- [ ] Disable rebase merges (optional)
- [x] Enable squash merges only
- [x] Default to PR title for squash commits
- [x] Automatically delete head branches

#### Branch Protection for `main`
- [x] Require pull request before merging
- [x] Require 1+ approvals
- [x] Dismiss stale approvals on new commits
- [x] Require CODEOWNERS review
- [x] Require conversation resolution
- [x] Require status checks:
  - `CI Pipeline`
  - `Validate PR Title`
  - `Dependency Review`
  - `Actionlint`
  - `Repository Hygiene`
- [x] Require branches to be up to date
- [x] Require linear history

#### For CodeQL on Private Repos
- Set repository variable: `CODEQL_ENABLED=true`
- Requires GitHub Advanced Security license

#### For Greptile (Optional)
1. Install Greptile GitHub App
2. Grant repository access
3. Optionally add `greptile` to required status checks
