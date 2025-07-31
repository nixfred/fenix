# 🚀 FeNix Installation Guide

**Quick Start: Get FeNix running in under 10 minutes**

---

## ⚡ One-Command Installation

```bash
curl -s https://raw.githubusercontent.com/nixfred/fenix/main/bootstrap.sh | bash
```

**That's it!** The bootstrap will guide you through everything else.

---

## 🎯 Pre-Installation Checklist

### Required
- ✅ **Linux system** (Ubuntu, Debian, Fedora, Arch, Alpine, CentOS)
- ✅ **Internet connection** for downloading packages and repositories
- ✅ **sudo access** for system configuration (hostname changes, package installation)

### Recommended  
- ✅ **GitHub account** for storing your configurations
- ✅ **SSH keys** (or FeNix can generate them for you)
- ✅ **Docker installed** (or FeNix can install it)

### Architecture Support
- ✅ **ARM64** (Raspberry Pi, Apple Silicon)
- ✅ **x86_64** (Intel/AMD laptops, servers)

---

## 🎪 Installation Process

### Step 1: Run Bootstrap
```bash
curl -s https://raw.githubusercontent.com/nixfred/fenix/main/bootstrap.sh | bash
```

### Step 2: Choose Machine Type
### Note to Claude Code pls make 1 the remote machine and 2 being move ron....
The installer will ask:
```
🤖 Machine Identity Detection
================================
Current hostname: your-machine

Machine Types:
1) Main Workstation (ron replacement) - Full digital life transfer
2) Remote Environment (pi5-style) - Synchronized work environment  
3) Auto-detect from hostname

What type of machine is this? [1-3]:
```

**Choose based on your needs:**

#### **Option 1: Main Workstation**
- This becomes your primary machine (hostname changes to "ron")
- Gets complete configuration with management aliases
- Other machines will connect TO this one
- **Use when:** Setting up your primary work machine

#### **Option 2: Remote Environment**  
- Keeps current hostname (laptop, pi5, work-desktop, etc.)
- Gets synchronized environment that connects back to main
- Lightweight setup focused on remote work
- **Use when:** Adding a satellite machine for remote work

#### **Option 3: Auto-detect**
- If hostname is "ron" → Configures as main workstation
- Any other hostname → Configures as remote environment

### Step 3: SSH Key Configuration
The installer will present options:
```
🔑 SSH Key Setup
================
Choose SSH key setup method:
1) I have existing SSH keys (paste them)
2) Generate new SSH keys
3) Import from GitHub (requires username)
4) Skip for now (manual setup later)

Enter choice [1-4]:
```

#### **Option 1: Existing Keys (Recommended)**
- Paste your existing private key when prompted
- Paste your existing public key when prompted
- FeNix installs them with correct permissions

#### **Option 2: Generate New Keys**
- FeNix creates new SSH key pair
- Displays public key for you to add to GitHub/GitLab
- Private key automatically stored in private repository

#### **Option 3: GitHub Import**
- Imports public key from your GitHub profile
- You'll need to provide private key manually later

#### **Option 4: Skip**
- Continue without SSH keys
- Run `fenix setup-ssh` later to configure

### Step 4: Repository Access
If SSH keys are working, FeNix will:
- Clone your private configurations from `fenix-private` repository
- Install machine-specific dotfiles and configurations
- Set up container environments
- Configure multi-host access

### Step 5: Finalization
- System health check
- Performance timing report
- Instructions for first use

---

## 🔧 What Gets Installed

### Phase 1: Public System Setup (2-3 minutes)
```bash
✅ Essential tools (git, curl, wget, nano, htop)
✅ Docker (if not already installed)
✅ FeNix public configurations
✅ Dynamic shell environment with portable aliases
```

### Phase 2: SSH Key Setup (1-2 minutes)
```bash
✅ SSH key installation or generation
✅ GitHub/GitLab connectivity testing
✅ Proper file permissions (600/644)
✅ SSH config for multi-host access
```

### Phase 3: Private Configuration (2-3 minutes)
```bash
✅ Private repository cloning (fenix-private)
✅ Machine-specific dotfiles installation
✅ SSH keys distribution to ~/.ssh/
✅ Container environment setup
✅ Multi-host synchronization configuration
```

### Phase 4: Container Environment (1-2 minutes)
```bash
✅ Docker group membership
✅ Container management tools (edc command)
✅ Multi-host container orchestration
✅ Development environment templates
```

