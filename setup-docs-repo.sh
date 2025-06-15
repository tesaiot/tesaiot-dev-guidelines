#!/bin/bash

# Setup script for TES⩓IoT Developer Guidelines Repository
# This script initializes the documentation repository structure

set -e

echo "🚀 Setting up TES⩓IoT Developer Guidelines Repository..."

# Create directory structure
echo "📁 Creating documentation structure..."

directories=(
    "docs"
    "docs/getting-started"
    "docs/architecture" 
    "docs/core-services"
    "docs/api-guidelines"
    "docs/api-reference"
    "docs/development-standards/languages"
    "docs/development-standards/frameworks"
    "docs/configuration"
    "docs/tutorials/beginner"
    "docs/tutorials/intermediate"
    "docs/tutorials/advanced"
    "docs/tutorials/examples"
    "docs/operations"
    "docs/reference"
    "docs/updates"
    "docs/platform-docs"
    "docs/assets/images"
    "docs/assets/diagrams"
    "docs/stylesheets"
    "docs/javascripts"
    "overrides"
    "includes"
)

for dir in "${directories[@]}"; do
    mkdir -p "$dir"
    echo "  ✓ Created $dir"
done

# Create initial index files
echo "📄 Creating index files..."

# Main index
cat > docs/index.md << 'EOF'
# Welcome to TES⩓IoT Developer Guidelines

<div align="center">
  <img src="assets/logo.png" alt="TES⩓IoT Logo" width="200">
  <h3>The Enterprise AIoT Platform with Zero Trust Security</h3>
</div>

## 🚀 Quick Navigation

<div class="grid cards" markdown>

- :material-rocket-launch: **[Getting Started](getting-started/overview.md)**
  
    Get up and running with TES⩓IoT in minutes

- :material-architecture: **[Architecture](architecture/overview.md)**
  
    Understand the platform's design and components

- :material-api: **[API Reference](api-reference/index.md)**
  
    Complete API documentation and examples

- :material-code-tags: **[Development Standards](development-standards/index.md)**
  
    Best practices and coding guidelines

</div>

## 🎯 What is TES⩓IoT?

TES⩓IoT is an enterprise-grade AIoT platform that combines:

- **🔒 Zero Trust Security** - Certificate-based device authentication
- **🤖 AI Integration** - Natural language insights with Flowise
- **📊 Real-time Analytics** - Process millions of data points
- **🔌 Extension Marketplace** - Expand functionality with plugins

## 📚 Documentation Overview

Our documentation is organized into several key sections:

### For Beginners
- [Quick Start Guide](getting-started/quick-start.md) - Deploy your first device in 5 minutes
- [Core Concepts](architecture/core-concepts.md) - Understand fundamental concepts
- [First Project](getting-started/first-project.md) - Build your first IoT application

### For Developers
- [API Guidelines](api-guidelines/index.md) - RESTful API design standards
- [Development Standards](development-standards/index.md) - Code quality guidelines
- [Tutorials](tutorials/index.md) - Step-by-step implementation guides

### For Operations
- [Deployment Guide](operations/deployment.md) - Production deployment strategies
- [Monitoring](operations/monitoring.md) - System health and metrics
- [Security](operations/security.md) - Security best practices

## 🤝 Contributing

We welcome contributions! See our [Contributing Guide](contributing.md) for details.

## 🔗 Resources

