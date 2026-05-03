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
NT_SCRIPT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/nt.bash"

if [[ ! -f "$NT_SCRIPT" ]]; then
    echo -e "${RED}✗ nt.bash not found at $NT_SCRIPT${NC}"
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

# Test 1: Install cowsay with default Node version
test_header "Test 1: Install cowsay (small, popular package with binary)"
if "$NT_SCRIPT" install cowsay &>/dev/null; then
    if [[ -d "$NT_HOME/tools/cowsay" ]]; then
        pass "cowsay installed successfully"
    else
        fail "cowsay directory not found"
    fi
else
    fail "cowsay installation failed"
fi

# Test 2: Check if wrapper was created
test_header "Test 2: Check if cowsay binary wrapper exists"
if [[ -x "$NT_HOME/bin/cowsay" ]]; then
    pass "cowsay wrapper created"
else
    fail "cowsay wrapper not found"
fi

# Test 3: List installed tools
test_header "Test 3: List installed tools"
if "$NT_SCRIPT" list | grep -q "cowsay"; then
    pass "cowsay appears in list"
else
    fail "cowsay not in list"
fi

# Test 4: Check Node.js was installed
test_header "Test 4: Check Node.js installation"
if [[ -d "$NT_HOME/node/latest" ]] && [[ -x "$NT_HOME/node/latest/bin/node" ]]; then
    pass "Node.js installed"
else
    fail "Node.js not found"
fi

# Test 5: Install package with specific Node version
test_header "Test 5: Install figlet with Node 20"
if "$NT_SCRIPT" install --node=20 figlet &>/dev/null; then
    if [[ -d "$NT_HOME/tools/figlet" ]]; then
        pass "figlet installed with Node 20"
    else
        fail "figlet directory not found"
    fi
else
    fail "figlet installation failed"
fi

# Test 6: Check Node 20 was installed
test_header "Test 6: Check Node 20 installation"
if [[ -d "$NT_HOME/node/20" ]] && [[ -x "$NT_HOME/node/20/bin/node" ]]; then
    pass "Node 20 installed"
else
    fail "Node 20 not found"
fi

# Test 7: Verify .node-version file
test_header "Test 7: Verify .node-version file for figlet"
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

# Test 8: Remove a package
test_header "Test 8: Remove cowsay"
if "$NT_SCRIPT" remove cowsay &>/dev/null; then
    if [[ ! -d "$NT_HOME/tools/cowsay" ]]; then
        pass "cowsay removed successfully"
    else
        fail "cowsay directory still exists"
    fi
else
    fail "cowsay removal failed"
fi

# Test 9: Verify wrapper was removed
test_header "Test 9: Verify cowsay wrapper was removed"
if [[ ! -f "$NT_HOME/bin/cowsay" ]]; then
    pass "cowsay wrapper removed"
else
    fail "cowsay wrapper still exists"
fi

# Test 10: Install scoped package
test_header "Test 10: Install scoped package (@sindresorhus/is)"
if "$NT_SCRIPT" install @sindresorhus/is &>/dev/null; then
    if [[ -d "$NT_HOME/tools/sindresorhus__is" ]]; then
        pass "scoped package installed"
    else
        fail "scoped package directory not found"
    fi
else
    fail "scoped package installation failed"
fi

# Test 11: Check n was downloaded
test_header "Test 11: Check 'n' was auto-downloaded"
if [[ -x "$NT_HOME/bin/n" ]]; then
    pass "'n' binary exists"
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
