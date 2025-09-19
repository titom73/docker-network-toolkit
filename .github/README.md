# GitHub Actions Workflows

This repository uses automated GitHub Actions workflows to build, test, and deploy Docker images. All workflows are designed to work with the unified Makefile system and support multi-architecture builds.

## 🚀 Workflow Overview

### 1. `docker-build-push.yml` - Main Build and Push Pipeline

**Triggers:**

- Push to `main` branch
- Git tags (`v*`)
- Pull requests to `main`
- Manual dispatch

**Features:**

- 🔍 **Smart change detection**: Only builds projects with actual changes
- 🏗️ **Multi-architecture builds**: `linux/amd64` and `linux/arm64`
- 📦 **GitHub Container Registry**: Images pushed to `ghcr.io/titom73/`
- 🏷️ **Intelligent tagging**:
  - `latest`: Latest version from main branch
  - `main`: Latest commit on main branch
  - `v*`: Git tag versions
  - PR numbers for pull requests
- ⚡ **Build cache**: Uses GitHub Actions cache for faster builds
- 📊 **Build summary**: Detailed reports in GitHub Actions

**Image naming:**

```text
ghcr.io/titom73/multitool:latest
ghcr.io/titom73/ssh-server:v1.2.3
ghcr.io/titom73/freeradius-server:main
```

### 2. `security-quality.yml` - Security and Quality Checks

**Triggers:**

- Pull requests to `main`
- Push to `main` branch
- Weekly schedule (Mondays 6 AM UTC)
- Manual dispatch

**Features:**

- 🔍 **Dockerfile linting**: Uses [hadolint](https://github.com/hadolint/hadolint)
- 🛡️ **Vulnerability scanning**: Uses [Trivy](https://github.com/aquasecurity/trivy)
- 📋 **Security reports**: Uploads results to GitHub Security tab
- 🧪 **Makefile validation**: Tests all Makefile commands
- ✅ **Container naming tests**: Validates examples from documentation

### 3. `cleanup-images.yml` - Image Maintenance

**Triggers:**

- Weekly schedule (Sundays 2 AM UTC)
- Manual dispatch

**Features:**

- 🧹 **Automatic cleanup**: Removes old untagged image versions
- 📦 **Version retention**: Keeps 10 most recent versions per project
- 🔄 **Registry maintenance**: Prevents registry storage bloat

## 🔧 Configuration

### Environment Setup (Required for Private Repositories)

For **private repositories**, the workflows use GitHub Environments for secure credential management:

#### 1. Create Production Environment

Navigate to: Repository → Settings → Environments → New environment

- **Name**: `production`
- **Configuration**: See detailed setup below

#### 2. Environment Variables

Configure in the `production` environment:

- `REGISTRY`: Container registry URL (default: `ghcr.io`)
- `REGISTRY_PREFIX`: Image name prefix (default: `ghcr.io/your-username`)
- `REGISTRY_USERNAME`: Registry username (default: `github.actor`)
- `CLEANUP_KEEP_VERSIONS`: Number of versions to keep (default: `10`)

#### 3. Environment Secrets

Configure in the `production` environment:

- `REGISTRY_TOKEN`: Access token for container registry

**For GitHub Container Registry (GHCR)**:

1. Create Personal Access Token: GitHub → Settings → Developer settings → Personal access tokens
2. Required permissions: Contents (Read), Packages (Write), Metadata (Read)
3. Add token as `REGISTRY_TOKEN` in environment secrets

### Required Secrets (Legacy - use environments instead)

For **public repositories** only - private repos should use environments:

- `GITHUB_TOKEN`: Automatically provided by GitHub Actions

### Environment Variables

```yaml
REGISTRY: ghcr.io
REGISTRY_PREFIX: ghcr.io/titom73
```

## 📁 Project Structure Support

The workflows automatically discover all projects by scanning for directories with `Dockerfile`:

- Checks each subdirectory for presence of `Dockerfile`
- Only builds projects that actually have Docker images to build
- Uses the unified Makefile at repository root for all build operations
- Dynamically adapts to new projects without workflow modifications

Example discovered projects:

- `freeradius-client/` (if contains Dockerfile)
- `freeradius-server/` (if contains Dockerfile)
- `multitool/` (if contains Dockerfile)
- `ssh-server/` (if contains Dockerfile)
- `syslog/` (if contains Dockerfile)
- `tacacs-server/` (if contains Dockerfile)

## 🏷️ Tagging Strategy

### Automatic Tags

- **`latest`**: Always points to the latest stable release from `main`
- **`main`**: Latest commit on the main branch
- **`pr-{number}`**: Pull request builds for testing

### Git Tag Releases

When you create a git tag:

```bash
git tag v1.2.3
git push origin v1.2.3
```

All projects will be built and tagged as:

- `ghcr.io/titom73/multitool:v1.2.3`
- `ghcr.io/titom73/ssh-server:v1.2.3`
- etc.

## 🚦 Build Optimization

### Change Detection

The workflow intelligently detects which projects have changes:

- **File-based detection**: Only builds projects with modified files
- **Forced builds**: Tags and manual triggers build all projects
- **Fallback**: Builds all on main if no changes detected

### Multi-Architecture Support

All images are built for:

- `linux/amd64` (Intel/AMD 64-bit)
- `linux/arm64` (ARM 64-bit, including Apple M1/M2)

### Build Cache

- Uses GitHub Actions cache to speed up builds
- Shares cache layers between similar projects
- Automatic cache invalidation on Dockerfile changes

## 📊 Monitoring and Reports

### Build Status

Each workflow provides detailed summaries:

- ✅ Successfully built projects
- ❌ Failed builds with error details
- 📦 Published image locations
- 🏷️ Applied tags

### Security Reports

Security scans are uploaded to GitHub's Security tab:

- **Code Scanning**: Dockerfile linting results
- **Vulnerability Alerts**: Container image security issues
- **Dependency Review**: Base image vulnerabilities

## 🔧 Local Development

Test the workflows locally using the Makefile:

```bash
# Test change detection logic
make projects

# Test builds (dry-run)
make build PROJECT=multitool --dry-run

# Test container naming
bash validate-examples.sh

# Test registry configuration
make build PROJECT=multitool REGISTRY_PREFIX=ghcr.io/titom73 --dry-run
```

## 🚀 Usage Examples

### Building a Single Project

Push changes to any project directory:

```bash
# Only builds multitool
echo "# Update" >> multitool/README.md
git add multitool/README.md
git commit -m "Update multitool docs"
git push
```

### Release All Projects

Create and push a git tag:

```bash
git tag v1.0.0
git push origin v1.0.0
# → Builds and tags all projects with v1.0.0
```

### Manual Build

Trigger builds manually from GitHub Actions web interface:

1. Go to "Actions" tab
2. Select "Build and Push Docker Images"
3. Click "Run workflow"
4. Choose branch and click "Run workflow"

## 🛠️ Customization

### Adding New Projects

1. Create project directory with Dockerfile
2. The unified Makefile at repository root handles all build operations
3. Workflows automatically discover the new project and include it in builds
4. No manual workflow configuration needed - discovery is automatic based on Dockerfile presence

### Changing Registry

Update the `REGISTRY_PREFIX` in the workflow files:

```yaml
env:
  REGISTRY: your-registry.com
  REGISTRY_PREFIX: your-registry.com/your-namespace
```

### Custom Build Platforms

Modify the platforms in the build step:

```yaml
platforms: linux/amd64,linux/arm64,linux/arm/v7
```

This workflow system provides a robust, scalable, and secure approach to building and deploying Docker images for the network toolkit repository.
