# Style Guide

This document defines coding standards and conventions for this project.

## General Principles

1. **Clarity over cleverness** - Write code that is easy to read and understand
2. **Consistency** - Follow existing patterns in the codebase
3. **Fail fast** - Validate inputs early, use strict mode, handle errors explicitly
4. **Automate** - Let tools enforce style; don't argue about formatting

## Formatting

### Rule: Formatter Output is Canonical

- Run `make fmt` before committing
- CI will fail if `make fmt-check` detects differences
- Do not manually adjust formatted code

### Line Length

- **Maximum**: 100 characters
- **Exceptions**: URLs, import statements, string literals that would be awkward to break

### Indentation

- **Spaces, not tabs** (except Makefiles)
- **2 spaces**: JavaScript, TypeScript, YAML, JSON, HTML, CSS
- **4 spaces**: Python

## Naming Conventions

### General

| Type | Convention | Example |
|------|------------|---------|
| Files | kebab-case | `user-service.ts` |
| Directories | kebab-case | `api-handlers/` |
| Constants | SCREAMING_SNAKE_CASE | `MAX_RETRY_COUNT` |

### TypeScript/JavaScript

| Type | Convention | Example |
|------|------------|---------|
| Variables | camelCase | `userName` |
| Functions | camelCase | `getUserById()` |
| Classes | PascalCase | `UserService` |
| Interfaces | PascalCase | `UserProfile` |
| Type aliases | PascalCase | `UserId` |
| Enums | PascalCase | `UserStatus` |
| Enum members | PascalCase | `UserStatus.Active` |

### Python

| Type | Convention | Example |
|------|------------|---------|
| Variables | snake_case | `user_name` |
| Functions | snake_case | `get_user_by_id()` |
| Classes | PascalCase | `UserService` |
| Constants | SCREAMING_SNAKE_CASE | `MAX_RETRIES` |
| Modules | snake_case | `user_service.py` |

## TypeScript/JavaScript Guidelines

### Strict Mode

- Enable `"strict": true` in tsconfig.json
- Enable `"noImplicitAny": true`
- Enable `"strictNullChecks": true`

### Prefer const

```typescript
// Good
const user = getUser();

// Avoid
let user = getUser();
```

### Explicit Return Types

```typescript
// Good - explicit return type for public functions
function getUser(id: string): User | null {
  // ...
}

// OK - inferred types for simple private functions
const double = (n: number) => n * 2;
```

### Async/Await

```typescript
// Good
async function fetchUser(id: string): Promise<User> {
  const response = await fetch(`/users/${id}`);
  return response.json();
}

// Avoid raw promises when async/await is cleaner
function fetchUser(id: string): Promise<User> {
  return fetch(`/users/${id}`).then(r => r.json());
}
```

## Python Guidelines

### Type Hints

```python
# Good - type hints for all function signatures
def get_user(user_id: str) -> User | None:
    ...

# Good - type hints for class attributes
class UserService:
    users: dict[str, User]
```

### Docstrings

```python
def process_order(order: Order, validate: bool = True) -> OrderResult:
    """Process an order and return the result.

    Args:
        order: The order to process.
        validate: Whether to validate before processing.

    Returns:
        The result of processing the order.

    Raises:
        ValidationError: If validation is enabled and fails.
    """
```

## Shell Scripts

### Strict Mode

Always start scripts with:

```bash
#!/usr/bin/env bash
set -euo pipefail
```

### Variable Quoting

```bash
# Good - always quote variables
echo "$VARIABLE"
cp "$SOURCE" "$DEST"

# Bad - unquoted variables
echo $VARIABLE
cp $SOURCE $DEST
```

### Conditionals

```bash
# Good - use [[ ]] for conditionals
if [[ -f "$file" ]]; then
  echo "File exists"
fi

# Avoid - [ ] has more gotchas
if [ -f "$file" ]; then
  echo "File exists"
fi
```

## Error Handling

### Be Explicit

```typescript
// Good - handle errors explicitly
try {
  await processOrder(order);
} catch (error) {
  if (error instanceof ValidationError) {
    logger.warn('Validation failed', { error });
    return { success: false, error: error.message };
  }
  throw error; // Re-throw unexpected errors
}

// Bad - swallow errors silently
try {
  await processOrder(order);
} catch {
  // Silent failure
}
```

### Fail Fast

```typescript
// Good - validate early
function processUser(user: unknown): ProcessedUser {
  if (!isValidUser(user)) {
    throw new ValidationError('Invalid user data');
  }
  // ... rest of processing
}
```

## Logging

### Use Structured Logging

```typescript
// Good - structured with context
logger.info('Order processed', {
  orderId: order.id,
  userId: order.userId,
  duration: processingTime,
});

// Avoid - unstructured strings
logger.info(`Order ${order.id} processed for user ${order.userId}`);
```

### Log Levels

| Level | Use Case |
|-------|----------|
| `error` | Errors requiring attention |
| `warn` | Unexpected but handled situations |
| `info` | Significant events (startup, requests) |
| `debug` | Detailed debugging information |

## Security Rules

### Never Commit Secrets

- No API keys, passwords, or tokens in code
- Use environment variables or secret management
- Add sensitive patterns to `.gitignore`

### Validate External Input

- Never trust user input
- Sanitize data before use
- Use parameterized queries for databases

### Dependency Management

- Keep dependencies updated (Dependabot)
- Review dependency changes carefully
- Prefer well-maintained packages with security policies

## Definition of Done

Code is "done" when:

- [ ] Tests pass (`make test`)
- [ ] Linting passes (`make lint`)
- [ ] Formatting is correct (`make fmt-check`)
- [ ] Documentation is updated (if needed)
- [ ] PR has been reviewed
- [ ] CI passes