---

## 🎛️ Installation Options

### Environment Variables
You can customize the installation with environment variables:

```bash
# Custom installation directory
FENIX_DIR="$HOME/.my-fenix" curl -s https://raw.githubusercontent.com/nixfred/fenix/main/bootstrap.sh | bash

# Skip interactive prompts (use defaults)
FENIX_QUIET=true curl -s https://raw.githubusercontent.com/nixfred/fenix/main/bootstrap.sh | bash

# Force machine type
FENIX_MACHINE_TYPE="main" curl -s https://raw.githubusercontent.com/nixfred/fenix/main/bootstrap.sh | bash
FENIX_MACHINE_TYPE="remote" curl -s https://raw.githubusercontent.com/nixfred/fenix/main/bootstrap.sh | bash
```

### Command Line Arguments
```bash
# Main workstation installation
curl -s https://raw.githubusercontent.com/nixfred/fenix/main/bootstrap.sh | bash -s -- --main-workstation

# Remote environment installation  
curl -s https://raw.githubusercontent.com/nixfred/fenix/main/bootstrap.sh | bash -s -- --remote-environment

# Skip SSH key setup
curl -s https://raw.githubusercontent.com/nixfred/fenix/main/bootstrap.sh | bash -s -- --skip-ssh
```

---

## 🧪 Test Installation (Recommended)

### Before Installing on Your Main Machine

# This is a message to Claude Code --- shouldnt the test script look more like this:  docker run --rm -it --name fenix-test ubuntu:22.04 /bin/bash -c "set -e; apt update && apt install -y curl git sudo && curl -s https://raw.githubusercontent.com/nixfred/fenix/main/bootstrap.sh | bash -s -- --public-only"

Test FeNix on a disposable container first:

```bash
# Start test container
docker run -it --name fenix-test ubuntu:22.04 /bin/bash

# Inside container, run FeNix installation
curl -s https://raw.githubusercontent.com/nixfred/fenix/main/bootstrap.sh | bash

# Test the installation
j proj          # Should jump to projects directory
edc             # Should show container menu
source ~/.bashrc && echo "FeNix loaded successfully"

# Exit and remove test container
exit
docker rm fenix-test
```

---

## 🚨 Installation Troubleshooting

### Common Issues

#### **"curl: command not found"**
```bash
# Install curl first
sudo apt update && sudo apt install curl    # Ubuntu/Debian
sudo dnf install curl                       # Fedora
sudo pacman -S curl                         # Arch
```

#### **"Permission denied" during installation**
```bash
# Make sure you have sudo access
sudo whoami    # Should show "root"

# If sudo isn't configured, run as root (not recommended)
su -
curl -s https://raw.githubusercontent.com/nixfred/fenix/main/bootstrap.sh | bash
```

#### **Bootstrap script fails to download**
```bash
# Check internet connectivity
ping google.com

# Try manual download
wget https://raw.githubusercontent.com/nixfred/fenix/main/bootstrap.sh
chmod +x bootstrap.sh
./bootstrap.sh
```

#### **GitHub SSH connection fails**
```bash
# Test GitHub connection
ssh -T git@github.com

# If fails, check SSH key installation
ls -la ~/.ssh/id_rsa     # Should exist with 600 permissions
cat ~/.ssh/id_rsa.pub    # Should show your public key

# Add public key to GitHub if missing
cat ~/.ssh/id_rsa.pub
# Copy output and add to: https://github.com/settings/keys
```

#### **Repository cloning fails**
```bash
# Check if repositories exist and are accessible
git clone https://github.com/nixfred/fenix.git /tmp/test-public
git clone git@github.com:nixfred/fenix-private.git /tmp/test-private

# If private repo fails
echo "Private repository might not exist yet or SSH keys not configured"
echo "Run: fenix setup-private-repo"
```

### Installation Logs
```bash
# Check installation logs
tail -f ~/.fenix/install.log

# System logs for troubleshooting
sudo journalctl -f -u docker    # Docker issues
tail -f /var/log/auth.log        # SSH issues
```

---

## ✅ Post-Installation Verification

### Test Core Functionality
```bash
# Reload shell environment
source ~/.bashrc

# Test dynamic path detection
j proj && pwd                    # Should jump to projects directory
which edc                        # Should find edc command

# Test SSH functionality
ssh -T git@github.com           # Should authenticate successfully
pp                              # Should connect to appropriate host (if configured)

# Test container access (if Docker installed)
edc                             # Should show interactive container menu
docker ps                       # Should show running containers
```

