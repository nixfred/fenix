#!/bin/bash
# 🔑 FeNix SSH Key Backup System
# Securely backs up SSH keys with encryption

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RESET='\033[0m'

SSH_DIR="$HOME/.ssh"
BACKUP_DIR="$HOME/fenix/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

echo -e "${CYAN}🔑 FeNix SSH Key Backup System${RESET}"
echo "======================================"

# Create backup directory
mkdir -p "$BACKUP_DIR"

backup_ssh_keys() {
    echo -e "${YELLOW}📦 Creating SSH key backup...${RESET}"
    
    if [ ! -d "$SSH_DIR" ]; then
        echo -e "${RED}❌ SSH directory not found: $SSH_DIR${RESET}"
        return 1
    fi
    
    # Create temporary directory for backup
    local temp_dir=$(mktemp -d)
    local backup_name="ssh-keys-$TIMESTAMP"
    local backup_path="$temp_dir/$backup_name"
    
    mkdir -p "$backup_path"
    
    # Copy SSH files (excluding known_hosts which changes frequently)
    for file in id_rsa id_rsa.pub id_ed25519 id_ed25519.pub config authorized_keys; do
        if [ -f "$SSH_DIR/$file" ]; then
            cp "$SSH_DIR/$file" "$backup_path/"
            echo "  ✅ Backed up: $file"
        fi
    done
    
    # Create archive
    cd "$temp_dir"
    tar -czf "$backup_name.tar.gz" "$backup_name"
    
    # Encrypt with GPG (you'll need to set up GPG key)
    if command -v gpg >/dev/null 2>&1; then
        echo -e "${YELLOW}🔐 Encrypting backup...${RESET}"
        gpg --symmetric --cipher-algo AES256 --compress-algo 1 --s2k-mode 3 \
            --s2k-digest-algo SHA512 --s2k-count 65536 \
            --output "$BACKUP_DIR/ssh-keys-$TIMESTAMP.tar.gz.gpg" \
            "$backup_name.tar.gz"
        
        # Secure delete original
        shred -vfz -n 3 "$backup_name.tar.gz"
        echo -e "${GREEN}✅ Encrypted backup created: $BACKUP_DIR/ssh-keys-$TIMESTAMP.tar.gz.gpg${RESET}"
    else
        # Fallback: just move the archive (less secure)
        mv "$backup_name.tar.gz" "$BACKUP_DIR/ssh-keys-$TIMESTAMP.tar.gz"
        echo -e "${YELLOW}⚠️  GPG not found - backup not encrypted!${RESET}"
        echo -e "${GREEN}✅ Backup created: $BACKUP_DIR/ssh-keys-$TIMESTAMP.tar.gz${RESET}"
    fi
    
    # Cleanup
    rm -rf "$temp_dir"
}

restore_ssh_keys() {
    echo -e "${YELLOW}📥 SSH Key Restoration${RESET}"
    
    # List available backups
    local backups=($(ls "$BACKUP_DIR"/ssh-keys-*.tar.gz* 2>/dev/null | sort -r))
    
    if [ ${#backups[@]} -eq 0 ]; then
        echo -e "${RED}❌ No SSH key backups found in $BACKUP_DIR${RESET}"
        return 1
    fi
    
    echo "Available backups:"
    for i in "${!backups[@]}"; do
        echo "  $((i+1)). $(basename "${backups[$i]}")"
    done
    
    read -p "Select backup to restore [1-${#backups[@]}]: " selection
    
    if [[ "$selection" -ge 1 && "$selection" -le ${#backups[@]} ]]; then
        local selected_backup="${backups[$((selection-1))]}"
        echo -e "${CYAN}Restoring from: $(basename "$selected_backup")${RESET}"
        
        # Create temporary directory for restoration
        local temp_dir=$(mktemp -d)
        
        # Decrypt if encrypted
        if [[ "$selected_backup" == *.gpg ]]; then
            echo -e "${YELLOW}🔐 Decrypting backup...${RESET}"
            gpg --decrypt "$selected_backup" > "$temp_dir/backup.tar.gz"
        else
            cp "$selected_backup" "$temp_dir/backup.tar.gz"
        fi
        
        # Extract and restore
        cd "$temp_dir"
        tar -xzf backup.tar.gz
        
        # Backup existing SSH directory
        if [ -d "$SSH_DIR" ]; then
            echo -e "${YELLOW}📁 Backing up existing SSH directory...${RESET}"
            mv "$SSH_DIR" "$SSH_DIR.backup.$TIMESTAMP"
        fi
        
        # Restore SSH keys
        mkdir -p "$SSH_DIR"
        cp -r ssh-keys-*/. "$SSH_DIR/"
        chmod 700 "$SSH_DIR"
        chmod 600 "$SSH_DIR"/id_* 2>/dev/null || true
        chmod 644 "$SSH_DIR"/*.pub 2>/dev/null || true
        
        # Cleanup
        rm -rf "$temp_dir"
        
        echo -e "${GREEN}✅ SSH keys restored successfully!${RESET}"
        echo -e "${CYAN}📁 Original SSH directory backed up to: $SSH_DIR.backup.$TIMESTAMP${RESET}"
    else
        echo -e "${RED}❌ Invalid selection${RESET}"
        return 1
    fi
}

sync_ssh_to_remote() {
    local remote_host="$1"
    if [ -z "$remote_host" ]; then
        # Auto-detect remote host based on current host
        case $(hostname) in
            "pi5") remote_host="ron" ;;
            "ron") remote_host="pi5" ;;
            *) echo -e "${RED}❌ Please specify remote host${RESET}"; return 1 ;;
        esac
    fi
    
    echo -e "${CYAN}🔄 Syncing SSH keys to $remote_host...${RESET}"
    
    # Create backup first
    backup_ssh_keys
    
    # Copy public key to remote host
    if [ -f "$SSH_DIR/id_rsa.pub" ]; then
        ssh-copy-id -i "$SSH_DIR/id_rsa.pub" "$remote_host" 2>/dev/null || true
        echo -e "${GREEN}✅ Public key copied to $remote_host${RESET}"
    fi
    
    # Sync backup to remote host
    scp "$BACKUP_DIR"/ssh-keys-*.tar.gz* "$remote_host:~/fenix/backups/" 2>/dev/null || true
    echo -e "${GREEN}✅ SSH key backup synced to $remote_host${RESET}"
}

# Main menu
case "${1:-menu}" in
    "backup")
        backup_ssh_keys
        ;;
    "restore")
        restore_ssh_keys
        ;;
    "sync")
        sync_ssh_to_remote "$2"
        ;;
    "menu"|*)
        echo "Usage: $0 {backup|restore|sync [host]}"
        echo ""
        echo "Commands:"
        echo "  backup  - Create encrypted backup of SSH keys"
        echo "  restore - Restore SSH keys from backup"
        echo "  sync    - Sync SSH keys to remote host (pi5 ↔ ron)"
        echo ""
        echo "Examples:"
        echo "  $0 backup"
        echo "  $0 restore"
        echo "  $0 sync ron"
        ;;
esac