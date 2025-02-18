# Commit Message Guidelines

Use Conventional Commits specification to enable automated changelog generation.

## Message Structure

```text
<type>: <subject>

<why this change was needed>
```

## Format Rules

- **Type**: Defines change category (see types below)
- **Subject**: Brief description in present tense
- **Body**: Explains WHY the change was needed - use "Reason of Change" section below as guidance for content

## Types

- **feat**: New feature
- **fix**: Bug fix
- **docs**: Documentation changes
- **style**: Formatting changes (no code change)
- **refactor**: Code restructuring
- **perf**: Performance improvements
- **test**: Test-related changes
- **build**: Build system/dependencies
- **chore**: Maintenance tasks
- **revert**: Reverting changes

## Example

```text
feat: add user authentication system

- Implement secure login to meet new security requirements.
- Current basic auth doesn't meet security standards.
```

### Reason of Change
