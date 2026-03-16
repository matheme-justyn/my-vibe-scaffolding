# RELEASE_PROCESS

**Status**: Active | Domain: Collaboration  
**Related Modules**: README_STRUCTURE, ADR_TEMPLATE, GIT_WORKFLOW, PRODUCTION_READINESS

## Purpose

This module provides guidance for version management, changelog maintenance, release tagging, and deployment processes. Use this module to establish consistent, reliable release workflows.

## When to Use This Module

Reference this module when:
- Preparing a new release
- Creating version tags
- Writing changelog entries
- Setting up automated releases
- Defining release cadence
- Implementing semantic versioning
- Creating release notes

## Semantic Versioning

### Version Format

`MAJOR.MINOR.PATCH` (e.g., 1.2.3)

| Component | When to Increment | Examples |
|-----------|-------------------|----------|
| **MAJOR** | Breaking changes | API changes, removed features |
| **MINOR** | New features (backward compatible) | New endpoints, optional parameters |
| **PATCH** | Bug fixes (backward compatible) | Security patches, bug fixes |

### Pre-release Versions

- `1.0.0-alpha.1` - Alpha (internal testing)
- `1.0.0-beta.1` - Beta (external testing)
- `1.0.0-rc.1` - Release Candidate

## Changelog Management

### Format (Keep a Changelog)

```markdown
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- New feature X for doing Y

### Changed
- Updated dependency Z to v2.0

### Deprecated
- Feature A will be removed in v3.0

### Removed
- (None)

### Fixed
- Bug in feature B

### Security
- Patched vulnerability CVE-2024-1234

## [1.2.0] - 2024-01-15

### Added
- User profile customization
- Dark mode support

### Fixed
- Login redirect issue
- Memory leak in background sync

## [1.1.0] - 2024-01-01

### Added
- Email notifications
- Export to CSV

[Unreleased]: https://github.com/user/repo/compare/v1.2.0...HEAD
[1.2.0]: https://github.com/user/repo/compare/v1.1.0...v1.2.0
[1.1.0]: https://github.com/user/repo/releases/tag/v1.1.0
```

### Automated Changelog Generation

```bash
#!/bin/bash
# generate-changelog.sh

# Get commits since last tag
LAST_TAG=$(git describe --tags --abbrev=0)
git log $LAST_TAG..HEAD --pretty=format:"- %s (%h)" --no-merges

# Or use conventional-changelog
npm install -g conventional-changelog-cli
conventional-changelog -p angular -i CHANGELOG.md -s
```

## Release Workflow

### 1. Pre-Release Checklist

- [ ] All tests passing
- [ ] Documentation updated
- [ ] CHANGELOG.md updated
- [ ] Version bumped in package.json/VERSION
- [ ] Dependencies updated (security patches)
- [ ] Release notes drafted
- [ ] Migration guide written (if breaking changes)

### 2. Version Bump Script

```bash
#!/bin/bash
# bump-version.sh

set -e

VERSION_TYPE=${1:-patch}  # patch, minor, or major

# Update version
npm version $VERSION_TYPE --no-git-tag-version

# Get new version
NEW_VERSION=$(node -p "require('./package.json').version")

# Update VERSION file
echo $NEW_VERSION > VERSION

# Update CHANGELOG.md
DATE=$(date +%Y-%m-%d)
sed -i "s/## \[Unreleased\]/## [Unreleased]\n\n## [$NEW_VERSION] - $DATE/" CHANGELOG.md

# Commit
git add package.json VERSION CHANGELOG.md
git commit -m "chore: release v$NEW_VERSION"

# Create tag
git tag -a "v$NEW_VERSION" -m "Release v$NEW_VERSION"

echo "✅ Version bumped to v$NEW_VERSION"
echo "Run: git push && git push --tags"
```

### 3. Release Notes Template

```markdown
# Release v1.2.0

## 🎉 Highlights

* **Dark Mode**: Users can now toggle between light and dark themes
* **Performance**: 50% faster page load times
* **API v2**: New GraphQL API with better error handling

## ✨ New Features

* User profile customization (#123)
* Email notifications (#145)
* Dark mode support (#167)

## 🐛 Bug Fixes

* Fixed login redirect issue (#134)
* Resolved memory leak in background sync (#156)
* Corrected timezone display (#178)

## ⚠️ Breaking Changes

* API endpoint `/api/v1/users` deprecated (use `/api/v2/users`)
* Configuration format changed (see [Migration Guide](./MIGRATION.md))

## 📦 Dependencies

* Upgraded React to v18.2
* Updated Express to v4.18
* Security patch for lodash (CVE-2024-1234)

## 📚 Documentation

* Added API reference
* Updated deployment guide
* Improved troubleshooting section

## 🙏 Contributors

Thanks to @user1, @user2, @user3 for their contributions!

---

**Full Changelog**: https://github.com/user/repo/compare/v1.1.0...v1.2.0
**Installation**: `npm install my-package@1.2.0`
```

## Automated Release with GitHub Actions

```yaml
# .github/workflows/release.yml
name: Release

on:
  push:
    tags:
      - 'v*'

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
      
      - name: Install dependencies
        run: npm ci
      
      - name: Run tests
        run: npm test
      
      - name: Build
        run: npm run build
      
      - name: Create Release
        uses: actions/create-release@v1
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        with:
          tag_name: ${{ github.ref }}
          release_name: Release ${{ github.ref }}
          body_path: ./RELEASE_NOTES.md
          draft: false
          prerelease: false
      
      - name: Publish to npm
        run: npm publish
        env:
          NODE_AUTH_TOKEN: ${{ secrets.NPM_TOKEN }}
```

## Release Cadence

### Time-Based Releases

- **Weekly**: Bug fixes and minor improvements
- **Monthly**: New features
- **Quarterly**: Major versions

### Event-Based Releases

- **On Demand**: Critical security patches
- **Feature Complete**: When milestone reached

## Migration Guides

```markdown
# Migration Guide: v1.x to v2.0

## Breaking Changes

### 1. Configuration Format

**Before (v1.x)**:
```javascript
const config = {
  apiKey: 'key',
  timeout: 5000
};
```

**After (v2.0)**:
```javascript
const config = {
  auth: {
    apiKey: 'key'
  },
  network: {
    timeout: 5000
  }
};
```

### 2. Removed Features

* `getUserById()` - Use `getUser({ id })` instead
* `updateUserEmail()` - Merged into `updateUser()`

## Step-by-Step Migration

1. Update package version:
   ```bash
   npm install my-package@2.0.0
   ```

2. Update configuration format:
   ```javascript
   // Old
   const client = new Client({ apiKey, timeout });
   
   // New
   const client = new Client({
     auth: { apiKey },
     network: { timeout }
   });
   ```

3. Update function calls:
   ```javascript
   // Old
   await client.getUserById('123');
   
   // New
   await client.getUser({ id: '123' });
   ```

4. Test thoroughly before deploying

## Support

* Questions? [Open an issue](https://github.com/user/repo/issues)
* Need help migrating? [Discussion forum](https://github.com/user/repo/discussions)
```

## Related Modules

- **GIT_WORKFLOW** - Git tagging and branching
- **README_STRUCTURE** - Documentation updates
- **PRODUCTION_READINESS** - Deployment checklist
- **ADR_TEMPLATE** - Architectural decision records
