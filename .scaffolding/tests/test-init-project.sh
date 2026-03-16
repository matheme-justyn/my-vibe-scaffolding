#!/usr/bin/env bash
# test-init-project.sh - Test init-project.sh with different scenarios
# This script runs validation tests WITHOUT modifying the current project state

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

TESTS_PASSED=0
TESTS_FAILED=0

# Test helper functions
pass() {
    echo -e "${GREEN}✓ PASS${NC}: $1"
    ((TESTS_PASSED++))
}

fail() {
    echo -e "${RED}✗ FAIL${NC}: $1"
    ((TESTS_FAILED++))
}

info() {
    echo -e "${YELLOW}ℹ INFO${NC}: $1"
}

echo "======================================"
echo "  init-project.sh Validation Tests"
echo "======================================"
echo ""

# Test 1: Script exists and is executable
info "Test 1: Checking if init-project.sh exists and is executable"
if [ -x "$PROJECT_ROOT/.scaffolding/scripts/init-project.sh" ]; then
    pass "init-project.sh exists and is executable"
else
    fail "init-project.sh not found or not executable"
fi

# Test 2: Script has valid shebang
info "Test 2: Checking shebang"
SHEBANG=$(head -n1 "$PROJECT_ROOT/.scaffolding/scripts/init-project.sh")
if [[ "$SHEBANG" == "#!/usr/bin/env bash" ]] || [[ "$SHEBANG" == "#!/bin/bash" ]]; then
    pass "Valid shebang: $SHEBANG"
else
    fail "Invalid shebang: $SHEBANG"
fi

# Test 3: Check for required files it creates
info "Test 3: Checking if script contains file creation logic"
REQUIRED_FILES=(
    "VERSION"
    "config.toml"
    ".gitignore"
)

for file in "${REQUIRED_FILES[@]}"; do
    if grep -q "$file" "$PROJECT_ROOT/.scaffolding/scripts/init-project.sh"; then
        pass "Script references $file"
    else
        fail "Script doesn't reference $file"
    fi
done

# Test 4: Check for mode detection logic
info "Test 4: Checking mode detection logic"
if grep -q "\.template-version" "$PROJECT_ROOT/.scaffolding/scripts/init-project.sh"; then
    pass "Script has .template-version detection"
else
    fail "Script missing .template-version detection"
fi

# Test 5: Check for scaffolding vs project mode handling
info "Test 5: Checking mode handling"
if grep -q 'mode.*scaffolding\|mode.*project' "$PROJECT_ROOT/.scaffolding/scripts/init-project.sh"; then
    pass "Script handles scaffolding/project modes"
else
    fail "Script missing mode handling"
fi

# Test 6: Dry-run test (check script syntax)
info "Test 6: Running bash syntax check"
if bash -n "$PROJECT_ROOT/.scaffolding/scripts/init-project.sh" 2>/dev/null; then
    pass "Script has valid bash syntax"
else
    fail "Script has syntax errors"
fi

# Test 7: Check if script handles missing dependencies gracefully
info "Test 7: Checking dependency handling"
if grep -q 'command -v\|which' "$PROJECT_ROOT/.scaffolding/scripts/init-project.sh"; then
    pass "Script checks for command dependencies"
else
    info "Script doesn't check dependencies (may be intentional)"
fi

# Summary
echo ""
echo "======================================"
echo "  Test Summary"
echo "======================================"
echo -e "${GREEN}Passed: $TESTS_PASSED${NC}"
echo -e "${RED}Failed: $TESTS_FAILED${NC}"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}✗ Some tests failed${NC}"
    exit 1
fi