- [GitHub Repository](https://github.com/tesaiot/tesa-iot-platform)
- [Community Forum](https://forum.tesaiot.com)
- [API Status](https://status.tesaiot.com)

---

<div align="center">
  <p>Made with ❤️ by the TES⩓IoT Team</p>
  <p>Licensed under Apache 2.0</p>
</div>
EOF

# Create getting-started index
cat > docs/getting-started/index.md << 'EOF'
# Getting Started

Welcome to TES⩓IoT! This section will help you get up and running quickly.

## In This Section

- **[Overview](overview.md)** - Platform introduction and capabilities
- **[Quick Start](quick-start.md)** - Deploy your first device in 5 minutes
- **[Installation](installation.md)** - Detailed installation instructions
- **[First Project](first-project.md)** - Build your first IoT application
- **[Next Steps](next-steps.md)** - Where to go from here

## Prerequisites

Before you begin, ensure you have:

- Docker and Docker Compose installed
- Basic understanding of IoT concepts
- Access to a Linux/macOS/Windows system

## Choose Your Path

<div class="grid cards" markdown>

- :material-speedometer: **I want to try it quickly**
  
    → Go to [Quick Start](quick-start.md)

- :material-server: **I want to deploy production**
  
    → Go to [Installation](installation.md)

- :material-school: **I want to learn the concepts**
  
    → Go to [Overview](overview.md)

</div>
EOF

# Create architecture index
cat > docs/architecture/index.md << 'EOF'
# Platform Architecture

Understanding TES⩓IoT's architecture is key to leveraging its full potential.

## Architecture Components

- **[Overview](overview.md)** - High-level system architecture
- **[Core Concepts](core-concepts.md)** - Fundamental concepts and terminology
- **[System Design](system-design.md)** - Design principles and patterns
- **[Data Flow](data-flow.md)** - How data moves through the system
- **[Security Model](security-model.md)** - Zero Trust security architecture
- **[Scalability](scalability.md)** - Scaling strategies and patterns

## Key Design Principles

1. **Security First** - Zero Trust architecture with PKI
2. **Scalability** - Handle millions of devices
3. **Extensibility** - Plugin architecture for customization
4. **Reliability** - 99.99% uptime SLA
5. **Performance** - Sub-5ms API response times
EOF

# Create basic overview pages
cat > docs/getting-started/overview.md << 'EOF'
# Platform Overview

## What is TES⩓IoT?

TES⩓IoT is an enterprise-grade AIoT (Artificial Intelligence of Things) platform designed for organizations that need:

- Secure device connectivity at scale
- AI-powered insights from IoT data
- Extensible architecture for custom solutions
- Enterprise compliance (NIST CSF 2.0, ISO 27001)

## Core Features

### 🔒 Zero Trust Security
- Certificate-based authentication for every device
- Vault PKI integration
- No hardcoded credentials
- Real-time certificate validation

### 🤖 AI Integration
- Natural language queries with Flowise
- Pre-built AI templates for common use cases
- Custom model integration support
- Real-time anomaly detection

### 📊 Scalable Architecture
- Support for 1M+ concurrent devices
- Multi-region deployment capability
- Horizontal auto-scaling
- <5ms API response times

### 🔌 Extension Marketplace
- Plugin architecture for custom functionality
- Revenue sharing for developers
- Industry-specific solutions
- Easy deployment and management

## Use Cases

TES⩓IoT excels in:

- **Manufacturing** - Predictive maintenance, quality control
- **Healthcare** - Patient monitoring, asset tracking
- **Smart Cities** - Infrastructure monitoring, energy management
- **Agriculture** - Precision farming, environmental monitoring

## Next Steps

Ready to get started? Choose your path:

- [Quick Start](quick-start.md) - Try it in 5 minutes
- [Installation](installation.md) - Set up production environment
- [Architecture](../architecture/overview.md) - Deep dive into design
EOF

# Create license file
cat > docs/license.md << 'EOF'
# License

## Documentation License

This documentation is licensed under the [Creative Commons Attribution 4.0 International License](http://creativecommons.org/licenses/by/4.0/).

You are free to:

- **Share** — copy and redistribute the material in any medium or format
- **Adapt** — remix, transform, and build upon the material for any purpose, even commercially

Under the following terms:

- **Attribution** — You must give appropriate credit, provide a link to the license, and indicate if changes were made.

## Platform License

The TES⩓IoT Platform is dual-licensed:

### Community Edition
- Licensed under Apache License 2.0
- Free for commercial and non-commercial use
- Limited to basic features

### Enterprise Edition
- Commercial license required
- Contact sales@tesaiot.com for pricing
- Includes advanced features and support

## Third-Party Licenses

This platform includes software from third parties. See [THIRD_PARTY_LICENSES.md](https://github.com/tesaiot/tesa-iot-platform/blob/main/THIRD_PARTY_LICENSES.md) for details.
EOF

# Create .gitignore
cat > .gitignore << 'EOF'
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
env/
venv/
ENV/
.venv

# MkDocs
site/
.cache/
.sass-cache/

# IDE
.vscode/
.idea/
*.swp
*.swo
*~

# OS
.DS_Store
Thumbs.db

# Documentation build
docs/gen/
docs/build/

# Temporary files
*.tmp
*.temp
*.log

# Credentials (never commit these!)
.env
.env.local
secrets/
*.key
*.pem
EOF

# Create GitHub Actions secrets template
cat > .github/workflows/secrets.example << 'EOF'
# GitHub Secrets Required for Documentation Deployment

## Required Secrets:

1. **DOCS_REPO_TOKEN**
   - Personal Access Token with repo scope
   - Used for syncing from main platform repository
   - Create at: https://github.com/settings/tokens

2. **GOOGLE_ANALYTICS_KEY** (Optional)
   - Google Analytics measurement ID
   - Format: G-XXXXXXXXXX
   - For tracking documentation usage

## Setup Instructions:

1. Go to Settings → Secrets and variables → Actions
2. Click "New repository secret"
3. Add each secret with its value

## For Cross-Repository Sync:

The main platform repository needs DOCS_REPO_TOKEN to push updates here.
EOF

# Create initial assets
echo "🎨 Creating placeholder assets..."
mkdir -p docs/assets
touch docs/assets/logo.png
touch docs/assets/favicon.png
touch docs/stylesheets/extra.css
touch docs/javascripts/mathjax.js

# Create contributing guide
cat > CONTRIBUTING.md << 'EOF'
# Contributing to TES⩓IoT Documentation

We love your input! We want to make contributing to TES⩓IoT documentation as easy and transparent as possible.

## Development Process

1. Fork the repo and create your branch from `main`
2. Make your changes
3. Test locally with `mkdocs serve`
4. Ensure no broken links with `linkchecker`
5. Submit a pull request

## Documentation Standards

- Use clear, concise language
- Include code examples where relevant
- Follow the existing structure
- Add screenshots for UI-related docs
- Update the navigation in `mkdocs.yml`

## Local Development

```bash
# Install dependencies
pip install -r requirements.txt

# Serve locally
mkdocs serve

# Build
mkdocs build
```

## Pull Request Process

1. Update documentation with your changes
2. Test all links and code examples
3. Update the CHANGELOG.md if applicable
4. PR will be merged after review

## License

By contributing, you agree that your contributions will be licensed under CC BY 4.0.
EOF

# Create initial CHANGELOG
cat > CHANGELOG.md << 'EOF'
# Changelog

All notable changes to the TES⩓IoT Developer Guidelines will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [Unreleased]

### Added
- Initial documentation structure
- Getting Started guide
- Architecture overview
- API reference framework
- Development standards
- MkDocs Material theme setup
- GitHub Pages deployment

### Changed
- N/A

### Deprecated
- N/A

### Removed
- N/A

### Fixed
- N/A

### Security
- N/A

## [0.1.0] - 2025-06-15

### Added
- Initial repository setup
- Basic documentation structure
- CI/CD pipeline for GitHub Pages
EOF

echo "✅ Documentation repository structure created!"
echo ""
echo "📋 Next Steps:"
echo "1. Create a new GitHub repository: tesaiot/tesaiot-dev-guidelines"
echo "2. Initialize git and push this structure:"
echo "   git init"
echo "   git add ."
echo "   git commit -m 'Initial documentation setup'"
echo "   git remote add origin git@github.com:tesaiot/tesaiot-dev-guidelines.git"
echo "   git push -u origin main"
echo ""
echo "3. Enable GitHub Pages in repository settings"
echo "4. Add required secrets (see .github/workflows/secrets.example)"
echo "5. The documentation will auto-deploy on push to main"
echo ""
echo "🔄 For syncing with main platform repo:"
echo "   - Add DOCS_REPO_TOKEN secret to main platform repo"
echo "   - Use ./scripts/sync-documentation.sh for manual sync"
echo "   - GitHub Actions will handle automatic sync on push"