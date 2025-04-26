# Warped Speed - Development Workflow

This document outlines the development workflow, best practices, and conventions for the Warped Speed project. Following these guidelines will ensure consistency, quality, and maintainability.

## Development Environment Setup

### Prerequisites

- Node.js (v16+)
- SQL Server
- Git
- Visual Studio Code with Cursor extension
- Docker (optional, for containerized development)

### Initial Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/warped.git
   cd warped
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Set up environment variables:
   ```bash
   cp .env.example .env
   # Edit .env with your own API keys and database credentials
   ```

4. Set up the database:
   ```bash
   npm run db:setup
   ```

5. Start the development server:
   ```bash
   npm run dev
   ```

## Project Structure

The project follows a modular structure:

```
/warped
  /.cursor           # Cursor AI configuration
  /docs              # Documentation
  /public            # Static assets
  /src
    /components      # UI components
    /services        # Business logic
    /hooks           # React hooks
    /context         # React context providers
    /utils           # Utility functions
    /types           # TypeScript interfaces
    /styles          # Global styles
  /server            # Backend code
    /routes          # API routes
    /controllers     # Request handlers
    /models          # Data models
    /database        # Database migrations
  /scripts           # Utility scripts
  /tests             # Test files
```

## Git Workflow

### Branching Strategy

- `main` - Production-ready code
- `develop` - Integration branch for features
- `feature/` - Feature development branches
- `bugfix/` - Bug fix branches
- `release/` - Release preparation branches

### Creating a New Feature

1. Create a new branch from `develop`:
   ```bash
   git checkout develop
   git pull
   git checkout -b feature/my-feature-name
   ```

2. Implement the feature in small, focused commits

3. Write tests for the feature

4. Create a pull request to merge back into `develop`

### Commit Messages

Follow the conventional commits format:

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

Where `type` is one of:
- `feat`: A new feature
- `fix`: A bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code changes that neither fix bugs nor add features
- `perf`: Performance improvements
- `test`: Adding or correcting tests
- `chore`: Changes to the build process, tools, etc.

Example:
```
feat(ui): add action button component

Implement the action button component with all color variants.
Includes unit tests and documentation.

Closes #123
```

## Development Best Practices

### General

1. **Code Quality**
   - Follow the established coding style
   - Keep functions small and focused
   - Write meaningful comments
   - Use descriptive variable and function names

2. **Documentation**
   - Document all public functions, classes, and interfaces
   - Keep documentation up-to-date with code changes
   - Document complex algorithms and business logic

3. **Testing**
   - Write unit tests for all services and utilities
   - Write integration tests for API endpoints
   - Write UI tests for critical user flows
   - Maintain high test coverage

### TypeScript Best Practices

1. **Type Definitions**
   - Define interfaces and types in dedicated files
   - Use explicit typing over `any`
   - Use union types for varying return types
   - Leverage generics for reusable components

2. **Null Handling**
   - Use optional chaining (`?.`) and nullish coalescing (`??`)
   - Initialize variables to avoid `undefined` errors
   - Document nullable parameters and return values

3. **Type Safety**
   - Enable strict mode in `tsconfig.json`
   - Use type guards for runtime type checking
   - Avoid type assertions (`as`) when possible

### React Best Practices

1. **Component Structure**
   - Use functional components with hooks
   - Keep components small and focused
   - Use composition over inheritance
   - Place components in appropriate directories

2. **State Management**
   - Use React Context for global state
   - Use hooks for local state
   - Avoid prop drilling
   - Consider performance implications of state updates

3. **Performance Optimization**
   - Use memoization (`useMemo`, `useCallback`)
   - Implement virtualization for long lists
   - Lazy load components when appropriate
   - Optimize re-renders

### Database Best Practices

1. **Schema Design**
   - Follow normalization principles
   - Use appropriate data types
   - Add proper indices for query optimization
   - Document all schema changes

2. **Migrations**
   - Use migration scripts for all schema changes
   - Never modify production schema directly
   - Test migrations on staging before production
   - Ensure migrations are reversible when possible

3. **Query Performance**
   - Write efficient queries
   - Use parameterized queries to prevent SQL injection
   - Monitor query performance
   - Cache frequent queries

## Database-Driven Development

The Warped Speed project emphasizes database-driven development:

1. **Schema First**
   - Design the database schema before implementing features
   - Create migration scripts for database changes
   - Document schema in `DATABASE.md`

2. **Content in Database**
   - Store all game content in the database
   - Use the database for UI configuration
   - Store prompt templates in the database

3. **Database Versioning**
   - Version the database schema
   - Include seed data in migrations
   - Implement upgrade/downgrade scripts

## Prompt-First Development

For AI-generated content:

1. **Template Definition**
   - Define prompt templates in the database
   - Document variables used in templates
   - Include examples of expected outputs

2. **Prompt Testing**
   - Test prompts with various inputs
   - Verify output formats
   - Optimize for token efficiency

3. **Iterative Refinement**
   - Review and refine prompts regularly
   - Monitor generation quality
   - Collect examples of failures for improvement

## Testing Strategy

### Unit Testing

- Test individual functions and components
- Use Jest for JavaScript/TypeScript testing
- Mock external dependencies
- Focus on testing business logic

