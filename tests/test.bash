#!/usr/bin/env bash

set -uo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counter
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Test directory
TEST_DIR=$(mktemp -d)
export NT_HOME="$TEST_DIR/nt"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  nt-manager Test Suite (Bash)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Test directory: $TEST_DIR"
echo "NT_HOME: $NT_HOME"
echo ""

# Path to nt script
NT_SCRIPT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/nt"

if [[ ! -f "$NT_SCRIPT" ]]; then
    echo -e "${RED}✗ nt not found at $NT_SCRIPT${NC}"
    exit 1
fi

# Helper functions
pass() {
    echo -e "${GREEN}✓${NC} $1"
    ((TESTS_PASSED++))
    ((TESTS_RUN++))
}

fail() {
    echo -e "${RED}✗${NC} $1"
    ((TESTS_FAILED++))
    ((TESTS_RUN++))
}

test_header() {
    echo ""
    echo -e "${YELLOW}▶${NC} $1"
}

cleanup() {
    echo ""
    echo "Cleaning up test directory..."
    rm -rf "$TEST_DIR"
}

trap cleanup EXIT

# Test 1: --home option overrides NT_HOME
test_header "Test 1: --home option overrides NT_HOME"
CUSTOM_HOME="$TEST_DIR/custom-nt"
if "$NT_SCRIPT" install --home="$CUSTOM_HOME" cowsay &>/dev/null; then
    if [[ -d "$CUSTOM_HOME/tools/cowsay" ]]; then
        pass "--home option works, cowsay installed to custom location"
    else
        fail "cowsay not found in custom home"
    fi
else
    fail "installation with --home failed"
fi

# Test 2: Verify NT_HOME location was not affected
test_header "Test 2: Verify NT_HOME location was not affected by --home"
if [[ ! -d "$NT_HOME/tools/cowsay" ]]; then
    pass "NT_HOME location unchanged"
else
    fail "cowsay found in NT_HOME (should only be in custom home)"
fi

# Test 3: --home with --node option
test_header "Test 3: --home with --node option"
ANOTHER_HOME="$TEST_DIR/another-nt"
if "$NT_SCRIPT" install --home="$ANOTHER_HOME" --node=18 figlet &>/dev/null; then
    if [[ -d "$ANOTHER_HOME/tools/figlet" ]] && [[ -d "$ANOTHER_HOME/node/18" ]]; then
        pass "--home and --node work together"
    else
        fail "figlet or Node 18 not found in custom home"
    fi
else
    fail "installation with --home and --node failed"
fi

# Test 4: Install cowsay with default Node version
test_header "Test 4: Install cowsay (small, popular package with binary)"
if "$NT_SCRIPT" install cowsay &>/dev/null; then
    if [[ -d "$NT_HOME/tools/cowsay" ]]; then
        pass "cowsay installed successfully"
    else
        fail "cowsay directory not found"
    fi
else
    fail "cowsay installation failed"
fi

# Test 5: Check if wrapper was created
test_header "Test 5: Check if cowsay binary wrapper exists"
if [[ -x "$NT_HOME/bin/cowsay" ]]; then
    pass "cowsay wrapper created"
else
    fail "cowsay wrapper not found"
fi

# Test 6: List installed tools
test_header "Test 6: List installed tools"
if "$NT_SCRIPT" list | grep -q "cowsay"; then
    pass "cowsay appears in list"
else
    fail "cowsay not in list"
fi

# Test 7: Check Node.js was installed
test_header "Test 7: Check Node.js installation"
if [[ -d "$NT_HOME/node/latest" ]] && [[ -x "$NT_HOME/node/latest/bin/node" ]]; then
    pass "Node.js installed"
else
    fail "Node.js not found"
fi

# Test 8: Install package with specific Node version
test_header "Test 8: Install figlet with Node 20"
if "$NT_SCRIPT" install --node=20 figlet &>/dev/null; then
    if [[ -d "$NT_HOME/tools/figlet" ]]; then
        pass "figlet installed with Node 20"
    else
        fail "figlet directory not found"
    fi
else
    fail "figlet installation failed"
fi

# Test 9: Check Node 20 was installed
test_header "Test 9: Check Node 20 installation"
if [[ -d "$NT_HOME/node/20" ]] && [[ -x "$NT_HOME/node/20/bin/node" ]]; then
    pass "Node 20 installed"
else
    fail "Node 20 not found"
fi

# Test 10: Verify .node-version file
test_header "Test 10: Verify .node-version file for figlet"
if [[ -f "$NT_HOME/tools/figlet/.node-version" ]]; then
    node_ver=$(cat "$NT_HOME/tools/figlet/.node-version")
    if [[ "$node_ver" == "20" ]]; then
        pass ".node-version contains '20'"
    else
        fail ".node-version contains '$node_ver' instead of '20'"
    fi
else
    fail ".node-version file not found"
fi

# Test 11: Remove a package
test_header "Test 11: Remove cowsay"
if "$NT_SCRIPT" remove cowsay &>/dev/null; then
    if [[ ! -d "$NT_HOME/tools/cowsay" ]]; then
        pass "cowsay removed successfully"
    else
        fail "cowsay directory still exists"
    fi
else
    fail "cowsay removal failed"
fi

# Test 12: Verify wrapper was removed
test_header "Test 12: Verify cowsay wrapper was removed"
if [[ ! -f "$NT_HOME/bin/cowsay" ]]; then
    pass "cowsay wrapper removed"
else
    fail "cowsay wrapper still exists"
fi

# Test 13: Install scoped package
test_header "Test 13: Install scoped package (@sindresorhus/is)"
if "$NT_SCRIPT" install @sindresorhus/is &>/dev/null; then
    if [[ -d "$NT_HOME/tools/sindresorhus__is" ]]; then
        pass "scoped package installed"
    else
        fail "scoped package directory not found"
    fi
else
    fail "scoped package installation failed"
fi

# Test 14: Check n was downloaded
test_header "Test 14: Check 'n' was auto-downloaded"
if [[ -x "$NT_HOME/.internal/bin/n" ]]; then
    pass "'n' binary exists in internal directory"
else
    fail "'n' binary not found"
fi

# Summary
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Test Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Total:  $TESTS_RUN"
echo -e "Passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Failed: ${RED}$TESTS_FAILED${NC}"
echo ""

if [[ $TESTS_FAILED -eq 0 ]]; then
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed.${NC}"
    exit 1
fi
