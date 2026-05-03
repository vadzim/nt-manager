#!/usr/bin/env fish

# Test counter
set -g TESTS_RUN 0
set -g TESTS_PASSED 0
set -g TESTS_FAILED 0

# Test directory
set -g TEST_DIR (mktemp -d)
set -gx NT_HOME $TEST_DIR/nt

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  nt-manager Test Suite (Fish)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Test directory: $TEST_DIR"
echo "NT_HOME: $NT_HOME"
echo ""

# Path to nt script
set NT_SCRIPT (cd (dirname (status -f))/..; and pwd)/nt

if not test -f $NT_SCRIPT
    echo "✗ nt not found at $NT_SCRIPT"
    exit 1
end

# Helper functions
function pass
    echo "✓ $argv"
    set -g TESTS_PASSED (math $TESTS_PASSED + 1)
    set -g TESTS_RUN (math $TESTS_RUN + 1)
end

function fail
    echo "✗ $argv"
    set -g TESTS_FAILED (math $TESTS_FAILED + 1)
    set -g TESTS_RUN (math $TESTS_RUN + 1)
end

function test_header
    echo ""
    echo "▶ $argv"
end

function cleanup
    echo ""
    echo "Cleaning up test directory..."
    rm -rf $TEST_DIR
end

# Cleanup on exit
trap cleanup EXIT

# Test 1: Install cowsay with default Node version
test_header "Test 1: Install cowsay (small, popular package with binary)"
if $NT_SCRIPT install cowsay &>/dev/null
    if test -d $NT_HOME/tools/cowsay
        pass "cowsay installed successfully"
    else
        fail "cowsay directory not found"
    end
else
    fail "cowsay installation failed"
end

# Test 2: Check if wrapper was created
test_header "Test 2: Check if cowsay binary wrapper exists"
if test -x $NT_HOME/bin/cowsay
    pass "cowsay wrapper created"
else
    fail "cowsay wrapper not found"
end

# Test 3: List installed tools
test_header "Test 3: List installed tools"
if $NT_SCRIPT list | grep -q "cowsay"
    pass "cowsay appears in list"
else
    fail "cowsay not in list"
end

# Test 4: Check Node.js was installed
test_header "Test 4: Check Node.js installation"
if test -d $NT_HOME/node/latest; and test -x $NT_HOME/node/latest/bin/node
    pass "Node.js installed"
else
    fail "Node.js not found"
end

# Test 5: Install package with specific Node version
test_header "Test 5: Install figlet with Node 20"
if $NT_SCRIPT install --node=20 figlet &>/dev/null
    if test -d $NT_HOME/tools/figlet
        pass "figlet installed with Node 20"
    else
        fail "figlet directory not found"
    end
else
    fail "figlet installation failed"
end

# Test 6: Check Node 20 was installed
test_header "Test 6: Check Node 20 installation"
if test -d $NT_HOME/node/20; and test -x $NT_HOME/node/20/bin/node
    pass "Node 20 installed"
else
    fail "Node 20 not found"
end

# Test 7: Verify .node-version file
test_header "Test 7: Verify .node-version file for figlet"
if test -f $NT_HOME/tools/figlet/.node-version
    set node_ver (cat $NT_HOME/tools/figlet/.node-version)
    if test "$node_ver" = "20"
        pass ".node-version contains '20'"
    else
        fail ".node-version contains '$node_ver' instead of '20'"
    end
else
    fail ".node-version file not found"
end

# Test 8: Remove a package
test_header "Test 8: Remove cowsay"
if $NT_SCRIPT remove cowsay &>/dev/null
    if not test -d $NT_HOME/tools/cowsay
        pass "cowsay removed successfully"
    else
        fail "cowsay directory still exists"
    end
else
    fail "cowsay removal failed"
end

# Test 9: Verify wrapper was removed
test_header "Test 9: Verify cowsay wrapper was removed"
if not test -f $NT_HOME/bin/cowsay
    pass "cowsay wrapper removed"
else
    fail "cowsay wrapper still exists"
end

# Test 10: Install scoped package
test_header "Test 10: Install scoped package (@sindresorhus/is)"
if $NT_SCRIPT install @sindresorhus/is &>/dev/null
    if test -d $NT_HOME/tools/sindresorhus__is
        pass "scoped package installed"
    else
        fail "scoped package directory not found"
    end
else
    fail "scoped package installation failed"
end

# Test 11: Check n was downloaded
test_header "Test 11: Check 'n' was auto-downloaded"
if test -x $NT_HOME/bin/n
    pass "'n' binary exists"
else
    fail "'n' binary not found"
end

# Summary
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Test Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Total:  $TESTS_RUN"
echo "Passed: $TESTS_PASSED"
echo "Failed: $TESTS_FAILED"
echo ""

if test $TESTS_FAILED -eq 0
    echo "All tests passed!"
    exit 0
else
    echo "Some tests failed."
    exit 1
end
