# CLI-Autoland Tool Development Guidelines

**IMPORTANT**: This document contains development guidelines for maintaining and extending the CLI-Autoland tool itself. These guidelines are NOT intended for AI agents invoked by this tool. Agent-specific instructions should be placed in the appropriate prompt templates or service configuration, not in this document.

## Architecture and Design

### Core Architecture Principles

This CLI tool follows a service-oriented architecture with clear separation between CLI interface (cli.py) and business logic (service.py). When adding new functionality, maintain this separation by implementing core logic in the service layer and keeping CLI commands thin.

The tool integrates with external systems (GitHub CLI, coding agents) through subprocess calls. Always implement proper error handling and response validation for these integrations.

### External Tool Integration

When integrating with GitHub CLI or coding agents, always validate responses and handle edge cases. Use consistent patterns for subprocess command construction as lists rather than shell strings to prevent injection vulnerabilities.

For coding agent communication, structure prompts clearly with locale information and proper context separation using the established pattern in invoke_agent_with_prompt.

## Python Development Standards

### Code Quality and Formatting

Follow the project's Python conventions as defined in pyproject.toml. Use autopep8 for formatting with max line length of 150 characters to accommodate complex GitHub API commands.

**Python Version Compatibility**: While the project requires Python 3.11+ (as specified in pyproject.toml), development should use Python 3.13 syntax and features while maintaining backward compatibility to 3.11. Avoid features introduced after 3.11 unless absolutely necessary.

### Type Hinting and Naming

**Type Hinting**: Only add type hints when they provide meaningful value for code clarity or IDE support. Avoid over-annotating simple functions or where types are obvious from context. Focus type hints on public APIs and complex data structures.

**Naming Conventions**: Do not use leading underscores for variables or function names. Leading underscores do not provide technical protection against unintended access and only reduce code readability. Use clear, descriptive names without underscore prefixes.

### Logging Best Practices

Never use f-string formatting in logging calls. Use logging's built-in string formatting for performance and security:

```python
# Correct
logger.info("Processing PR #%s", pr_number)

# Incorrect
logger.info(f"Processing PR #{pr_number}")
```

### Error Handling

Use the custom AutolandError exception class for domain-specific errors. Wrap subprocess calls appropriately - use `check=True` for commands that must succeed, `check=False` for commands where failure is acceptable.

All subprocess-related errors should be caught and handled at the CLI layer (cli.py). The service layer should focus on business logic and let subprocess exceptions bubble up to be handled consistently in the CLI commands.

Provide meaningful error messages that help users understand what went wrong and how to resolve issues.

## Testing and Quality Assurance

When implementing new features, consider the polling and timing aspects of GitHub Actions integration. The tool waits for checks completion and has configurable polling intervals - ensure new functionality respects these patterns.

Test subprocess integrations carefully, as the tool relies heavily on external commands (gh, git, codex, claude) for its functionality.

## Internationalization and Communication

### User Communication Language

When interacting with users, agents should communicate in the language the user initially uses. If a user starts a conversation in Japanese, continue in Japanese. If they use English, respond in English. This approach respects user preferences while maintaining natural communication flow.

### Technical Documentation Language

The project maintains English as the official language for all technical documentation and code-related content. This includes source code comments, commit messages, API documentation, and technical specifications. Consistency in technical language ensures better collaboration across international development teams and maintains professional standards.

### Documentation Maintenance

The project follows a dual-language documentation approach. When updating the primary README.md file, agents must also update the corresponding README.ja.md file to maintain content parity across languages. This ensures that both English and Japanese-speaking users have access to current information about the project.

### Internationalization Implementation

Agents should always consider internationalization (i18n) when working with user-facing text. Instead of concatenating translatable strings with dynamic content, use proper formatting placeholders within complete translatable strings.

For example, when displaying quantities, avoid splitting the message like `_("You have") + str(amount) + _("cows")`. Instead, use a single translatable string with placeholders: `_("You have {amount} cows").format(amount=amount)`. This approach allows translators to adjust word order and grammar rules that vary between languages, ensuring natural-sounding translations across different linguistic structures.

**Message ID Language Requirements**: All message IDs (msgid) in translation files must be written in English, regardless of the conversation language or user interface language. Even when communicating with users in non-English languages, the underlying translatable strings should always use English as the source language. This maintains consistency in the translation workflow and ensures that the primary language for all technical content remains English.

For example, use `_("Welcome to the application")` rather than `_("Bienvenido a la aplicacion")`, even in Spanish-focused development contexts.

This methodology prevents grammatical issues that arise from literal word-by-word translation and provides translators with complete context for accurate localization.

**i18n Development Workflow**: When implementing internationalization features, always follow the complete workflow: run `make po` before editing .po files, then update Python code with `_()` calls, run `make po` again to extract strings, translate in .po files, and run `make mo` to compile translations.
