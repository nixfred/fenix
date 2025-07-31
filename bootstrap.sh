#!/bin/bash
# 🔥 FeNix Bootstrap - One Command to Rule Them All
# Usage: curl -s https://raw.githubusercontent.com/nixfred/fenix/main/bootstrap.sh | bash

set -e

# Parse command line arguments
SKIP_SSH=false
PUBLIC_ONLY=false
QUIET_MODE=false
FORCE_MACHINE_TYPE=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --skip-ssh)
            SKIP_SSH=true
            shift
            ;;
        --public-only)
            PUBLIC_ONLY=true
            SKIP_SSH=true
            shift
            ;;
        --quiet)
            QUIET_MODE=true
            shift
            ;;
        --remote-environment)
            FORCE_MACHINE_TYPE="remote"
            shift
            ;;
        --main-workstation)
            FORCE_MACHINE_TYPE="main"
            shift
            ;;
        --help|-h)
            echo "FeNix Bootstrap Options:"
            echo "  --public-only          Install only public configs (no SSH/private)"
            echo "  --skip-ssh             Skip SSH key setup"
            echo "  --quiet                Minimal output"
            echo "  --remote-environment   Force remote environment setup"
            echo "  --main-workstation     Force main workstation setup"
            echo "  --help                 Show this help"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for available options"
            exit 1
            ;;
    esac
done

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

# Machine Identity Detection
detect_machine_type() {
    local current_hostname=$(hostname)
    
    echo -e "${YELLOW}🤖 Machine Identity Detection${RESET}"
    echo "================================"
    echo "Current hostname: $current_hostname"
    echo ""
    echo "Machine Types:"
    echo "1) Remote Environment (pi5-style) - Synchronized work environment"
    echo "2) Main Workstation (ron replacement) - Full digital life transfer"
    echo "3) Auto-detect from hostname"
    echo ""
    
    # Auto-detect for non-interactive mode or default to option 3 for interactive
    if [ -t 0 ]; then
        read -p "What type of machine is this? [1-3]: " machine_type
    else
        machine_type=3  # Auto-detect for non-interactive (piped) input
    fi
    
    case $machine_type in
        1)
            MACHINE_ROLE="remote"
            echo -e "${CYAN}📍 Configuring as REMOTE ENVIRONMENT${RESET}"
            echo "   • Will keep current hostname: $current_hostname"
            echo "   • Synchronized configs but separate identity"
            echo "   • Will connect back to main workstation"
            ;;
        2)
            MACHINE_ROLE="main"
            echo -e "${GREEN}📍 Configuring as MAIN WORKSTATION${RESET}"
            echo "   • Will change hostname to 'ron' and inherit full configuration"
            echo "   • SSH keys, containers, and data will be restored"
            echo "   • Remote machines will connect to this as primary"
            ;;
        3|"")
            # Relaxed auto-detection: check for common main workstation indicators
            if [[ "$current_hostname" == "ron" ]] || [[ "$current_hostname" == *"main"* ]] || [[ "$current_hostname" == *"workstation"* ]]; then
                MACHINE_ROLE="main"
                echo -e "${GREEN}📍 AUTO-DETECTED: MAIN WORKSTATION ($current_hostname)${RESET}"
                echo "   • Detected as main workstation based on hostname pattern"
            else
                MACHINE_ROLE="remote"
                echo -e "${CYAN}📍 AUTO-DETECTED: REMOTE ENVIRONMENT ($current_hostname)${RESET}"
                echo "   • Will keep current hostname and configure as remote environment"
            fi
            ;;
        *)
            echo -e "${YELLOW}⚠️  Unknown input '$machine_type'. Using auto-detection.${RESET}"
            # Fall back to auto-detection logic
            if [[ "$current_hostname" == "ron" ]] || [[ "$current_hostname" == *"main"* ]] || [[ "$current_hostname" == *"workstation"* ]]; then
                MACHINE_ROLE="main"
                echo -e "${GREEN}📍 DEFAULTED: MAIN WORKSTATION ($current_hostname)${RESET}"
            else
                MACHINE_ROLE="remote"
                echo -e "${CYAN}📍 DEFAULTED: REMOTE ENVIRONMENT ($current_hostname)${RESET}"
            fi
            ;;
    esac
    
    export MACHINE_ROLE
    export CURRENT_HOSTNAME="$current_hostname"
}
echo -e "${RESET}"

FENIX_DIR="$HOME/.fenix"
START_TIME=$(date +%s)