Example:
```typescript
describe('calculateDamage', () => {
  it('should calculate base damage correctly', () => {
    const attacker = { attack: 10 };
    const defender = { defense: 5 };
    const weapon = { damage: 20 };
    
    const result = calculateDamage(attacker, defender, weapon);
    
    expect(result.damage).toBeGreaterThanOrEqual(20);
    expect(result.damage).toBeLessThanOrEqual(30);
  });
});
```

### Integration Testing

- Test API endpoints
- Test database interactions
- Use Supertest for API testing
- Set up test databases

Example:
```typescript
describe('Character API', () => {
  it('should create a new character', async () => {
    const response = await request(app)
      .post('/api/characters')
      .send({
        name: 'Test Character',
        species: 'Human',
        role: 'Pilot'
      });
    
    expect(response.status).toBe(201);
    expect(response.body).toHaveProperty('id');
    expect(response.body.name).toBe('Test Character');
  });
});
```

### UI Testing

- Test critical user flows
- Use Playwright for end-to-end testing
- Focus on user interactions
- Test across browsers and devices

Example:
```typescript
test('user can create a character', async ({ page }) => {
  await page.goto('/character-creation');
  
  await page.selectOption('select[name="species"]', 'Human');
  await page.selectOption('select[name="role"]', 'Pilot');
  await page.fill('input[name="name"]', 'Test Character');
  await page.click('button[type="submit"]');
  
  await expect(page).toHaveURL(/\/game/);
  await expect(page.locator('.character-name')).toHaveText('Test Character');
});
```

## Deployment Workflow

### Environments

1. **Development**
   - Local development environment
   - Used for feature development
   - Can use mock APIs

2. **Staging**
   - Mirror of production
   - Used for testing before deployment
   - Connected to test API keys

3. **Production**
   - Live environment
   - Requires approval for deployment
   - Uses production API keys

### Deployment Process

1. Merge changes into `develop`
2. Create a release branch when ready
3. Run tests on staging environment
4. Fix any issues found
5. Deploy to production
6. Tag the release
7. Merge release branch to `main`

## Code Review Process

### Before Submitting

1. Run tests locally
2. Review your own code
3. Update documentation
4. Ensure all linting passes

### Review Criteria

1. **Functionality**
   - Code works as expected
   - Edge cases are handled
   - No regression issues

2. **Code Quality**
   - Follows coding standards
   - No code smells
   - Appropriate error handling

3. **Performance**
   - No obvious performance issues
   - Efficient algorithms
   - Appropriate caching

4. **Security**
   - No security vulnerabilities
   - Proper input validation
   - API keys and secrets protected

5. **Testing**
   - Adequate test coverage
   - Tests cover edge cases
   - No flaky tests

## Troubleshooting Common Issues

### Database Connection Issues

1. Verify connection string in `.env`
2. Check that SQL Server is running
3. Verify user permissions
4. Check network connectivity

### API Integration Issues

1. Verify API keys in `.env`
2. Check API usage limits
3. Verify request format
4. Check network connectivity
5. Review API documentation for changes

### Build Issues

1. Clear `node_modules` and reinstall
2. Verify Node.js version
3. Check for TypeScript errors
4. Review build logs for specific errors

## Continuous Improvement

1. **Technical Debt**
   - Regularly review and address technical debt
   - Schedule refactoring sprints
   - Document known issues in `TECHNICAL_DEBT.md`

2. **Knowledge Sharing**
   - Document complex systems
   - Conduct code reviews as learning opportunities
   - Hold regular technical discussions

3. **Process Improvement**
   - Regularly review development workflow
   - Collect feedback from team members
   - Implement improvements incrementally

## GitHub CLI Integration

This project leverages GitHub CLI for streamlined GitHub operations.

## Setting Up GitHub CLI

1. Install GitHub CLI:
   ```
   winget install GitHub.cli
   ```

2. Authenticate with your GitHub account:
   ```
   gh auth login
   ```

3. Verify successful authentication:
   ```
   gh auth status
   ```

## Common GitHub CLI Commands

### Repository Operations

- Clone this repository:
  ```
  gh repo clone Skeptic1222/Warpedspeed
  ```

- Create a new repository:
  ```
  gh repo create [name] --public --source=. --push
  ```

- View repository information:
  ```
  gh repo view
  ```

### Issue Management

- List issues:
  ```
  gh issue list
  ```

- Create a new issue:
  ```
  gh issue create --title "Issue title" --body "Issue description"
  ```

- Close an issue:
  ```
  gh issue close [issue-number]
  ```

### Pull Request Workflow

- Create a pull request:
  ```
  gh pr create --title "PR title" --body "PR description"
  ```

- List pull requests:
  ```
  gh pr list
  ```

- Check out a pull request locally:
  ```
  gh pr checkout [pr-number]
  ```

### Automated Backup

- Run backup manually:
  ```
  gh workflow run automated-backup.yml
  ```

- View workflow runs:
  ```
  gh run list --workflow=automated-backup.yml
  ```

For more information on GitHub CLI, see the [official documentation](https://cli.github.com/manual/).

## Conclusion

Following this development workflow will ensure a consistent, high-quality codebase for the Warped Speed project. The emphasis on database-driven development, comprehensive testing, and code quality will create a maintainable and extensible foundation for the game.

Remember that this workflow is not set in stone and should evolve as the project grows and team needs change. Regular retrospectives and process reviews will help identify areas for improvement. 