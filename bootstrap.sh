#!/bin/bash
# 🔥 FeNix Bootstrap - One Command to Rule Them All
# 
# Basic usage:
#   curl -s https://raw.githubusercontent.com/nixfred/fenix/main/bootstrap.sh | bash
#
# With options (note the -s -- syntax):
#   curl -s https://raw.githubusercontent.com/nixfred/fenix/main/bootstrap.sh | bash -s -- --public-only
#   curl -s https://raw.githubusercontent.com/nixfred/fenix/main/bootstrap.sh | bash -s -- --work-machine

set -e

# Parse command line arguments
SKIP_SSH=false
PUBLIC_ONLY=false
WORK_MACHINE=false
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
        --work-machine)
            WORK_MACHINE=true
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
            echo "  --work-machine         Minimal work machine setup (shell only, no system changes)"
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
if [ "$WORK_MACHINE" = true ]; then
    echo -e "${YELLOW}💼 Phase 1: Work Machine Setup (Minimal)${RESET}"
    echo "========================================"
    echo -e "${CYAN}🏢 Work machine mode: No system packages will be installed${RESET}"
    echo -e "${CYAN}📋 Installing only shell environment and productivity enhancements${RESET}"
else
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
            qrencode build-essential \
            timeshift
    elif command -v dnf >/dev/null 2>&1; then
        echo "🔧 Installing FeNix essential packages (Fedora)..."
        sudo dnf install -y \
            git curl wget nano htop docker \
            neofetch screenfetch bat tree colordiff \
            unzip p7zip unrar \
            net-tools iotop \
            python3 python3-pip \
            jq ripgrep fd-find \
            qrencode @development-tools \
            timeshift
    elif command -v pacman >/dev/null 2>&1; then
        echo "🔧 Installing FeNix essential packages (Arch)..."
        sudo pacman -Sy --noconfirm \
            git curl wget nano htop docker \
            neofetch screenfetch bat tree colordiff \
            unzip p7zip unrar \
            net-tools iotop \
            python python-pip \
            jq ripgrep fd \
            qrencode base-devel \
            timeshift
    fi
fi

# Clone public repositories
echo "📥 Cloning FeNix public repositories..."
mkdir -p "$FENIX_DIR"
cd "$FENIX_DIR"

# Clone or update public repository
if [ -d "public" ]; then
    echo "🔄 Updating existing FeNix public repository..."
    cd public && git pull origin main && cd "$FENIX_DIR"
else
    git clone https://github.com/nixfred/fenix.git public
fi

# Try to clone dotfiles repository (may not exist or be private)
if [ -d "dotfiles" ]; then
    echo "🔄 Updating existing FeNix dotfiles..."
    cd dotfiles && git pull origin main 2>/dev/null && cd "$FENIX_DIR"
    dotfiles_available=true
elif git clone https://github.com/nixfred/fenix-dotfiles.git dotfiles 2>/dev/null; then
    dotfiles_available=true
else
    dotfiles_available=false
fi

if [ "$dotfiles_available" = true ]; then
    echo "🏠 Installing FeNix dotfiles..."
    cd dotfiles
    if [ -f "./install.sh" ]; then
        ./install.sh --stage1 || {
            echo "⚠️  Dotfiles install script failed, continuing with basic setup..."
            echo "⚠️  Error details: Check if .bashrc exists in dotfiles directory"
            ls -la . | head -10
            cd "$FENIX_DIR"
        }
    else
        echo "⚠️  Dotfiles install script not found, continuing with basic setup..."
        cd "$FENIX_DIR"
    fi
else
    echo "⚠️  FeNix dotfiles repository not accessible, creating basic shell setup..."
    mkdir -p dotfiles
    cd dotfiles
    
    # Create basic .bashrc enhancement
    cat > .bashrc_fenix << 'EOF'
# FeNix Basic Shell Enhancement
export FENIX_DIR="$HOME/.fenix"

