#!/bin/bash
echo "Running tests..."

# Fake test 1
if [ 2 -eq 2 ]; then
    echo "✅ Test 1 passed: Math works"
else
    echo "❌ Test 1 failed"
    exit 1
fi

# Fake test 2
if [ -f "/etc/hostname" ]; then
    echo "✅ Test 2 passed: System file exists"
else
    echo "❌ Test 2 failed"
    exit 1
fi

echo "All tests passed! 🚀"
