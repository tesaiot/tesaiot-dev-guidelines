#!/bin/bash

# Script to initialize and push TES⩓IoT Developer Guidelines to GitHub
# This script will help you set up the repository and push to GitHub

set -e

echo "🚀 TES⩓IoT Developer Guidelines - Repository Setup"
echo "=================================================="

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Check if git is installed
if ! command -v git &> /dev/null; then
    echo -e "${RED}Error: Git is not installed. Please install git first.${NC}"
    exit 1
fi

# Check if we're in the right directory
if [ ! -f "mkdocs.yml" ]; then
    echo -e "${RED}Error: mkdocs.yml not found. Are you in the right directory?${NC}"
    echo "Please run this script from the tesaiot-dev-guidelines-init directory"
    exit 1
fi

# Initialize git repository if not already initialized
if [ ! -d ".git" ]; then
    echo -e "${YELLOW}Initializing Git repository...${NC}"
    git init
    echo -e "${GREEN}✓ Git repository initialized${NC}"
else
    echo -e "${GREEN}✓ Git repository already initialized${NC}"
fi

# Add all files
echo -e "${YELLOW}Adding files to Git...${NC}"
git add .
echo -e "${GREEN}✓ Files added${NC}"

# Create initial commit
echo -e "${YELLOW}Creating initial commit...${NC}"
git commit -m "Initial commit: TES⩓IoT Developer Guidelines Portal

- Complete MkDocs Material setup
- Getting Started documentation
- Platform architecture docs
- Security model documentation
- REST API reference
- Python development standards
- Tutorials and examples
- GitHub Actions for deployment
- Cross-repository sync automation

Built with MkDocs Material theme for professional documentation portal."

echo -e "${GREEN}✓ Initial commit created${NC}"

# Add remote repository
echo -e "${YELLOW}Adding remote repository...${NC}"
if git remote | grep -q "origin"; then
    echo -e "${YELLOW}Remote 'origin' already exists. Updating URL...${NC}"
    git remote set-url origin git@github.com:tesaiot/tesaiot-dev-guidelines.git
else
    git remote add origin git@github.com:tesaiot/tesaiot-dev-guidelines.git
fi
echo -e "${GREEN}✓ Remote repository configured${NC}"

# Create .gitignore if it doesn't exist
if [ ! -f ".gitignore" ]; then
    echo -e "${YELLOW}Creating .gitignore...${NC}"
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
    git add .gitignore
    git commit -m "Add .gitignore file"
    echo -e "${GREEN}✓ .gitignore created${NC}"
fi

echo ""
echo -e "${GREEN}=================================================="
echo -e "✅ Repository is ready to push!"
echo -e "==================================================${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo ""
echo "1. Make sure you have created the repository on GitHub:"
echo "   https://github.com/new"
echo "   - Repository name: tesaiot-dev-guidelines"
echo "   - Visibility: Public"
echo "   - Do NOT initialize with README, .gitignore, or license"
echo ""
echo "2. Make sure you have SSH access configured:"
echo "   ssh -T git@github.com"
echo ""
echo "3. Push to GitHub:"
echo -e "   ${GREEN}git push -u origin main${NC}"
echo ""
echo "4. After pushing, configure GitHub Pages:"
echo "   - Go to Settings → Pages"
echo "   - Source: GitHub Actions"
echo ""
echo "5. Add the DOCS_REPO_TOKEN secret to your main platform repo:"
echo "   - Go to main platform repo Settings → Secrets"
echo "   - Add DOCS_REPO_TOKEN with a Personal Access Token"
echo ""
echo -e "${YELLOW}Optional: Test documentation locally first:${NC}"
echo "   pip install -r requirements.txt"
echo "   mkdocs serve"
echo "   # Visit http://localhost:8000"
echo ""
echo -e "${GREEN}Ready to push? Run: git push -u origin main${NC}"