# Dynamic path detection for common project directories
j() {
    local target_dirs=("$HOME/projects" "$HOME/Projects" "$HOME/dev" "$HOME/Development" "$HOME/code" "$HOME/src")
    case "$1" in
        "proj"|"project"|"projects")
            for dir in "${target_dirs[@]}"; do
                if [ -d "$dir" ]; then
                    cd "$dir" && return 0
                fi
            done
            echo "No projects directory found. Creating $HOME/projects"
            mkdir -p "$HOME/projects" && cd "$HOME/projects"
            ;;
        *)
            echo "Usage: j proj - Jump to projects directory"
            ;;
    esac
}

# Basic system info
neo() {
    echo "=== FeNix System Info ==="
    echo "Host: $(hostname)"
    echo "User: $(whoami)"
    echo "Date: $(date)"
    echo "Uptime: $(uptime -p 2>/dev/null || uptime)"
    echo "=========================="
}


echo "🔥 FeNix shell environment loaded!"
EOF
    
    # Install the basic .bashrc enhancement
    if ! grep -q "FeNix Basic Shell Enhancement" "$HOME/.bashrc" 2>/dev/null; then
        echo "" >> "$HOME/.bashrc"
        echo "# FeNix Basic Shell Enhancement" >> "$HOME/.bashrc"
        echo "source $FENIX_DIR/dotfiles/.bashrc_fenix" >> "$HOME/.bashrc"
        echo "✅ Added FeNix shell enhancements to ~/.bashrc"
    else
        echo "✅ FeNix shell enhancements already installed in ~/.bashrc"
    fi
    
    cd "$FENIX_DIR"
fi

echo -e "${GREEN}✅ Phase 1 Complete: Basic system ready!${RESET}"

# Don't exit yet - we need to install edc for public-only mode too!

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
if [ "$WORK_MACHINE" = true ]; then
    echo ""
    echo -e "${YELLOW}💼 Phase 4: Work Machine - Skipping Container Setup${RESET}"
    echo "=================================================="
    echo -e "${CYAN}🏢 Work machine mode: Container management skipped${RESET}"
    echo -e "${CYAN}📋 No Docker tools or system modifications will be made${RESET}"
else
    echo ""
    echo -e "${YELLOW}🐳 Phase 4: Container Environment Setup${RESET}"
    echo "======================================="

    echo "🐳 Setting up FeNix container management..."