# Detect machine type first (unless forced)
if [ -n "$FORCE_MACHINE_TYPE" ]; then
    MACHINE_ROLE="$FORCE_MACHINE_TYPE"
    CURRENT_HOSTNAME=$(hostname)
    echo -e "${GREEN}🎯 Machine type forced: $MACHINE_ROLE${RESET}"
else
    detect_machine_type
fi

# Phase 1: Public System Setup
echo -e "${YELLOW}📦 Phase 1: Public System Setup${RESET}"
echo "================================="

# Install essential tools
if command -v apt >/dev/null 2>&1; then
    echo "🔧 Installing FeNix essential packages..."
    sudo apt update && sudo apt install -y \
        git curl wget nano htop docker.io \
        neofetch screenfetch bat tree colordiff \
        unzip p7zip-full unrar-free \
        net-tools netstat-nat iotop \
        python3 python3-pip \
        jq ripgrep fd-find \
        qrencode build-essential
elif command -v dnf >/dev/null 2>&1; then
    echo "🔧 Installing FeNix essential packages (Fedora)..."
    sudo dnf install -y \
        git curl wget nano htop docker \
        neofetch screenfetch bat tree colordiff \
        unzip p7zip unrar \
        net-tools iotop \
        python3 python3-pip \
        jq ripgrep fd-find \
        qrencode @development-tools
elif command -v pacman >/dev/null 2>&1; then
    echo "🔧 Installing FeNix essential packages (Arch)..."
    sudo pacman -Sy --noconfirm \
        git curl wget nano htop docker \
        neofetch screenfetch bat tree colordiff \
        unzip p7zip unrar \
        net-tools iotop \
        python python-pip \
        jq ripgrep fd \
        qrencode base-devel
fi

# Clone public repositories
echo "📥 Cloning FeNix public repositories..."
mkdir -p "$FENIX_DIR"
cd "$FENIX_DIR"

git clone https://github.com/nixfred/fenix.git public
git clone https://github.com/nixfred/fenix-dotfiles.git dotfiles

# Install public dotfiles
echo "🏠 Installing public dotfiles..."
cd dotfiles
./install.sh --stage1

echo -e "${GREEN}✅ Phase 1 Complete: Basic system ready!${RESET}"

# Exit early if public-only mode
if [ "$PUBLIC_ONLY" = true ]; then
    END_TIME=$(date +%s)
    TOTAL_TIME=$((END_TIME - START_TIME))
    
    echo ""
    echo -e "${BOLD}${GREEN}🎉 FeNix PUBLIC-ONLY Installation Complete! 🎉${RESET}"
    echo -e "${CYAN}Total time: ${TOTAL_TIME} seconds${RESET}"
    echo ""
    echo -e "${YELLOW}Public-only installation includes:${RESET}"
    echo "• Dynamic shell environment (.bashrc with intelligent path detection)"
    echo "• Enhanced aliases and functions for productivity"
    echo "• Multi-host aware configurations"
    echo "• Basic FeNix directory structure"
    echo ""
    echo -e "${CYAN}To complete setup:${RESET}"
    echo "• Run: source ~/.bashrc"
    echo "• Test: j proj (should jump to project directory)"
    echo "• For full FeNix: Re-run without --public-only flag"
    echo ""
    echo -e "${CYAN}FeNix System (public-only) ready! 🔥${RESET}"
    exit 0
fi

echo ""

# Phase 2: SSH Key Setup (unless skipped)
if [ "$SKIP_SSH" = false ]; then
    echo -e "${YELLOW}🔑 Phase 2: SSH Key Setup${RESET}"
    echo "=========================="
else
    echo -e "${YELLOW}⏭️  Phase 2: SSH Key Setup (SKIPPED)${RESET}"
    echo "==============================="
fi

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