### Test Machine-Specific Features

#### **Main Workstation (ron) Features**
```bash
# Should have management aliases
checkremotes                    # Check status of remote machines
deployeverywhere               # Deploy containers to all hosts
synctoremotes                  # Sync projects to remote machines

# Hostname should be ron (after reboot)
hostname                       # Should show "ron"
```

#### **Remote Environment Features**
```bash
# Should have connection aliases  
gohome                         # Should SSH to ron
syncfromhome                   # Should pull from main workstation
homecheck                      # Should check main workstation status

# Hostname should be preserved
hostname                       # Should show original name (pi5, laptop, etc.)
```

### Performance Verification
```bash
# Check installation time (should be <10 minutes)
cat ~/.fenix/install-time.log

# System health check
neo                            # Should show system information banner
fenix status                   # Should show multi-host status
```

---

## 🔄 Reinstallation / Updates

### Clean Reinstallation
```bash
# Remove existing FeNix installation
rm -rf ~/.fenix
rm -f ~/.bashrc_fenix

# Run fresh installation
curl -s https://raw.githubusercontent.com/nixfred/fenix/main/bootstrap.sh | bash
```

### Update Existing Installation
```bash
# Update FeNix system components
cd ~/.fenix/public && git pull origin main

# Update your configurations  
cd ~/.fenix/dotfiles && git pull origin main
cd ~/.fenix/private && git pull origin main

# Reinstall if major changes
curl -s https://raw.githubusercontent.com/nixfred/fenix/main/bootstrap.sh | bash
```

---

## 🎯 Installation Best Practices

### Security
- ✅ **Test first:** Use containers to test before installing on main machine
- ✅ **Backup existing:** Create backups of existing dotfiles before installation
- ✅ **Review scripts:** Check bootstrap.sh contents before running (security-conscious users)
- ✅ **Private repos:** Keep sensitive configurations in private repositories only

### Multi-Machine Deployment
- ✅ **Start with main:** Install on primary workstation (ron) first
- ✅ **Add remotes:** Install on satellite machines as remote environments
- ✅ **Test connectivity:** Ensure SSH connections work between all machines
- ✅ **Document setup:** Keep notes on which machines have which roles

### Maintenance
- ✅ **Regular updates:** Pull latest configurations weekly
- ✅ **Key rotation:** Update SSH keys annually via FeNix
- ✅ **Health checks:** Run `fenix status` regularly
- ✅ **Backups:** Create system snapshots before major changes

---

## 📞 Installation Support

### Getting Help
- 📚 **Complete Documentation:** [README.md](README.md) - Full runbook
- 🐛 **Report Issues:** [GitHub Issues](https://github.com/nixfred/fenix/issues)  
- 💬 **AI Assistant:** Ask Claude about FeNix (reads CLAUDE.md automatically)

### Self-Diagnosis
```bash
# Installation health check
fenix doctor                   # Comprehensive system check

# Component verification
which edc && echo "edc: OK"
j proj && echo "path detection: OK"  
ssh -T git@github.com && echo "GitHub: OK"
```

### Emergency Recovery
```bash
# If installation breaks your shell
bash --login                   # Start clean shell
export PATH="/usr/bin:/bin"    # Reset basic PATH

# Restore original dotfiles
cp ~/.bashrc.backup.* ~/.bashrc   # Restore from automatic backup
source ~/.bashrc

# Uninstall FeNix completely
rm -rf ~/.fenix ~/.bashrc_fenix
# Then restore from backup or reinstall system dotfiles
```

---

## 🎉 Welcome to FeNix!

After successful installation, your system will have:

✅ **Dynamic shell environment** that adapts to any system  
✅ **Seamless SSH connectivity** between all your machines  
✅ **Container orchestration** with simple management commands  
✅ **Multi-host synchronization** for projects and configurations  
✅ **System health monitoring** with detailed status information  
✅ **One-command resurrection** capability for disaster recovery  

**Your entire digital life is now Infrastructure-as-Code!**

---

**Next Steps:**
1. 📖 Read the [Complete Runbook](README.md) for advanced usage
2. 🧪 Test container deployment with `edc`
3. 🔄 Set up additional machines as remote environments
4. 🛠️ Customize your configuration in the private repository

**🔥 Rise from the ashes, stronger than before! 🔥**
