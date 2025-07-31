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

# Install edc command - ALWAYS UPDATE TO LATEST VERSION
echo -e "${CYAN}🔧 Installing/updating edc command to /usr/local/bin/edc...${RESET}"

# Always create/update edc with latest version regardless of existing installation
# Create a fully functional edc script
sudo tee /usr/local/bin/edc > /dev/null << 'EOF'
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
    echo "Enter container number or 'c' to cancel"
    read -p "Select container number: " container_num
    
    # Check for cancel option FIRST
    case "$container_num" in
        "c"|"C"|"cancel"|"quit"|"q"|"Q")
            echo "Operation cancelled"
            exit 0
            ;;
        "")
            echo "No selection made"
            exit 0
            ;;
        *[!0-9]*)
            echo "Error: Please enter a number or 'c' to cancel"
            exit 1
            ;;
    esac
    
    container_name=$(docker ps --format "{{.Names}}" | sed -n "${container_num}p")
    
    if [ -z "$container_name" ]; then
        echo "Error: Container $container_num not found"
        exit 1
    fi
    
    echo "Connecting to container: $container_name"
    docker exec -it "$container_name" /bin/bash
fi
EOF

sudo chmod +x /usr/local/bin/edc
echo -e "${GREEN}✅ edc command installed/updated at /usr/local/bin/edc${RESET}"

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