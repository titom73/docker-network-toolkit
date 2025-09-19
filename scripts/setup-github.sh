#!/bin/bash
# GitHub Repository Setup Script
# Configures the repository for automated Docker builds

set -euo pipefail

echo "🔧 Setting up GitHub repository for Docker Network Toolkit..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Repository configuration
REPO_OWNER="titom73"
REPO_NAME="docker-network-toolkit"
REGISTRY="ghcr.io"

echo -e "${YELLOW}📋 Repository Configuration${NC}"
echo "  Owner: $REPO_OWNER"
echo "  Name: $REPO_NAME"
echo "  Registry: $REGISTRY"
echo ""

# Check if GitHub CLI is installed
if ! command -v gh &> /dev/null; then
    echo -e "${RED}❌ GitHub CLI (gh) is not installed${NC}"
    echo "Please install it: https://cli.github.com/"
    exit 1
fi

# Check if user is logged in
if ! gh auth status &> /dev/null; then
    echo -e "${YELLOW}🔐 Please login to GitHub CLI${NC}"
    gh auth login
fi

echo -e "${GREEN}✅ GitHub CLI is ready${NC}"
echo ""

# Create repository if it doesn't exist
echo -e "${YELLOW}📦 Checking repository status...${NC}"
if gh repo view "$REPO_OWNER/$REPO_NAME" &> /dev/null; then
    echo -e "${GREEN}✅ Repository $REPO_OWNER/$REPO_NAME already exists${NC}"
else
    echo -e "${YELLOW}📦 Creating repository $REPO_OWNER/$REPO_NAME...${NC}"
    gh repo create "$REPO_OWNER/$REPO_NAME" \
        --description "Docker Network Toolkit - Multi-architecture containers for network testing and labs" \
        --homepage "https://github.com/$REPO_OWNER/$REPO_NAME" \
        --public
    echo -e "${GREEN}✅ Repository created${NC}"
fi

# Set up repository settings
echo -e "${YELLOW}⚙️ Configuring repository settings...${NC}"

# Enable GitHub Container Registry
echo "🔐 Enabling GitHub Container Registry access..."
echo "Please ensure your repository has the following settings:"
echo "  1. Go to Settings > Actions > General"
echo "  2. Set 'Workflow permissions' to 'Read and write permissions'"
echo "  3. Check 'Allow GitHub Actions to create and approve pull requests'"
echo ""

# Enable vulnerability alerts
gh api repos/"$REPO_OWNER"/"$REPO_NAME" \
    --method PATCH \
    --field has_vulnerability_alerts=true \
    --silent || true

echo -e "${GREEN}✅ Repository settings configured${NC}"
echo ""

# Environment setup
echo -e "${YELLOW}🔧 Setting up GitHub Environment for private repository...${NC}"
echo ""
echo "For a private repository, you need to configure an environment 'production':"
echo ""
echo "1. Go to: https://github.com/$REPO_OWNER/$REPO_NAME/settings/environments"
echo "2. Click 'New environment' and name it 'production'"
echo "3. Configure the following variables:"
echo ""
echo "   📋 Environment Variables:"
echo "   - REGISTRY: ghcr.io"
echo "   - REGISTRY_PREFIX: ghcr.io/$REPO_OWNER"
echo "   - REGISTRY_USERNAME: $REPO_OWNER"
echo "   - CLEANUP_KEEP_VERSIONS: 10"
echo ""
echo "   🔐 Environment Secrets:"
echo "   - REGISTRY_TOKEN: [Your GitHub Personal Access Token]"
echo ""
echo "4. Create Personal Access Token:"
echo "   - Go to: https://github.com/settings/tokens?type=beta"
echo "   - Create fine-grained token with permissions:"
echo "     • Contents: Read"
echo "     • Packages: Write"
echo "     • Metadata: Read"
echo ""
echo "📖 For detailed instructions, see: GITHUB_ENVIRONMENTS_CONFIG.md"
echo ""

# Display next steps
echo -e "${YELLOW}🚀 Next Steps:${NC}"
echo ""
echo "1. Push your code to the repository:"
echo "   git remote add origin https://github.com/$REPO_OWNER/$REPO_NAME.git"
echo "   git branch -M main"
echo "   git push -u origin main"
echo ""
echo "2. The GitHub Actions workflows will automatically:"
echo "   - Build all projects on push to main"
echo "   - Run security scans on pull requests"
echo "   - Clean up old images weekly"
echo ""
echo "3. Create your first release:"
echo "   git tag v1.0.0"
echo "   git push origin v1.0.0"
echo ""
echo "4. Your images will be available at:"
echo "   $REGISTRY/$REPO_OWNER/multitool:latest"
echo "   $REGISTRY/$REPO_OWNER/ssh-server:latest"
echo "   etc."
echo ""
echo -e "${GREEN}🎉 Setup complete! Your repository is ready for automated Docker builds.${NC}"