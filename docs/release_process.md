# Release Process

This document describes how releases are managed in this project.

## Overview

We use [Release Please](https://github.com/googleapis/release-please) for automated releases based on [Conventional Commits](https://www.conventionalcommits.org/).

### How It Works

```
1. Develop on feature branch
2. Create PR with Conventional Commit title
3. Merge to main (squash merge)
4. Release Please creates/updates release PR
5. Merge release PR to publish release
```

## Conventional Commits

### Format

```
<type>(<scope>): <description>

[optional body]

[optional footer(s)]
```

### Types

| Type | Description | Version Bump |
|------|-------------|--------------|
| `feat` | New feature | MINOR |
| `fix` | Bug fix | PATCH |
| `docs` | Documentation only | PATCH |
| `style` | Formatting, no code change | PATCH |
| `refactor` | Code restructuring | PATCH |
| `perf` | Performance improvement | PATCH |
| `test` | Adding/updating tests | PATCH |
| `build` | Build system changes | PATCH |
| `ci` | CI configuration | PATCH |
| `chore` | Maintenance tasks | PATCH |
| `revert` | Revert previous commit | PATCH |

### Breaking Changes

Breaking changes trigger a MAJOR version bump:

```
feat!: remove deprecated API endpoints

BREAKING CHANGE: The /v1/users endpoint has been removed.
Use /v2/users instead.
```

Or with footer:

```
feat(api): restructure response format

BREAKING CHANGE: Response now uses camelCase instead of snake_case.
```

### Examples

```bash
# Feature
feat(auth): add OAuth2 login support

# Bug fix
fix(api): handle null user gracefully

# With scope
feat(dashboard): add export to CSV button

# Breaking change
feat!: require Node.js 20+

# Documentation
docs: update API reference for v2 endpoints

# Maintenance
chore(deps): update dependencies
```

## PR Titles

**Important**: We use squash merges, so the **PR title becomes the commit message**.

### Rules

1. PR title MUST follow Conventional Commits format
2. PR title is validated by CI (`pr-title` workflow)
3. Keep titles under 72 characters
4. Use imperative mood ("add feature" not "added feature")

### Valid Examples

- `feat(auth): add password reset flow`
- `fix: resolve race condition in worker pool`
- `docs: clarify installation steps`
- `chore(ci): speed up test caching`

### Invalid Examples

- `Update user service` (missing type)
- `feat: Add new feature for users that allows them to do things` (too long)
- `FEAT: add feature` (type must be lowercase)

## Versioning

We follow [Semantic Versioning](https://semver.org/):

```
MAJOR.MINOR.PATCH

1.0.0 → 1.0.1 (patch: bug fix)
1.0.1 → 1.1.0 (minor: new feature)
1.1.0 → 2.0.0 (major: breaking change)
```

### Pre-1.0.0

During initial development (0.x.x):
- MINOR bumps may include breaking changes
- PATCH bumps are for fixes and features

## Release Please Workflow

### Automatic Release PR

When commits land on `main`, Release Please:

1. Analyzes commit messages since last release
2. Determines version bump
3. Updates CHANGELOG.md
4. Creates/updates a release PR

### Release PR Contents

The release PR will:
- Update version in package.json / pyproject.toml
- Update CHANGELOG.md with categorized changes
- Have title like "chore(main): release 1.2.0"

### Publishing a Release

1. Review the release PR
2. Verify CHANGELOG looks correct
3. Merge the release PR
4. Release Please creates GitHub Release with tag

## CHANGELOG

The CHANGELOG.md is **automatically managed** by Release Please.

### Do Not Edit Manually

- Release Please owns this file
- Manual edits will be overwritten
- If you need to add notes, do it in the release PR

### Format

```markdown
## [1.2.0](link) (2024-01-15)

### Features

* **auth:** add OAuth2 support ([#123](link))

### Bug Fixes

* **api:** handle edge case in pagination ([#124](link))
```

## Hotfix Procedure

For urgent fixes that can't wait for normal release:

1. Create branch from `main`: `git checkout -b fix/critical-bug`
2. Make minimal fix
3. Create PR with `fix:` title
4. Get expedited review
5. Merge to main
6. Release Please will create release PR
7. Merge release PR immediately

**Note**: Hotfixes still go through the normal PR and release process, just with expedited review.

## Manual Release (Emergency Only)

Only use this if Release Please is broken:

```bash
# 1. Update version manually
npm version patch  # or minor, major
# or edit pyproject.toml

# 2. Update CHANGELOG manually

# 3. Commit
git commit -am "chore: release v1.2.3"

# 4. Tag and push
git tag v1.2.3
git push origin main --tags

# 5. Create GitHub release manually
```

**Always** fix Release Please and return to automated process afterwards.

## Troubleshooting

### Release PR Not Created

Check:
- Commits have valid Conventional Commit format
- Release Please workflow ran successfully
- No existing open release PR

### Wrong Version Bump

Check commit messages:
- `feat` → MINOR
- `fix` → PATCH
- `feat!` or `BREAKING CHANGE` → MAJOR

### CHANGELOG Missing Entries

Commits must follow Conventional Commits exactly. Check:
- Type is valid (`feat`, `fix`, etc.)
- Colon and space after type: `feat: ` not `feat:`
- No typos in type
