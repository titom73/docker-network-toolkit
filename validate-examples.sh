#!/bin/bash
# Validation script for COMMANDS.md examples
# This script validates that all examples in the documentation work correctly

set -euo pipefail

echo "🧪 Validating COMMANDS.md examples..."

# Change to project root
cd "$(dirname "$0")"

echo "📋 Testing basic commands..."

# Test projects listing
echo "✓ Testing: make projects"
make projects > /dev/null

# Test help
echo "✓ Testing: make help"
make help > /dev/null

echo "🐳 Testing container naming examples (dry-run)..."

# Test default configuration
echo "✓ Testing: Default configuration"
OUTPUT=$(make build PROJECT=multitool --dry-run 2>&1)
if [[ $OUTPUT == *"git.as73.inetsix.net/docker/multitool:dev"* ]]; then
    echo "  ✅ Default naming works"
else
    echo "  ❌ Default naming failed"
    exit 1
fi

# Test registry change
echo "✓ Testing: Registry change"
OUTPUT=$(make build PROJECT=multitool REGISTRY_PREFIX=harbor.mycompany.com/network-tools --dry-run 2>&1)
if [[ $OUTPUT == *"harbor.mycompany.com/network-tools/multitool:dev"* ]]; then
    echo "  ✅ Registry prefix override works"
else
    echo "  ❌ Registry prefix override failed"
    exit 1
fi

# Test complete override
echo "✓ Testing: Complete override"
OUTPUT=$(make build PROJECT=multitool IMAGE_NAME=mycustomregistry/tools/multitool IMAGE_TAG=latest --dry-run 2>&1)
if [[ $OUTPUT == *"mycustomregistry/tools/multitool:latest"* ]]; then
    echo "  ✅ Complete override works"
else
    echo "  ❌ Complete override failed"
    exit 1
fi

# Test project shortcuts
echo "✓ Testing: Project shortcuts"
OUTPUT=$(make multitool.build --dry-run 2>&1)
if [[ $OUTPUT == *"git.as73.inetsix.net/docker/multitool:dev"* ]]; then
    echo "  ✅ Project shortcut works"
else
    echo "  ❌ Project shortcut failed"
    exit 1
fi

echo "🎉 All examples from COMMANDS.md are working correctly!"
echo ""
echo "📖 Available documentation files:"
echo "  - COMMANDS.md          : Complete usage documentation (English)"
echo "  - CONTAINER_NAMING.md  : Container naming guide (French)"
echo "  - .env.example         : Environment configuration template"
echo ""
echo "🚀 Ready to use! Try: make help"