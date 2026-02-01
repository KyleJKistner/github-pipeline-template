# Testing Policy

This document defines testing requirements and standards for this project.

## Coverage Requirements

### Minimum Thresholds

| Metric | Minimum | Target |
|--------|---------|--------|
| Line coverage | 80% | 90% |
| Branch coverage | 75% | 85% |
| Function coverage | 80% | 90% |

### Critical Paths

Critical business logic must have **95% coverage**. This includes:

- Authentication and authorization
- Payment processing
- Data validation
- Security-sensitive operations

### Exclusions

The following may be excluded from coverage requirements:

- Generated code
- Type definitions (`.d.ts`)
- Configuration files
- Test utilities and fixtures

Configure exclusions in your coverage tool, not by lowering thresholds.

## Test Types

### Unit Tests (Required)

**Purpose**: Test individual functions/methods in isolation.

**Characteristics**:
- Fast execution (<100ms per test)
- No external dependencies (database, network, filesystem)
- Mock all dependencies
- One assertion focus per test

**Example**:
```typescript
describe('calculateTotal', () => {
  it('should sum item prices', () => {
    const items = [{ price: 10 }, { price: 20 }];
    expect(calculateTotal(items)).toBe(30);
  });

  it('should return 0 for empty array', () => {
    expect(calculateTotal([])).toBe(0);
  });
});
```

### Integration Tests (Recommended)

**Purpose**: Test component interactions and integrations.

**Characteristics**:
- May use real dependencies (test database, etc.)
- Test realistic scenarios
- Slower than unit tests
- Use test fixtures and factories

**Example**:
```typescript
describe('UserService', () => {
  let db: TestDatabase;

  beforeAll(async () => {
    db = await TestDatabase.create();
  });

  it('should create and retrieve a user', async () => {
    const service = new UserService(db);
    const user = await service.create({ name: 'Test' });
    const retrieved = await service.getById(user.id);
    expect(retrieved).toEqual(user);
  });
});
```

### End-to-End Tests (Optional)

**Purpose**: Test complete user workflows.

**Characteristics**:
- Run against staging/test environment
- Test real user scenarios
- Slowest test type
- Most brittle; use sparingly

**When to use**:
- Critical user journeys
- Smoke tests for deployments
- Regression tests for complex flows

## Running Tests

### Local Development

```bash
# Run all tests with coverage
make test

# Run tests in watch mode (if supported)
npm test -- --watch
# or
pytest --watch
```

### CI Pipeline

Tests run automatically on:
- Every pull request
- Every push to main

CI will fail if:
- Any test fails
- Coverage drops below thresholds

### Viewing Coverage

```bash
# Generate coverage report
make test

# View HTML report (Node.js)
open artifacts/coverage/index.html

# View HTML report (Python)
open artifacts/htmlcov/index.html
```

## Test Organization

### File Location

Tests should live alongside source files:

```
src/
  user/
    user-service.ts
    user-service.test.ts    # Unit tests
    user-service.int.test.ts # Integration tests (optional)
```

Or in a parallel `__tests__` directory:

```
src/
  user/
    user-service.ts
    __tests__/
      user-service.test.ts
```

### Naming Conventions

| Type | Pattern | Example |
|------|---------|---------|
| Unit test | `*.test.ts` | `user-service.test.ts` |
| Integration test | `*.int.test.ts` | `user-service.int.test.ts` |
| E2E test | `*.e2e.test.ts` | `checkout.e2e.test.ts` |

### Test Structure

Use descriptive names that explain what is being tested:

```typescript
// Good - describes the scenario and expectation
describe('OrderService.submitOrder', () => {
  it('should return error when cart is empty', () => {});
  it('should apply discount code when valid', () => {});
  it('should send confirmation email on success', () => {});
});

// Bad - vague names
describe('OrderService', () => {
  it('works', () => {});
  it('test 1', () => {});
});
```

## Mocking Guidelines

### Prefer Dependency Injection

```typescript
// Good - injectable dependency
class UserService {
  constructor(private db: Database) {}
}

// Test
const mockDb = createMockDatabase();
const service = new UserService(mockDb);
```

### Reset Mocks Between Tests

```typescript
beforeEach(() => {
  jest.clearAllMocks();
  // or
  vi.clearAllMocks();
});
```

### Document Complex Mocks

```typescript
// Mock the payment gateway to simulate a declined card
// This tests our retry logic and error handling
const mockGateway = {
  charge: jest.fn()
    .mockRejectedValueOnce(new CardDeclinedError())
    .mockResolvedValueOnce({ success: true }),
};
```

## Test Data

### Use Factories

```typescript
// Good - factory function
function createUser(overrides?: Partial<User>): User {
  return {
    id: randomUUID(),
    name: 'Test User',
    email: 'test@example.com',
    ...overrides,
  };
}

// Usage
const user = createUser({ name: 'Custom Name' });
```

### Avoid Shared State

```typescript
// Bad - shared mutable state
const testUser = { id: '1', name: 'Test' };

describe('test suite', () => {
  it('modifies user', () => {
    testUser.name = 'Modified'; // Affects other tests!
  });
});

// Good - fresh data per test
describe('test suite', () => {
  it('modifies user', () => {
    const user = createUser();
    user.name = 'Modified'; // Isolated
  });
});
```

## Continuous Improvement

### Review Coverage Trends

- Monitor coverage over time
- Investigate sudden drops
- Celebrate improvements

### Flaky Test Policy

Flaky tests (tests that sometimes pass/fail without code changes):

1. Mark as skipped immediately
2. Create issue to fix
3. Fix within 1 week or delete
4. Never merge code that introduces flaky tests