if [ "$SKIP_SSH" = false ] && setup_ssh_keys; then
    # Phase 3: Private Repository Setup
    echo ""
    echo -e "${YELLOW}🔐 Phase 3: Private Repository Setup${RESET}"
    echo "===================================="
    
    echo "📥 Cloning private repositories..."
    cd "$FENIX_DIR"
    
    if git clone git@github.com:nixfred/fenix-private.git private 2>/dev/null; then
        echo "🏠 Installing private dotfiles..."
        cd private
        
        # Machine-specific configuration
        if [ "$MACHINE_ROLE" = "main" ]; then
            echo -e "${GREEN}🏠 MAIN WORKSTATION SETUP${RESET}"
            
            # Full identity transfer for main workstation
            ./install.sh --main-workstation 2>/dev/null || ./install.sh --stage3
            
            # Change hostname to ron if not already
            if [ "$CURRENT_HOSTNAME" != "ron" ]; then
                echo -e "${YELLOW}🏷️  Changing hostname to 'ron'...${RESET}"
                echo "ron" | sudo tee /etc/hostname >/dev/null
                sudo sed -i "s/$CURRENT_HOSTNAME/ron/g" /etc/hosts 2>/dev/null || true
                echo -e "${CYAN}💡 Hostname will be 'ron' after reboot${RESET}"
            fi
            
            # Install SSH keys with full permissions
            if [ -d ssh ]; then
                cp -r ssh/* ~/.ssh/ 2>/dev/null || true
                chmod 700 ~/.ssh
                chmod 600 ~/.ssh/id_* 2>/dev/null || true
                chmod 644 ~/.ssh/*.pub 2>/dev/null || true
                echo -e "${GREEN}🔑 Main workstation SSH keys installed${RESET}"
            fi
            
            # Install main workstation specific configs
            [ -f .bashrc_main ] && cp .bashrc_main ~/.bashrc_private
            [ -f .bash_aliases_main ] && cp .bash_aliases_main ~/.bash_aliases
            
        else
            echo -e "${CYAN}🖥️  REMOTE ENVIRONMENT SETUP${RESET}"
            
            # Remote environment configuration
            ./install.sh --remote-environment 2>/dev/null || ./install.sh --stage3
            
            # Keep current hostname
            echo -e "${CYAN}🏷️  Keeping hostname: $CURRENT_HOSTNAME${RESET}"
            
            # Install SSH keys for connecting back to main
            if [ -d ssh ]; then
                cp -r ssh/* ~/.ssh/ 2>/dev/null || true
                chmod 700 ~/.ssh
                chmod 600 ~/.ssh/id_* 2>/dev/null || true
                chmod 644 ~/.ssh/*.pub 2>/dev/null || true
                echo -e "${CYAN}🔑 Remote environment SSH keys installed${RESET}"
                
                # Add ron to known hosts if not present
                if ! grep -q "ron" ~/.ssh/known_hosts 2>/dev/null; then
                    echo -e "${CYAN}🔗 Adding ron to SSH known hosts...${RESET}"
                    ssh-keyscan ron >> ~/.ssh/known_hosts 2>/dev/null || true
                fi
            fi
            
            # Install remote environment specific configs  
            [ -f .bashrc_remote ] && cp .bashrc_remote ~/.bashrc_private
            [ -f .bash_aliases_remote ] && cp .bash_aliases_remote ~/.bash_aliases
            
            # Create connection alias to main workstation
            echo "alias gohome='ssh ron'" >> ~/.bash_aliases 2>/dev/null || true
        fi
        
        echo -e "${GREEN}✅ Phase 3 Complete: Private configuration installed!${RESET}"
    else
        echo -e "${YELLOW}⚠️  Private repo not accessible yet. Creating from current config...${RESET}"
        echo "You can run 'fenix sync-private' later to push your configs."
    fi
else
    if [ "$SKIP_SSH" = true ]; then
        echo -e "${YELLOW}⏭️  Skipping private repository setup (SSH setup skipped)${RESET}"
    else
        echo -e "${YELLOW}⏭️  Skipping private repository setup (SSH not configured)${RESET}"
    fi
fi

# Phase 4: Container Setup
echo ""
echo -e "${YELLOW}🐳 Phase 4: Container Environment Setup${RESET}"
echo "======================================="

echo "🐳 Setting up FeNix container management..."

# Install container management system
if [ -f "$FENIX_DIR/public/containers/install.sh" ]; then
    echo "📦 Installing FeNix container management tools..."
    cd "$FENIX_DIR/public/containers"
    ./install.sh
    echo -e "${GREEN}✅ Container management system installed!${RESET}"
else
    echo -e "${YELLOW}⚠️  Container management system not found${RESET}"
    
    # Fallback: basic Docker setup if available
    if command -v docker >/dev/null 2>&1; then
        echo "🔧 Setting up basic Docker access..."
        sudo usermod -aG docker "$USER" 2>/dev/null || true
        echo -e "${GREEN}✅ Basic Docker setup complete!${RESET}"
        echo -e "${CYAN}💡 Log out and back in for Docker permissions to take effect.${RESET}"
    else
        echo -e "${YELLOW}⚠️  Docker not available. Container features will be limited.${RESET}"
    fi
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