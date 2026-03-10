---
name: "template-skill"
version: "1.0.0"
description: "Template for creating new skills - copy this as starting point"
author: "Vibe Scaffolding"
tags: ["template", "example", "meta"]
requires: []
compatible_tools: ["opencode", "cursor", "windsurf", "claude"]
---

# Template Skill

## Purpose

This is a template for creating new skills. Copy this directory as a starting point for your own skills.

**When to use this template:**
- Creating a new reusable AI workflow
- Packaging domain expertise for AI agents
- Building project-specific AI behaviors

---

## When to Use

Replace this section with trigger phrases that activate your skill:

- User says "[trigger phrase 1]"
- User asks "[question pattern]"
- Specific situation occurs

---

## Instructions

Replace this with step-by-step instructions for the AI agent.

### Step 1: [Action Name]

Describe what the AI should do:
- Sub-point A
- Sub-point B

Example:
```bash
# Example command or code
echo "Hello, World!"
```

### Step 2: [Next Action]

Continue with next step...

### Step 3: Output Format

Describe expected output:

```json
{
  "result": "expected structure",
  "status": "success"
}
```

---

## Examples

### Example 1: Basic Usage

**User Input:**
```
User: "[example user request]"
```

**AI Response:**
```
[Expected AI behavior]
1. First, analyze...
2. Then, implement...
3. Finally, verify...
```

**Result:**
```
[Expected outcome]
```

---

### Example 2: Advanced Usage

**Scenario:** More complex situation

**User Input:**
```
User: "[complex request]"
```

**AI Response:**
```
[Detailed step-by-step behavior]
```

---

## Anti-Patterns

Document what NOT to do:

- ❌ **Don't [bad practice 1]** - Explain why this is wrong
- ❌ **Don't [bad practice 2]** - Provide better alternative
- ❌ **Don't [bad practice 3]** - Common mistake to avoid

---

## Configuration (Optional)

If your skill needs configuration, document it here:

```yaml
# .agents/skills/your-skill/config.yaml
setting1: "value"
setting2: 42
```

---

## Dependencies (Optional)

If this skill requires other skills:

- `skill-name-1` (v1.0.0+) - Required for [reason]
- `skill-name-2` (v2.0.0+) - Used in Step 3

---

## Testing

How to verify this skill works correctly:

1. **Test Case 1:**
   - Input: `[test input]`
   - Expected: `[expected output]`

2. **Test Case 2:**
   - Input: `[test input]`
   - Expected: `[expected output]`

---

## Maintenance

**Version History:**
- `1.0.0` (2026-03-10) - Initial release

**Known Issues:**
- None

**Roadmap:**
- [ ] Feature idea 1
- [ ] Feature idea 2

---

## Resources

Additional materials (if applicable):

- See `./scripts/` for helper scripts
- See `./templates/` for code templates
- See `./resources/` for reference docs

---

## Contributing

If you improve this skill:

1. Update version in frontmatter (follow SemVer)
2. Document changes in "Maintenance" section
3. Add tests if needed
4. Update examples to reflect changes

---

**Created:** 2026-03-10  
**Last Modified:** 2026-03-10  
**License:** MIT