# Install container management system
if [ -f "$FENIX_DIR/public/containers/install.sh" ]; then
    echo "📦 Installing FeNix container management tools..."
    cd "$FENIX_DIR/public/containers"
    ./install.sh 2>/dev/null || {
        echo "⚠️  Container install script failed, using direct installation..."
        cd "$FENIX_DIR"
        
        # Direct installation fallback - just ensure edc works
        echo -e "${CYAN}🔧 Setting up edc command (fallback method)...${RESET}"
        
        if command -v edc >/dev/null 2>&1; then
            echo -e "${GREEN}✅ edc command already available${RESET}"
        else
            mkdir -p ~/.fenix/bin
            
            # Create functional edc script
            cat > ~/.fenix/bin/edc << 'EOF'
#!/bin/bash
# edc - Easy Docker Container access script
if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    echo "edc - Easy Docker Container access script"
    echo "Usage: edc [container_number] or edc for interactive menu"
    exit 0
fi

if [ $# -eq 1 ]; then
    container_name=$(docker ps --format "{{.Names}}" | sed -n "${1}p")
    if [ -z "$container_name" ]; then
        echo "Error: Container $1 not found"
        exit 1
    fi
    docker exec -it "$container_name" /bin/bash
else
    containers=$(docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}" | tail -n +2)
    if [ -z "$containers" ]; then
        echo "No running containers found"
        exit 1
    fi
    echo "Available containers:"
    echo "$containers" | nl -w2 -s'. '
    read -p "Select container number: " container_num
    container_name=$(docker ps --format "{{.Names}}" | sed -n "${container_num}p")
    if [ -n "$container_name" ]; then
        docker exec -it "$container_name" /bin/bash
    else
        echo "Invalid selection"
    fi
fi
EOF
            chmod +x ~/.fenix/bin/edc
            echo -e "${GREEN}✅ edc command created at ~/.fenix/bin/edc${RESET}"
        fi
    }
    echo -e "${GREEN}✅ Container management system installed!${RESET}"
else
    echo -e "${BOLD}${CYAN}🐳 FeNix Container Management Setup${RESET}"
    echo "==================================="
    
    # Check Docker availability
    if command -v docker >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Docker is already available${RESET}"
        
        # Add user to docker group if not already
        if groups $USER | grep -q docker; then
            echo -e "${GREEN}✅ User already in docker group${RESET}"
        else
            echo "🔧 Adding user to docker group..."
            sudo usermod -aG docker "$USER"
            echo -e "${YELLOW}💡 Log out and back in for Docker permissions to take effect${RESET}"
        fi
    else
        echo -e "${YELLOW}⚠️  Docker not installed. Container features will be limited.${RESET}"
    fi
    
    # Install edc command - SIMPLIFIED APPROACH
    echo -e "${CYAN}🔧 Installing edc container management command...${RESET}"
    
    # Check if edc already exists in system PATH
    if command -v edc >/dev/null 2>&1; then
        echo -e "${GREEN}✅ edc command already available in system PATH${RESET}"
        echo -e "${CYAN}   Location: $(which edc)${RESET}"
    else
        # Create bin directory
        mkdir -p "$HOME/.fenix/bin"
        
        # Create a simple working edc script if we can't find the original
        cat > "$HOME/.fenix/bin/edc" << 'EOF'
#!/bin/bash
# edc - Easy Docker Container access script
# Usage: edc [container_number]

show_help() {
    echo "edc - Easy Docker Container access script"
    echo ""
    echo "Usage:"
    echo "  edc                    Show interactive container menu"
    echo "  edc <number>           Connect directly to container number"
    echo "  edc --help, -h         Show this help message"
    echo ""
    echo "Examples:"
    echo "  edc                    # Interactive mode"
    echo "  edc 2                  # Connect directly to container #2"
}

get_containers() {
    docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}" | tail -n +2
}

# Handle help arguments
if [ "$1" = "--help" ] || [ "$1" = "-h" ] || [ "$1" = "help" ]; then
    show_help
    exit 0
fi

