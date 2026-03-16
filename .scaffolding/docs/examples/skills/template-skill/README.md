# Template Skill

This is a template for creating new reusable AI skills.

## Directory Structure

```
template-skill/
├── SKILL.md           # Main skill file (core instructions)
├── README.md          # This file (extended documentation)
├── scripts/           # Helper scripts (optional)
├── templates/         # Code templates (optional)
└── resources/         # Reference materials (optional)
```

## Usage

### 1. Copy This Template

```bash
# Copy to your project's skills directory
cp -r .scaffolding/docs/examples/skills/template-skill .agents/skills/your-skill-name

# Or copy to create a new template skill
cp -r .scaffolding/docs/examples/skills/template-skill .scaffolding/docs/examples/skills/new-skill
```

### 2. Customize

Edit the following files:

**SKILL.md:**
- Update frontmatter (name, version, description, tags)
- Replace "Purpose" section with your skill's purpose
- Define "When to Use" triggers
- Write step-by-step "Instructions"
- Add "Examples" and "Anti-Patterns"

**README.md (this file):**
- Document extended usage
- Add configuration details
- Provide troubleshooting tips

### 3. Add Supporting Files (Optional)

**scripts/:**
Place executable scripts that help the skill:
```bash
scripts/
├── lint.sh           # Validation script
├── generate.sh       # Code generation
└── test.sh           # Testing helper
```

**templates/:**
Code templates the skill references:
```
templates/
├── component.tsx     # React component template
├── api-route.ts      # API endpoint template
└── test.spec.ts      # Test template
```

**resources/:**
Reference documentation:
```
resources/
├── best-practices.md # Guidelines
├── checklist.md      # Step checklist
└── examples/         # Real-world examples
```

## Examples

### Minimal Skill (Single File)

For simple skills, SKILL.md alone is sufficient:

```
simple-skill/
└── SKILL.md          # Everything in one file
```

### Full-Featured Skill

For complex skills with helpers:

```
complex-skill/
├── SKILL.md          # Core instructions
├── README.md         # Extended docs
├── scripts/
│   ├── validate.sh
│   └── deploy.sh
├── templates/
│   ├── config.yaml
│   └── Dockerfile
└── resources/
    ├── architecture.md
    └── examples/
        ├── basic.md
        └── advanced.md
```

## Skill Development Workflow

### 1. Planning Phase

- Define skill purpose (one sentence)
- List trigger phrases
- Outline high-level steps
- Identify dependencies

### 2. Implementation Phase

- Write frontmatter
- Detail each instruction step
- Add code examples
- Document anti-patterns

### 3. Testing Phase

- Test with real AI tool (OpenCode/Cursor)
- Verify all examples work
- Check for ambiguities
- Gather feedback

### 4. Documentation Phase

- Write README.md
- Add usage examples
- Document configuration
- Create troubleshooting guide

### 5. Maintenance Phase

- Update version on changes
- Track known issues
- Plan future features
- Accept contributions

## Best Practices

### DO ✅

- **Be Specific:** "Check for SQL injection in all database queries" > "Review security"
- **Use Examples:** Show concrete input/output pairs
- **Number Steps:** Make instructions easy to follow
- **Document Why:** Explain reasoning, not just actions
- **Version Properly:** Follow Semantic Versioning

### DON'T ❌

- **Be Vague:** Avoid "handle this appropriately"
- **Skip Examples:** AI needs concrete patterns
- **Assume Context:** Make all dependencies explicit
- **Forget Anti-Patterns:** Show what NOT to do
- **Break Compatibility:** Major version for breaking changes

## Validation Checklist

Before using your new skill:

- [ ] Frontmatter complete (name, version, description, author, tags)
- [ ] Clear "Purpose" statement
- [ ] At least 3 "When to Use" triggers
- [ ] Numbered, step-by-step "Instructions"
- [ ] Minimum 2 "Examples" with input/output
- [ ] At least 3 "Anti-Patterns" documented
- [ ] Version is `1.0.0` (initial release)
- [ ] Tags are relevant and discoverable
- [ ] Compatible tools listed (if tool-specific)
- [ ] Dependencies declared (if any)

## Integration

### In AGENTS.md

Reference your skill:

## AI Assistant Skills

- **your-skill-name** (v1.0.0) - [Brief description]
  Location: `.agents/skills/your-skill-name/`
  
To use: `@use your-skill-name`

### In Code

If your skill generates code, reference the templates:

```typescript
// See .agents/skills/your-skill-name/templates/component.tsx
import { YourComponent } from './YourComponent';
```

## Troubleshooting

### Skill Not Loading

**Problem:** AI doesn't recognize the skill

**Solutions:**
1. Check file is named exactly `SKILL.md` (case-sensitive)
2. Verify frontmatter YAML is valid
3. Ensure skill directory is in `.agents/skills/`
4. Restart AI tool to reload skills

### Instructions Unclear

**Problem:** AI doesn't follow instructions correctly

**Solutions:**
1. Add more examples (show, don't tell)
2. Break complex steps into sub-steps
3. Use concrete examples, not abstract descriptions
4. Test with different phrasings

### Dependency Issues

**Problem:** Skill requires another skill

**Solutions:**
1. Document in `requires` frontmatter field
2. Check dependency skill exists
3. Verify dependency version compatibility
4. Load dependencies before main skill

## Contributing

Improve this template:

1. Fork the repository
2. Make your changes
3. Test with real AI tools
4. Submit pull request
5. Update CHANGELOG.md

## Resources

- **SKILL Format Guide:** `.scaffolding/docs/SKILL_FORMAT_GUIDE.md`
- **AGENTS.md Guide:** `.scaffolding/docs/AGENTS_MD_GUIDE.md`
- **Anthropic Skills:** https://github.com/anthropics/skills
- **agents.md Standard:** https://agents.md/

## License

MIT License - Use freely, modify as needed.

---

**Version:** 1.0.0  
**Created:** 2026-03-10  
**Maintained by:** Vibe Scaffolding Project
