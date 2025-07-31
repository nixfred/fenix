#!/bin/bash
# 🔥 FeNix Bootstrap - One Command to Rule Them All
# Usage: curl -s https://raw.githubusercontent.com/nixfred/fenix/main/bootstrap.sh | bash

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

echo -e "${BOLD}${CYAN}"
echo "🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥"
echo "              FeNix RESURRECTION                "
echo "         Digital Life as Code (DLaC)           "
echo "   From Zero to Hero in Under 10 Minutes       "
echo "🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥"
echo -e "${RESET}"

FENIX_DIR="$HOME/.fenix"
START_TIME=$(date +%s)

# Phase 1: Public System Setup
echo -e "${YELLOW}📦 Phase 1: Public System Setup${RESET}"
echo "================================="

# Install essential tools
if command -v apt >/dev/null 2>&1; then
    echo "🔧 Installing essential tools..."
    sudo apt update && sudo apt install -y git curl wget nano htop docker.io
elif command -v dnf >/dev/null 2>&1; then
    echo "🔧 Installing essential tools (Fedora)..."
    sudo dnf install -y git curl wget nano htop docker
elif command -v pacman >/dev/null 2>&1; then
    echo "🔧 Installing essential tools (Arch)..."
    sudo pacman -Sy --noconfirm git curl wget nano htop docker
fi

# Clone public repositories
echo "📥 Cloning FeNix public repositories..."
mkdir -p "$FENIX_DIR"
cd "$FENIX_DIR"

git clone https://github.com/nixfred/fenix.git public
git clone https://github.com/nixfred/dotfiles-public.git dotfiles

# Install public dotfiles
echo "🏠 Installing public dotfiles..."
cd dotfiles
./install.sh --stage1

echo -e "${GREEN}✅ Phase 1 Complete: Basic system ready!${RESET}"
echo ""

# Phase 2: SSH Key Setup
echo -e "${YELLOW}🔑 Phase 2: SSH Key Setup${RESET}"
echo "=========================="

setup_ssh_keys() {
    echo "Choose SSH key setup method:"
    echo "1) I have existing SSH keys (paste them)"
    echo "2) Generate new SSH keys"  
    echo "3) Import from GitHub (requires username)"
    echo "4) Skip for now (manual setup later)"
    
    read -p "Enter choice [1-4]: " ssh_choice
    
    case $ssh_choice in
        1)
            echo "Paste your private key (press Ctrl+D when done):"
            mkdir -p ~/.ssh
            cat > ~/.ssh/id_rsa
            chmod 600 ~/.ssh/id_rsa
            
            echo "Paste your public key:"
            cat > ~/.ssh/id_rsa.pub
            chmod 644 ~/.ssh/id_rsa.pub
            ;;
        2)
            echo "Generating new SSH key..."
            read -p "Enter your email: " email
            ssh-keygen -t rsa -b 4096 -C "$email" -f ~/.ssh/id_rsa -N ""
            echo ""
            echo "🔑 Your public key (add this to GitHub):"
            echo "========================================"
            cat ~/.ssh/id_rsa.pub
            echo "========================================"
            read -p "Press Enter after adding key to GitHub..."
            ;;
        3)
            read -p "Enter GitHub username: " github_user
            curl -s "https://github.com/$github_user.keys" > ~/.ssh/id_rsa.pub
            echo "⚠️  Public key imported. You'll need the private key manually."
            ;;
        4)
            echo "⏭️  Skipping SSH setup. Run 'fenix setup-ssh' later."
            return 0
            ;;
    esac
    
    # Test SSH connection
    echo "🧪 Testing SSH connection to GitHub..."
    if ssh -T git@github.com -o ConnectTimeout=10 2>&1 | grep -q "successfully authenticated"; then
        echo -e "${GREEN}✅ SSH connection to GitHub working!${RESET}"
        return 0
    else
        echo -e "${YELLOW}⚠️  SSH not working yet. You may need to add key to GitHub.${RESET}"
        return 1
    fi
}

if setup_ssh_keys; then
    # Phase 3: Private Repository Setup
    echo ""
    echo -e "${YELLOW}🔐 Phase 3: Private Repository Setup${RESET}"
    echo "===================================="
    
    echo "📥 Cloning private repositories..."
    cd "$FENIX_DIR"
    
    if git clone git@github.com:nixfred/dotfiles-private.git private 2>/dev/null; then
        echo "🏠 Installing private dotfiles..."
        cd private
        ./install.sh --stage3
        
        # Link SSH keys from private repo
        if [ -d ssh ]; then
            ln -sf "$FENIX_DIR/private/ssh"/* ~/.ssh/ 2>/dev/null || true
            chmod 600 ~/.ssh/id_rsa 2>/dev/null || true
            chmod 644 ~/.ssh/id_rsa.pub 2>/dev/null || true
        fi
        
        echo -e "${GREEN}✅ Phase 3 Complete: Private configuration installed!${RESET}"
    else
        echo -e "${YELLOW}⚠️  Private repo not accessible yet. Creating from current config...${RESET}"
        echo "You can run 'fenix sync-private' later to push your configs."
    fi
else
    echo -e "${YELLOW}⏭️  Skipping private repository setup (SSH not configured)${RESET}"
fi

# Phase 4: Container Setup
echo ""
echo -e "${YELLOW}🐳 Phase 4: Container Environment Setup${RESET}"
echo "======================================="

if command -v docker >/dev/null 2>&1; then
    echo "🔧 Setting up Docker access..."
    sudo usermod -aG docker "$USER" 2>/dev/null || true
    
    if [ -d "$FENIX_DIR/public/containers" ]; then
        echo "📦 Installing container management tools..."
        cd "$FENIX_DIR/public/containers"
        ./install.sh
    fi
    
    echo -e "${GREEN}✅ Container environment ready!${RESET}"
    echo -e "${CYAN}💡 Log out and back in for Docker permissions to take effect.${RESET}"
else
    echo -e "${YELLOW}⚠️  Docker not available. Skipping container setup.${RESET}"
fi

# Finalization
END_TIME=$(date +%s)
TOTAL_TIME=$((END_TIME - START_TIME))

echo ""
echo -e "${BOLD}${GREEN}🎉🎉🎉 FeNix RESURRECTION COMPLETE! 🎉🎉🎉${RESET}"
echo -e "${CYAN}Total time: ${TOTAL_TIME} seconds${RESET}"
echo ""
echo -e "${YELLOW}Next steps:${RESET}"
echo "• Run: source ~/.bashrc"
echo "• Test: j proj (should jump to project directory)"
echo "• Test: edc (container access if Docker available)"
echo "• Configure: fenix config (for host-specific settings)"
echo ""
echo -e "${CYAN}Welcome back to your digital life! 🔥${RESET}"