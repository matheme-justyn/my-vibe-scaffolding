# Commands System

**Version**: 1.0.0  
**Origin**: [everything-claude-code](https://github.com/affaan-m/everything-claude-code) (Anthropic Hackathon Winner)  
**Adapted for**: OpenCode

## Overview

Commands provide task-specific workflows that combine agents and skills for common development operations. Think of them as "macros" for AI-assisted development.

## Available Commands (10)

| Command | Description | Agent Used | Use When |
|---------|-------------|------------|----------|
| **plan** | Create implementation plan with risk assessment | planner | Starting complex features |
| **code-review** | Review code for quality, security, maintainability | code-reviewer | Before committing, PR review |
| **build-fix** | Diagnose and fix build/compilation errors | architect | Build failures, type errors |
| **e2e** | Create end-to-end tests for user flows | tdd-guide | Testing critical workflows |
| **checkpoint** | Save current state before major changes | — | Before refactoring, experiments |
| **test-all** | Run all tests (unit, integration, E2E) with coverage | tdd-guide | Pre-commit, CI/CD |
| **security-scan** | Security audit for vulnerabilities | security-reviewer | Pre-deployment, security review |
| **analyze** | Analyze codebase quality and metrics | architect | Code health check, refactoring candidates |
| **refactor** | Systematic code refactoring | architect | Improving code maintainability |
| **document** | Generate/update documentation | architect | API docs, README, inline comments |

## Usage Patterns

### In OpenCode

Commands are invoked by referencing the command file in your prompt:

```
User: "I need to plan the implementation of user authentication"
Agent: [Reads .agents/commands/plan.md and follows instructions]

User: "Review the code I just wrote"
Agent: [Reads .agents/commands/code-review.md and executes review]

User: "Run all tests and show me coverage"
Agent: [Reads .agents/commands/test-all.md and runs test suite]
```

### Command Workflow

Each command follows this structure:

1. **Receive input** - User specifies target (e.g., "plan user auth")
2. **Execute steps** - Command provides systematic checklist
3. **Generate output** - Structured report or action items
4. **Wait for confirmation** - User approves before proceeding

## Command Categories

### Planning & Design
- **plan** - Break down complex tasks into phases
- **analyze** - Assess codebase quality and identify issues

### Implementation
- **refactor** - Improve code structure safely
- **document** - Generate comprehensive documentation

### Quality Assurance
- **code-review** - Multi-category quality check
- **test-all** - Comprehensive test execution
- **security-scan** - Vulnerability detection

### Debugging
- **build-fix** - Resolve compilation errors
- **checkpoint** - Save state before risky changes

### Testing
- **e2e** - End-to-end test creation

## Command Chains (Common Workflows)

### Feature Development Flow
```
1. plan → Review requirements, create implementation plan
2. checkpoint → Save baseline
3. [Implement feature]
4. test-all → Verify all tests pass
5. code-review → Check quality
6. security-scan → Check for vulnerabilities
7. document → Update API docs
```

### Bug Fix Flow
```
1. checkpoint → Save current state
2. analyze → Identify problem area
3. [Fix bug]
4. test-all → Verify fix doesn't break other tests
5. code-review → Ensure fix is clean
```

### Refactoring Flow
```
1. analyze → Identify refactoring candidates
2. checkpoint → Save before refactoring
3. test-all → Ensure tests pass (baseline)
4. refactor → Apply refactoring
5. test-all → Verify tests still pass
6. code-review → Check code quality improved
```

### Pre-Deployment Flow
```
1. test-all → All tests must pass
2. code-review → No critical issues
3. security-scan → No vulnerabilities
4. document → Documentation up to date
5. [Deploy]
```

## Command Format

Each command file follows this structure:

```markdown
---
description: Brief description
agent: Which agent to use (optional)
subtask: true/false
---

# Command Name

Brief description: $ARGUMENTS

## Your Task

1. Step 1
2. Step 2
3. Step 3

## [Category 1]

Details...

## [Category 2]

Details...

## Output Format

Expected output structure...

---

**IMPORTANT**: Critical notes or warnings
```

## Integration with Agents & Skills

Commands orchestrate agents and skills:

| Command | Primary Agent | Related Skills |
|---------|---------------|----------------|
| plan | planner | — |
| code-review | code-reviewer | requesting-code-review |
| build-fix | architect | systematic-debugging |
| e2e | tdd-guide | e2e-testing |
| test-all | tdd-guide | tdd-workflow, unit-testing |
| security-scan | security-reviewer | security-review |
| analyze | architect | coding-standards |
| refactor | architect | coding-standards, tdd-workflow |
| document | architect | — |

## Extending Commands

To add new commands:

1. Create `.agents/commands/new-command.md`
2. Follow command format (see above)
3. Specify agent and related skills
4. Add to this README
5. Update AGENTS.md Commands section

## Best Practices

### ✅ DO

- Use commands for repeatable workflows
- Chain commands for complex processes
- Specify clear inputs (file paths, feature names)
- Review command output before proceeding

### ❌ DON'T

- Skip checkpoint before risky changes
- Ignore security-scan warnings
- Deploy without running test-all
- Refactor without passing tests

## Command Aliases (Recommended)

For frequently used commands, create shell aliases:

```bash
# Add to ~/.zshrc or ~/.bashrc
alias ai-plan="echo 'plan:' && cat"
alias ai-review="echo 'code-review:' && cat"
alias ai-test="echo 'test-all' && cat"
alias ai-security="echo 'security-scan' && cat"
```

Usage:
```bash
ai-plan "user authentication feature"
ai-review "src/api/auth.ts"
ai-test
```

## References

- **Source**: https://github.com/affaan-m/everything-claude-code
- **PRD**: `docs/PRD-claude-code-inspired-upgrades.md`
- **ADR**: `docs/adr/0009-reference-claude-code-architecture.md`
- **Agents**: `.agents/agents/README.md`
- **Skills**: `.agents/skills/README.md`

---

**Total Commands**: 10  
**Last Updated**: 2025-03-12  
**Status**: Phase 1.3 Complete ✅