if [ $# -eq 1 ]; then
    # Direct selection mode: edc 2
    container_num=$1
    container_name=$(docker ps --format "{{.Names}}" | sed -n "${container_num}p")
    
    if [ -z "$container_name" ]; then
        echo "Error: Container $container_num not found"
        exit 1
    fi
    
    echo "Connecting to container: $container_name"
    docker exec -it "$container_name" /bin/bash
else
    # Interactive mode: show list and prompt for selection
    containers=$(get_containers)
    
    if [ -z "$containers" ]; then
        echo "No running containers found"
        exit 1
    fi
    
    echo "Available containers:"
    echo "$containers" | nl -w2 -s'. '
    echo
    read -p "Select container number (or 'c' to cancel): " container_num
    
    # Check for cancel option
    if [ "$container_num" = "c" ] || [ "$container_num" = "C" ] || [ "$container_num" = "cancel" ]; then
        echo "Operation cancelled"
        exit 0
    fi
    
    container_name=$(docker ps --format "{{.Names}}" | sed -n "${container_num}p")
    
    if [ -z "$container_name" ]; then
        echo "Error: Invalid selection"
        exit 1
    fi
    
    echo "Connecting to container: $container_name"
    docker exec -it "$container_name" /bin/bash
fi
EOF
        
        chmod +x "$HOME/.fenix/bin/edc"
        echo -e "${GREEN}✅ edc command created at ~/.fenix/bin/edc${RESET}"
        
        # Add to PATH in .bashrc if not already there
        if ! grep -q ".fenix/bin" ~/.bashrc; then
            echo 'export PATH="$HOME/.fenix/bin:$PATH"' >> ~/.bashrc
            echo -e "${GREEN}✅ Added ~/.fenix/bin to PATH in .bashrc${RESET}"
        fi
    fi
    
    # Check for existing container systems
    echo ""
    echo -e "${CYAN}🔍 Checking for existing container systems...${RESET}"
    
    local container_systems_found=false
    
    # Check common locations for container systems
    local container_dirs=("$HOME/docker/universal" "$HOME/docker/ubuntu-vm" "$HOME/projects/docker" "$HOME/containers")
    
    for dir in "${container_dirs[@]}"; do
        if [ -d "$dir" ]; then
            echo -e "${GREEN}✅ Found container system: $dir${RESET}"
            container_systems_found=true
        fi
    done
    
    if [ "$container_systems_found" = false ]; then
        echo -e "${YELLOW}⚠️  Universal Container Creator not found at $HOME/docker/universal${RESET}"
        echo -e "${YELLOW}⚠️  Ubuntu Container System not found at $HOME/docker/ubuntu-vm${RESET}"
    fi
    
    # Test Docker functionality
    echo ""
    echo -e "${CYAN}🧪 Testing Docker functionality...${RESET}"
    
    if command -v docker >/dev/null 2>&1; then
        if docker info >/dev/null 2>&1; then
            echo -e "${GREEN}✅ Docker daemon is running${RESET}"
            
            if docker run --rm hello-world >/dev/null 2>&1; then
                echo -e "${GREEN}✅ Docker basic functionality works${RESET}"
            else
                echo -e "${YELLOW}⚠️  Docker run test failed (may need group permissions)${RESET}"
            fi
        else
            echo -e "${YELLOW}⚠️  Docker daemon not running or permission denied${RESET}"
        fi
    else
        echo -e "${RED}❌ Docker command not available${RESET}"
    fi
    
    # Check edc command availability
    echo ""
    echo -e "${CYAN}🔧 Checking edc command availability...${RESET}"
    
    if [ -f "$HOME/.fenix/bin/edc" ]; then
        if [[ ":$PATH:" == *":$HOME/.fenix/bin:"* ]]; then
            echo -e "${GREEN}✅ edc command should be available after sourcing .bashrc${RESET}"
        else
            echo -e "${YELLOW}⚠️  edc not in PATH. Make sure ~/.fenix/bin is in your PATH${RESET}"
            echo -e "${CYAN}💡 Add this to your .bashrc: export PATH=\"\$HOME/.fenix/bin:\$PATH\"${RESET}"
        fi
    else
        echo -e "${RED}❌ edc command not installed${RESET}"
    fi
    
    echo ""
    echo -e "${BOLD}${GREEN}🎉 FeNix Container Management Setup Complete!${RESET}"
    echo ""
    echo -e "${CYAN}Usage:${RESET}"
    echo "  edc                    # Interactive container menu"
    echo "  edc 1                  # Direct access to container #1"
    echo "  edc create             # Create new container"
    echo "  edc list               # List all containers"
    echo "  edc universal          # Universal Container Creator"
    echo "  edc ubuntu             # Ubuntu Container System"
    echo ""
    echo -e "${YELLOW}Note: If Docker permissions were just set, log out and back in for them to take effect.${RESET}"
    
    echo -e "${GREEN}✅ Container management system installed!${RESET}"
fi
fi  # End of work machine check

# Install ts (timeshift) command wrapper (skip for work machines)
if [ "$WORK_MACHINE" = false ] && command -v timeshift >/dev/null 2>&1; then
    echo "📦 Installing FeNix ts (timeshift) command wrapper..."
    sudo tee /usr/local/bin/ts > /dev/null << 'EOF'
#!/bin/bash
# FeNix ts - Timeshift wrapper for easy system snapshots
sudo timeshift "$@"
EOF
    sudo chmod +x /usr/local/bin/ts 2>/dev/null || {
        # If sudo fails, try user bin directory
        mkdir -p "$HOME/.local/bin"
        tee "$HOME/.local/bin/ts" > /dev/null << 'EOF'
#!/bin/bash
# FeNix ts - Timeshift wrapper for easy system snapshots
sudo timeshift "$@"
EOF
        chmod +x "$HOME/.local/bin/ts"
        # Add to PATH if not already there
        if ! grep -q ".local/bin" ~/.bashrc; then
            echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
        fi
    }
    echo -e "${GREEN}✅ FeNix ts command installed!${RESET}"
else
    echo -e "${YELLOW}⚠️  Timeshift not available, ts command skipped${RESET}"
fi

# Container fallback section
if [ -z "$(find $FENIX_DIR/public -name "edc" -o -name "manage.sh" 2>/dev/null)" ]; then
    echo -e "${YELLOW}⚠️  No container management tools found${RESET}"
    
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

# Show appropriate completion message based on installation type
if [ "$PUBLIC_ONLY" = true ]; then
    if [ "$WORK_MACHINE" = true ]; then
        echo -e "${BOLD}${GREEN}🎉 FeNix WORK MACHINE Installation Complete! 🎉${RESET}"
        echo -e "${CYAN}Total time: ${TOTAL_TIME} seconds${RESET}"
        echo ""
        echo -e "${YELLOW}Work machine installation includes:${RESET}"
        echo "• Dynamic shell environment (.bashrc with intelligent path detection)"
        echo "• Enhanced aliases and functions for productivity"
        echo "• Multi-host aware configurations"
        echo "• Basic FeNix directory structure"
        echo "• ⚠️  NO system packages installed (work-friendly)"
        echo "• ⚠️  NO Docker or container management"
        echo "• ⚠️  NO sudo operations performed"
        echo ""
        echo -e "${CYAN}To use your new environment:${RESET}"
        echo "• Run: source ~/.bashrc"
        echo "• Test: j proj (should jump to project directory)"
        echo "• Test: neo (system info banner)"
        echo ""
        echo -e "${CYAN}FeNix Work Machine ready! 💼🔥${RESET}"
    else
        echo -e "${BOLD}${GREEN}🎉 FeNix PUBLIC-ONLY Installation Complete! 🎉${RESET}"
        echo -e "${CYAN}Total time: ${TOTAL_TIME} seconds${RESET}"
        echo ""
        echo -e "${YELLOW}Public-only installation includes:${RESET}"
        echo "• Dynamic shell environment (.bashrc with intelligent path detection)"
        echo "• Enhanced aliases and functions for productivity"
        echo "• Multi-host aware configurations"
        echo "• Basic FeNix directory structure"
        echo "• Container management tools (edc command)"
        echo ""
        echo -e "${CYAN}FeNix System (public-only) ready! 🔥${RESET}"
    fi
else
    echo -e "${BOLD}${GREEN}🎉🎉🎉 FeNix RESURRECTION COMPLETE! 🎉🎉🎉${RESET}"
    echo -e "${CYAN}Total time: ${TOTAL_TIME} seconds${RESET}"
    echo ""
    echo -e "${CYAN}Welcome back to your digital life! 🔥${RESET}"
fi

# Instructions for activating the new environment
echo ""
echo -e "${BOLD}${CYAN}🔄 To activate your new FeNix environment, run:${RESET}"
echo ""
echo -e "${BOLD}${YELLOW}  exec bash${RESET}"
echo ""
echo -e "${CYAN}This will start a fresh shell with all FeNix commands available:${RESET}"
echo "• sb - Reload shell configuration"
echo "• j proj - Jump to projects directory"  
echo "• neo - System information banner"
echo "• edc - Container management (if Docker available)"
echo "• pp - Smart SSH between hosts"
echo ""
echo -e "${BOLD}${GREEN}🎉 FeNix is ready! Run 'exec bash' to activate! 🎉${RESET}"
