#!/bin/bash
# Local GitHub Actions Testing Script
# Tests the workflows locally using act (https://github.com/nektos/act)

set -euo pipefail

echo "🧪 Testing GitHub Actions workflows locally..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if act is installed
if ! command -v act &> /dev/null; then
    echo -e "${RED}❌ act is not installed${NC}"
    echo "Please install it: https://github.com/nektos/act#installation"
    echo ""
    echo "Quick install options:"
    echo "  macOS: brew install act"
    echo "  Linux: curl https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash"
    exit 1
fi

echo -e "${GREEN}✅ act is available${NC}"
echo ""

# Check if Docker is running
if ! docker info &> /dev/null; then
    echo -e "${RED}❌ Docker is not running${NC}"
    echo "Please start Docker and try again."
    exit 1
fi

echo -e "${GREEN}✅ Docker is running${NC}"
echo ""

# Test available workflows
echo -e "${YELLOW}📋 Available workflows:${NC}"
act --list
echo ""

# Test the main build workflow (dry-run)
echo -e "${YELLOW}🏗️ Testing main build workflow (dry-run)...${NC}"
act push --dry-run --verbose
echo ""

# Test pull request workflow
echo -e "${YELLOW}🔍 Testing pull request workflow (dry-run)...${NC}"
act pull_request --dry-run --verbose
echo ""

# Test security workflow
echo -e "${YELLOW}🛡️ Testing security workflow (dry-run)...${NC}"
act --workflows .github/workflows/security-quality.yml --dry-run --verbose
echo ""

echo -e "${GREEN}🎉 Local workflow testing complete!${NC}"
echo ""
echo -e "${YELLOW}💡 Tips:${NC}"
echo "  - Run 'act push' to actually execute the build workflow"
echo "  - Use 'act -j job-name' to run specific jobs"
echo "  - Add '--verbose' for detailed output"
echo "  - Use '--dry-run' to test without execution"
echo ""
echo "Example commands:"
echo "  act push -j build-and-push                 # Test main build job"
echo "  act pull_request -j dockerfile-checks      # Test security checks"
echo "  act --workflows .github/workflows/cleanup-images.yml  # Test cleanup"