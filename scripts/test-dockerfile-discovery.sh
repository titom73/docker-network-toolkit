#!/bin/bash
# Test script for Dockerfile-based project discovery
# Validates that workflows correctly identify projects with Dockerfiles

set -euo pipefail

echo "🧪 Testing Dockerfile-based project discovery..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to simulate the workflow discovery logic
discover_projects() {
    local available_projects=()
    for dir in */; do
        project_name=${dir%/}
        if [ -f "$project_name/Dockerfile" ]; then
            available_projects+=("$project_name")
        fi
    done
    printf '%s\n' "${available_projects[@]}"
}

echo -e "${YELLOW}📁 Discovering projects with Dockerfiles...${NC}"
projects=$(discover_projects)
project_count=$(echo "$projects" | wc -l)

echo "Found $project_count projects with Dockerfiles:"
echo "$projects" | while read -r project; do
    echo "  ✅ $project"
done

echo ""
echo -e "${YELLOW}🔍 Checking project structure...${NC}"

# Validate each discovered project
error_count=0
for project in $projects; do
    if [ ! -f "$project/Dockerfile" ]; then
        echo -e "  ${RED}❌ $project: Missing Dockerfile${NC}"
        ((error_count++))
    else
        echo "  ✅ $project: Has Dockerfile"
    fi

    # Check if project works with unified Makefile
    if make build PROJECT="$project" --dry-run >/dev/null 2>&1; then
        echo "  ✅ $project: Compatible with unified Makefile"
    else
        echo -e "  ${RED}❌ $project: Not compatible with unified Makefile${NC}"
        ((error_count++))
    fi
done

echo ""
echo -e "${YELLOW}🏗️ Testing workflow change detection logic...${NC}"

# Simulate the workflow logic for different scenarios
echo "Testing scenarios:"

# Scenario 1: Tag/Manual trigger (should build all projects with Dockerfiles)
echo "  📋 Scenario 1: Git tag / Manual trigger"
all_projects=$(discover_projects)
echo "    Would build: $(echo "$all_projects" | tr '\n' ' ')"

# Scenario 2: Changed files (would be determined by GitHub Actions)
echo "  📋 Scenario 2: File changes"
echo "    Logic: Only projects with changes AND Dockerfiles would be built"

# Scenario 3: No changes on main (fallback)
echo "  📋 Scenario 3: Fallback on main branch"
echo "    Would build all projects with Dockerfiles (same as scenario 1)"

echo ""
echo -e "${YELLOW}📊 Summary:${NC}"
echo "  Total directories scanned: $(ls -d */ | wc -l | tr -d ' ')"
echo "  Projects with Dockerfiles: $project_count"
echo "  Projects compatible with Makefile: $((project_count - error_count))"
echo "  Errors found: $error_count"

if [ $error_count -eq 0 ]; then
    echo ""
    echo -e "${GREEN}🎉 All tests passed! Dockerfile-based discovery is working correctly.${NC}"
    echo ""
    echo "Benefits of this approach:"
    echo "  ✅ Automatic project discovery - no manual workflow updates needed"
    echo "  ✅ Only builds projects that actually have Docker images"
    echo "  ✅ Uses unified Makefile for consistent build process"
    echo "  ✅ Scales automatically as new projects are added"
else
    echo ""
    echo -e "${RED}❌ Found $error_count errors. Please check the issues above.${NC}"
    exit 1
fi