#!/bin/bash
# 🔥 FeNix Container Management Installation
# Integrates existing container systems with FeNix

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RESET='\033[0m'

echo -e "${CYAN}🐳 FeNix Container Management Setup${RESET}"
echo "==================================="

# Check if Docker is available
if ! command -v docker >/dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  Docker not found. Installing Docker...${RESET}"
    
    # Install Docker based on the distribution
    if command -v apt >/dev/null 2>&1; then
        sudo apt update
        sudo apt install -y docker.io docker-compose
    elif command -v dnf >/dev/null 2>&1; then
        sudo dnf install -y docker docker-compose
    elif command -v pacman >/dev/null 2>&1; then
        sudo pacman -S --noconfirm docker docker-compose
    else
        echo -e "${RED}❌ Unsupported package manager. Please install Docker manually.${RESET}"
        exit 1
    fi
    
    # Start and enable Docker service
    sudo systemctl start docker
    sudo systemctl enable docker
    
    echo -e "${GREEN}✅ Docker installed and started${RESET}"
else
    echo -e "${GREEN}✅ Docker is already available${RESET}"
fi

# Add current user to docker group
if ! groups "$USER" | grep -q docker; then
    echo -e "${CYAN}🔐 Adding user to docker group...${RESET}"
    sudo usermod -aG docker "$USER"
    echo -e "${YELLOW}⚠️  You'll need to log out and back in for Docker permissions to take effect${RESET}"
else
    echo -e "${GREEN}✅ User already in docker group${RESET}"
fi

# Create FeNix bin directory if it doesn't exist
FENIX_BIN="$HOME/.fenix/bin"
mkdir -p "$FENIX_BIN"

# Install edc command to FeNix bin
ETC_SOURCE="/home/pi/fenix/edc"
if [ -f "$ETC_SOURCE" ]; then
    cp "$ETC_SOURCE" "$FENIX_BIN/edc"
    chmod +x "$FENIX_BIN/edc"
    echo -e "${GREEN}✅ edc command installed to $FENIX_BIN${RESET}"
else
    echo -e "${RED}❌ edc source file not found: $ETC_SOURCE${RESET}"
fi

# Check for existing container systems
echo ""
echo -e "${CYAN}🔍 Checking for existing container systems...${RESET}"

UNIVERSAL_SYSTEM="/home/pi/docker/universal"
UBUNTU_VM_SYSTEM="/home/pi/docker/ubuntu-vm"

if [ -d "$UNIVERSAL_SYSTEM" ]; then
    echo -e "${GREEN}✅ Universal Container Creator found${RESET}"
    # Make sure scripts are executable
    chmod +x "$UNIVERSAL_SYSTEM"/*.sh 2>/dev/null || true
else
    echo -e "${YELLOW}⚠️  Universal Container Creator not found at $UNIVERSAL_SYSTEM${RESET}"
fi

if [ -d "$UBUNTU_VM_SYSTEM" ]; then
    echo -e "${GREEN}✅ Ubuntu Container System found${RESET}"
    # Make sure scripts are executable
    chmod +x "$UBUNTU_VM_SYSTEM"/*.sh 2>/dev/null || true
else
    echo -e "${YELLOW}⚠️  Ubuntu Container System not found at $UBUNTU_VM_SYSTEM${RESET}"
fi

# Test Docker functionality
echo ""
echo -e "${CYAN}🧪 Testing Docker functionality...${RESET}"

if docker info >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Docker daemon is running${RESET}"
    
    # Test basic Docker operation
    if docker run --rm hello-world >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Docker basic functionality works${RESET}"
    else
        echo -e "${YELLOW}⚠️  Docker basic test failed (may need group permissions)${RESET}"
    fi
else
    echo -e "${YELLOW}⚠️  Docker daemon not accessible (may need group permissions)${RESET}"
fi

# Check if edc is accessible from PATH
echo ""
echo -e "${CYAN}🔧 Checking edc command availability...${RESET}"

if command -v edc >/dev/null 2>&1; then
    echo -e "${GREEN}✅ edc command is available in PATH${RESET}"
else
    echo -e "${YELLOW}⚠️  edc not in PATH. Make sure ~/.fenix/bin is in your PATH${RESET}"
    echo -e "${CYAN}💡 Add this to your .bashrc: export PATH=\"\$HOME/.fenix/bin:\$PATH\"${RESET}"
fi

echo ""
echo -e "${GREEN}🎉 FeNix Container Management Setup Complete!${RESET}"
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