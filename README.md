# 📚 FeNix Phoenix System - Complete Runbook

**Digital Life as Code (DLaC)** - Rise from the ashes in under 10 minutes

[![FeNix System](https://img.shields.io/badge/FeNix-Digital%20Life%20as%20Code-orange?style=for-the-badge&logo=phoenix-framework)](https://github.com/nixfred/fenix)
[![License](https://img.shields.io/badge/License-MIT-blue?style=for-the-badge)](LICENSE)
[![Bootstrap](https://img.shields.io/badge/Bootstrap-One%20Command-green?style=for-the-badge)](bootstrap.sh)

> *"If my machine dies, I'm back to 100% productivity in under 10 minutes"*

**THIS IS YOUR COMPLETE RUNBOOK** - Everything you need to deploy, manage, and maintain the FeNix system. No external docs needed!

## 🎯 What is FeNix?

FeNix is your complete digital life as code. It's a Git-based Infrastructure-as-Code solution that can resurrect your entire development environment on any Linux machine in under 10 minutes. Unlike simple dotfile managers, FeNix manages your complete digital workspace including shell configurations, container environments, SSH keys, and multi-host synchronization.

**Core Promise:** *"If my machine dies, I'm back to 100% productivity in under 10 minutes"*

### Key Features
- 🏠 **Dynamic Shell Environment** - Portable configs that adapt to any system
- 🐳 **Container Orchestration** - Full Docker development environments  
- 🔄 **Multi-Host Synchronization** - Seamless sync between multiple machines
- 🛡️ **Security Monitoring** - SSH intrusion detection, system health tracking
- 🧪 **Chaos-Tested** - Validated across 6 Linux distributions, 2 architectures
- ⚡ **Lightning Fast** - Complete environment restoration in <10 minutes

## 🚀 Quick Start

### 💥 One Command to Rule Them All
```bash
curl -s https://raw.githubusercontent.com/nixfred/fenix/main/bootstrap.sh | bash
```

### 🎭 Two FeNix Modes

#### 🌐 **Multi-Machine Mode** (Default)
*Add FeNix environment to multiple machines, each keeps its identity*

```bash
# On your laptop:
curl -s https://nixfred.dev/fenix | bash

# On your server:  
curl -s https://nixfred.dev/fenix | bash

# Result: Same environment, different identities
laptop$ hostname  # → laptop
server$ hostname  # → server
both$ j proj      # → jumps to projects (works everywhere!)
```

#### 🚚 **Migration Mode**
*Replace a machine completely - transfer your digital identity*

```bash
# Migration from old-pi5 to new-pi5:
curl -s https://nixfred.dev/fenix | bash --migrate-from old-pi5

# Result: New machine becomes identical to old machine
new-pi5$ hostname    # → pi5 (same as old machine)
new-pi5$ ssh ron     # → works (same SSH keys)
new-pi5$ docker ps   # → same containers restored
```

## 🏗️ Architecture

### 🎪 The FeNix Ecosystem
```
FeNix Repositories:
├── fenix/              # 🌍 Master system (this repo)
├── fenix-dotfiles/     # 🌍 Public shell configs  
└── fenix-private/      # 🔐 SSH keys & secrets

Local Structure:
~/.fenix/
├── public/             # Public configurations
├── private/            # Private configurations  
├── backups/            # System backups
└── containers/         # Docker environments
```

### 🔥 Core Features

#### **Dynamic Path Detection**
No more hardcoded paths! FeNix automatically discovers:
- Tool locations (`edc`, utilities) across `/usr/local/bin`, `~/bin`, `~/.local/bin`
- Project directories (adapts to `~/projects`, `~/Projects`, `~/workspace`, `~/docker`)
- Container configurations (handles moves and renames gracefully)

#### **Multi-Host Orchestration**  
- **Auto-Discovery**: Detects pi5 ↔ ron hosts and configures sync
- **Bidirectional Sync**: Real-time file synchronization between machines
- **Container Deployment**: Orchestrates Docker environments across hosts
- **SSH Tunneling**: Smart SSH connections (`pp` command auto-routes)

#### **Infrastructure Monitoring**
Built-in system health dashboard:
```
****************************************************
*  Host:        pi5                                *
*  Docker:      3 running / 8 total               *
*  Timeshift:   12 snapshots, 45GB free          *
*  Git Branch:  fenix-dev                         *
*  SSH Fails:   None                              *
****************************************************
```

#### **Phoenix Testing Labs**
Revolutionary validation approach:
- **Multi-Distro**: Ubuntu, Debian, Fedora, Arch, Alpine, CentOS
- **Cross-Architecture**: ARM64 (Raspberry Pi) + x86_64 (laptops/servers)
- **Chaos Engineering**: Network failures, disk full, broken dependencies
- **Performance Benchmarks**: Target <10 minutes full deployment

## 🎯 Use Cases

### 🏠 **Home Lab Management**
Perfect for Raspberry Pi clusters and multi-host development:
```bash
# Deploy same environment to entire cluster:
for host in pi5 ron pi-cluster-1 pi-cluster-2; do
    ssh $host "curl -s https://nixfred.dev/fenix | bash"
done
```

### 👥 **Development Teams**
Consistent environments across all developers:
```bash
# Team onboarding - one command:
curl -s https://company.com/fenix-team-config | bash
```

### 🚨 **Disaster Recovery**
Business continuity for development workflows:
```bash
# Machine dies at 2 AM:
curl -s https://nixfred.dev/fenix | bash --migrate-from backup-config

# Back to productivity in 8 minutes
```

### 🎓 **Education & Research**
Reproducible computational environments:
```bash
# Students get identical research environment:
curl -s https://university.edu/research-fenix | bash
```

## 📊 Comparison

| Feature | FeNix | Thoughtbot Laptop | Mathias Dotfiles | Holman Dotfiles |
|---------|-------|-------------------|------------------|-----------------|
| **Multi-Host Sync** | ✅ | ❌ | ❌ | ❌ |
| **Container Orchestration** | ✅ | ❌ | ❌ | ❌ |
| **Cross-Architecture** | ✅ | ❌ | ❌ | ❌ |
| **Migration Mode** | ✅ | ❌ | ❌ | ❌ |
| **Chaos Testing** | ✅ | ❌ | ❌ | ❌ |
| **Dynamic Detection** | ✅ | ❌ | ❌ | ❌ |
| **Health Monitoring** | ✅ | ❌ | ❌ | ❌ |
| **Deployment Time** | <10 min | ~30 min | ~20 min | ~15 min |

## 🛠️ Advanced Usage

### 🔧 **Daily Commands**
```bash
# Environment management
sb                      # Reload shell configuration
j proj                  # Jump to projects (auto-detected)
pp                      # Smart SSH (pi5 ↔ ron, others → pi5)

# Container operations
edc                     # Interactive container menu
edc 2                   # Direct access to container #2

# Sync operations
fenix sync              # Sync changes across hosts
fenix backup            # Create system backup
fenix status            # System health check
```

### 🧪 **Testing New Configurations**
```bash
# Test FeNix on pristine container:
docker run -it ubuntu:22.04 /bin/bash
curl -s https://raw.githubusercontent.com/nixfred/fenix/main/bootstrap.sh | bash

# Chaos engineering:
./testing/chaos-engineering.sh --scenario network_failure
```

### 🔐 **Security Features**
- **SSH Key Management**: Secure backup and restoration of SSH keys
- **Multi-Factor Backup**: Git repos + Timeshift + encrypted archives
- **Intrusion Detection**: SSH failure monitoring and alerting
- **Container Isolation**: Development environments in isolated containers

## 🗺️ Roadmap

### 🎯 **Phase 1: Core System** (Current)
- ✅ Dynamic shell environment with path detection
- ✅ Multi-host synchronization (pi5 ↔ ron)
- ✅ Container orchestration and management
- ✅ Phoenix Testing Labs validation

### 🚀 **Phase 2: Intelligence** (Next)
- 🔄 Machine learning for usage pattern optimization  
- 🔄 Auto-configuration based on detected hardware/OS
- 🔄 Predictive resource management
- 🔄 Smart conflict resolution for multi-host sync

### 🌟 **Phase 3: Social & Cloud** (Future)
- 📅 Anonymous configuration sharing and community templates
- 📅 Multi-cloud backup strategies (AWS, GCP, Azure)
- 📅 Mobile integration (QR code sharing, mobile dashboards)
- 📅 Team collaboration features

### 🔬 **Phase 4: Next-Gen** (Research)
- 🔬 Quantum-safe cryptography for future-proof security
- 🔬 Edge computing and IoT device management integration  
- 🔬 Immutable infrastructure with NixOS-style declarations
- 🔬 AI-powered environment optimization and troubleshooting

## 🤝 Contributing

### 🎯 **Architecture Principles**
- **Simplicity**: One command should do everything
- **Reliability**: Must work 99.9% of the time  
- **Portability**: Any Linux, any architecture
- **Speed**: <10 minutes for complete restoration
- **Security**: Defense in depth, no secret leakage

### 🧪 **Development Workflow**
1. **Test First**: Use Phoenix Testing Labs before deploying
2. **Document Changes**: Update CLAUDE.md files for AI assistants
3. **Maintain Portability**: No hardcoded paths, dynamic detection only
4. **Security Review**: Ensure no secrets in public repos
5. **Multi-Host Validation**: Test on both ARM64 and x86_64

### 📝 **Contribution Guidelines**
- Fork the repository and create feature branches
- All changes must pass the Phoenix Testing Lab validation
- Update documentation for any new features
- Follow the existing code style and conventions
- Add tests for new functionality

## 🏆 **Why FeNix?**

FeNix represents the evolution from configuration management to **complete Digital Life as Code (DLaC)**. Every component is designed for:

- 🎯 **Ultimate Reliability** - Battle-tested across distributions and architectures
- 🚀 **Maximum Portability** - Works anywhere Linux runs
- ⚡ **Rapid Recovery** - Minutes, not hours, to full productivity
- 🔒 **Security First** - Multi-layered backup and intrusion detection
- 🧠 **Intelligence** - Learns and adapts to your usage patterns

*Rise from the ashes, stronger than before.* 🔥

---

## 📄 License

MIT License - see [LICENSE](LICENSE) for details.

## 🙏 Acknowledgments

Inspired by the Phoenix mythological creature and the principle that great systems should be able to resurrect themselves from nothing but their own descriptions.

Special thanks to the open-source community for the tools that make FeNix possible.

---

---

## 🏗️ Machine Architecture

### Machine Roles

**🏠 Main Workstation (ron)**
- Your primary machine where you do most work
- Always has hostname "ron" 
- Other machines connect TO this one
- Stores master copies of projects and data
- Runs primary containers and services

**🖥️ Remote Environment (pi5, laptop, work-desktop)**
- Satellite machines for remote work
- Keep their original hostnames
- Synchronized environment that connects back to ron
- Lightweight setup, syncs data from main workstation

### Repository Structure

```
GitHub Repositories:
├── nixfred/fenix              # 🌍 PUBLIC - Master system, bootstrap scripts
├── nixfred/fenix-dotfiles     # 🌍 PUBLIC - Shell configs, aliases, functions  
└── nixfred/fenix-private      # 🔐 PRIVATE - SSH keys, secrets, host configs

Local Structure:
~/.fenix/
├── public/                    # Public configurations
├── private/                   # Private configurations (SSH keys, secrets)
├── dotfiles/                  # Shell environment files
└── backups/                   # System backups
```

---

## 🔑 SSH Key Strategy - SAME KEYS EVERYWHERE

**IMPORTANT:** FeNix uses the SAME SSH keys on ALL machines for seamless operation.

### Why Same Keys Everywhere?
- **Seamless Connection:** Any machine can SSH to any other machine
- **Git Access:** Same GitHub/GitLab access from all machines  
- **Container Deployment:** Deploy containers across hosts without re-authentication
- **Simplified Management:** One key pair to manage instead of multiple

### SSH Key Distribution
```bash
~/.ssh/
├── id_rsa          # SAME private key on all machines
├── id_rsa.pub      # SAME public key on all machines
├── config          # SSH client configuration
└── known_hosts     # Trusted hosts (grows as you connect)
```

### Security Considerations
- **Private repo only:** SSH keys never stored in public repositories
- **Proper permissions:** 600 for private keys, 644 for public keys
- **Backup strategy:** Keys stored in encrypted private Git repository
- **Key rotation:** Change keys periodically, update all machines via FeNix

---

## 🚀 Quick Start Commands

### Fresh Machine Setup
```bash
# On any fresh Linux machine:
curl -s https://raw.githubusercontent.com/nixfred/fenix/main/bootstrap.sh | bash

# Follow the prompts:
# 1) Choose machine type (main workstation or remote environment)  
# 2) Configure SSH keys
# 3) Let FeNix install everything
```

### Daily Commands
```bash
# Reload shell configuration
sb                              

# Jump to projects (auto-detected directory)
j proj                          

# SSH to other host (smart routing)
pp                              

# Container access
edc                             # Interactive menu
edc 2                           # Direct access to container #2

# Sync operations  
fenix sync                      # Sync changes across hosts
fenix backup                    # Create system backup
fenix status                    # System health check
```

---

## 📋 Scenario 1: Adding a New Computer

### Step 1: Determine Machine Role
**Before running anything, decide:**
- **Main Workstation Replacement?** → Will this become the new "ron"?
- **Remote Environment?** → Will this be a satellite machine?

### Step 2: Run FeNix Bootstrap
```bash
# On the new machine:
curl -s https://raw.githubusercontent.com/nixfred/fenix/main/bootstrap.sh | bash
```

### Step 3: Choose Configuration During Bootstrap

**For Remote Environment (pi5-style):**
```bash
# Bootstrap will ask:
"What type of machine is this? [1-3]: "
# Choose: 2) Remote Environment (pi5-style) - Synchronized work environment

# Results:
✅ Keeps current hostname (laptop, pi-work, etc.)
✅ Installs same SSH keys for seamless connection
✅ Gets "gohome" alias to connect back to ron
✅ Syncs environment but maintains separate identity
✅ Lightweight configuration focused on connecting back to main
```

**For Main Workstation Replacement:**
```bash
# Bootstrap will ask:
"What type of machine is this? [1-3]: "  
# Choose: 1) Main Workstation (ron replacement) - Full digital life transfer

# Results:
✅ Changes hostname to "ron" (after reboot)
✅ Installs complete SSH key set with full permissions
✅ Gets management aliases (checkremotes, deployeverywhere)
✅ Becomes the center that other machines connect to
✅ Restores complete container environments and data
```

### Step 4: Post-Installation
```bash
# Reload shell to activate new configuration
source ~/.bashrc

# Test the installation
j proj                          # Should jump to projects directory
edc                             # Should show container menu (if Docker available)
pp                              # Should connect to appropriate host

# For remote environments, test connection to main:
gohome                          # Should SSH to ron
```

### Step 5: Verify SSH Connections
```bash
# Test SSH connections between machines
ssh ron                         # From remote to main
ssh pi5                         # From main to remote (if pi5 exists)
ssh laptop                      # To any other configured machine

# If SSH fails, check:
ssh-keygen -l -f ~/.ssh/id_rsa  # Verify key is installed
cat ~/.ssh/id_rsa.pub           # Check public key content
```

---

## 🚚 Scenario 2: Moving Ron to a New Machine

### When You Need This
- Main workstation (ron) hardware fails
- Upgrading to new primary machine  
- Consolidating workstations

### Step 1: Prepare New Machine
```bash
# On the NEW machine that will become ron:
curl -s https://raw.githubusercontent.com/nixfred/fenix/main/bootstrap.sh | bash
```

### Step 2: Choose Main Workstation Mode
```bash
# During bootstrap, choose:
"What type of machine is this? [1-3]: "
# Answer: 1) Main Workstation (ron replacement) - Full digital life transfer
```

### Step 3: Bootstrap Process
The bootstrap will automatically:
```bash
✅ Change hostname to "ron" (requires reboot to take effect)
✅ Install complete SSH keys with full permissions
✅ Restore all dotfiles and configurations  
✅ Set up container environments
✅ Configure as primary machine for remote connections
✅ Install management aliases and functions
```

### Step 4: Reboot and Verify
```bash
# Reboot to activate hostname change
sudo reboot

# After reboot, verify:
hostname                        # Should show "ron"
ssh pi5                         # Should connect to remote machines
docker ps                       # Should show restored containers
j proj                          # Should jump to projects directory
```

### Step 5: Update Remote Machines
```bash
# On each remote machine (pi5, laptop, etc.), update known_hosts:
ssh-keygen -R ron               # Remove old ron key
ssh ron                         # Connect and accept new host key

# Or simply:
ssh-keyscan ron >> ~/.ssh/known_hosts
```

### Step 6: Decommission Old Machine
```bash
# On old ron machine (if accessible):
# 1. Final data sync to new ron
rsync -av ~/projects/ new-ron:~/projects/

# 2. Final backup
fenix backup

# 3. Secure wipe (optional)
sudo shred -vfz -n 3 ~/.ssh/id_rsa
```

---

## 🔧 SSH Key Management Details

### Initial Key Setup
```bash
# Keys are managed through FeNix private repository
# During bootstrap, you'll choose:

# Option 1: Generate new keys
# - FeNix creates new SSH key pair
# - You add public key to GitHub/GitLab
# - Private key stored in fenix-private repo

# Option 2: Import existing keys  
# - Paste your existing private key
# - Paste your existing public key
# - FeNix installs them everywhere

# Option 3: GitHub import
# - Import public key from GitHub profile
# - You provide private key manually
```

### Key Distribution Process
```bash
# FeNix automatically:
1. Stores keys in ~/.ssh/ with correct permissions
   chmod 700 ~/.ssh
   chmod 600 ~/.ssh/id_rsa
   chmod 644 ~/.ssh/id_rsa.pub

2. Updates SSH config for multi-host access
3. Adds known hosts for trusted connections
4. Tests GitHub/GitLab connectivity
5. Enables seamless machine-to-machine SSH
```

### Key Security Best Practices
```bash
# Backup verification
ls -la ~/.ssh/                  # Check permissions
ssh-keygen -l -f ~/.ssh/id_rsa  # Verify key fingerprint
ssh -T git@github.com           # Test GitHub access

# Key rotation (annually recommended)
ssh-keygen -t rsa -b 4096 -C "your-email@domain.com"
# Then update fenix-private repo and redeploy to all machines
```

---

## 🐳 Container Management

### Container Operations
```bash
# Interactive container menu
edc                             

# Direct container access
edc 1                           # Connect to first container
edc 2                           # Connect to second container

# Container status across hosts
fenix container-status          # Check containers on all hosts

# Deploy containers everywhere
fenix deploy-containers         # Deploy to main + all remotes
```

### Multi-Host Container Deployment
```bash
# From main workstation (ron):
docker-compose up -d            # Start containers locally
ssh pi5 "cd ~/projects && docker-compose up -d"  # Start on remote

# Or use FeNix automation:
deployeverywhere                # Alias that deploys to all configured hosts
```

---

## 🔄 Sync and Backup Operations

### Project Synchronization
```bash
# From main workstation:
synctoremotes                   # Push projects to all remote machines

# From remote environment:
syncfromhome                    # Pull latest projects from ron
```

### System Backups
```bash
# Create system backup
fenix backup                    # Creates timestamped backup

# System health check
fenix status                    # Shows system health across all hosts
neo                             # Detailed system information banner
```

### Git-Based Configuration Sync
```bash
# Your configurations are in Git - sync anytime:
cd ~/.fenix/dotfiles
git pull origin main            # Get latest configs

cd ~/.fenix/private  
git pull origin main            # Get latest private configs

# Push your changes:
bashup                          # Pushes dotfiles to GitHub automatically
```

---

## 🧪 Testing and Validation

### Test New Configurations Safely
```bash
# Test FeNix on pristine container before deploying:
docker run -it ubuntu:22.04 /bin/bash

# Inside container:
curl -s https://raw.githubusercontent.com/nixfred/fenix/main/bootstrap.sh | bash
```

### Validate Installation
```bash
# Check all components after installation:
which edc                       # Should find edc command
j proj && pwd                   # Should jump to projects directory  
ssh -T git@github.com           # Should authenticate with GitHub
docker ps                       # Should show containers (if Docker installed)
```

### Performance Benchmarks
```bash
# Target metrics for FeNix installation:
# - Fresh machine to full productivity: <10 minutes
# - Bootstrap Phase 1 (public setup): <3 minutes  
# - SSH key configuration: <2 minutes
# - Private configuration install: <3 minutes
# - Container environment setup: <2 minutes
```

---

## 🚨 Troubleshooting

### Common Issues and Solutions

**SSH Connection Fails**
```bash
# Check SSH key installation
ls -la ~/.ssh/id_rsa            # Should exist with 600 permissions
ssh-keygen -l -f ~/.ssh/id_rsa  # Check key fingerprint

# Test GitHub connection
ssh -T git@github.com           # Should show authentication success

# Regenerate known_hosts
rm ~/.ssh/known_hosts
ssh ron                         # Reconnect and accept host key
```

**Bootstrap Fails**
```bash
# Check internet connectivity
ping google.com

# Check GitHub access
curl -I https://github.com

# Check repository access
git clone https://github.com/nixfred/fenix.git /tmp/test-clone
```

**Hostname Change Doesn't Work**
```bash
# Manually change hostname (requires sudo)
sudo hostnamectl set-hostname ron
sudo sed -i 's/old-hostname/ron/g' /etc/hosts
sudo reboot
```

**Dynamic Path Detection Fails**
```bash
# Check if paths exist
ls -la /usr/local/bin/edc       # Check edc location
ls -la ~/projects               # Check projects directory

# Manually set paths
export PATH="$PATH:$HOME/bin"
source ~/.bashrc
```

---

## 📈 Advanced Usage

### Custom Machine Configurations
```bash
# Edit machine-specific configs in private repo:
cd ~/.fenix/private

# For main workstation additions:
vim configs/main/.bashrc_main

# For remote environment additions:  
vim configs/remote/.bashrc_remote

# Push changes:
git add . && git commit -m "Update machine configs" && git push
```

### Multi-Host Management
```bash
# Check status of all machines from ron:
checkremotes                    # Shows uptime and containers on all remotes

# Deploy same container to all hosts:
deployeverywhere                # Runs docker-compose on all configured machines

# Sync data to all remotes:
synctoremotes                   # Pushes ~/projects to all remote machines
```

### Environment Customization
```bash
# Add custom aliases (survives FeNix updates):
echo 'alias myalias="command"' >> ~/.bash_aliases_local

# Add custom functions:
vim ~/.functions_local

# These files are preserved during FeNix updates
```

---

## 🔒 Security Considerations

### SSH Key Security
- **Single key pair:** Same keys on all machines for seamless operation
- **Private storage:** Keys only in encrypted private Git repository
- **Proper permissions:** Automatic permission setting (600/644)
- **Regular rotation:** Change keys annually, update via FeNix

### Repository Security
- **Public repos:** Only sanitized configurations, no secrets
- **Private repos:** SSH keys, API keys, passwords - proper access control
- **Git encryption:** All data encrypted in transit via HTTPS/SSH

### Network Security
- **VPN recommended:** Use Tailscale or similar for secure remote access
- **SSH hardening:** Disable password auth, use key-based only
- **Firewall:** Configure appropriate firewall rules on main workstation

---

## 🛠️ Maintenance

### Regular Maintenance Tasks
```bash
# Weekly:
fenix status                    # Check system health
bashup                          # Sync any configuration changes

# Monthly:  
fenix backup                    # Create full system backup
sudo apt update && sudo apt upgrade  # Update system packages

# Annually:
# Rotate SSH keys via FeNix bootstrap
# Review and clean up old containers
# Update container base images
```

### Updating FeNix System
```bash
# Update FeNix master system:
cd ~/.fenix/public
git pull origin main

# Update your configurations:
cd ~/.fenix/dotfiles  
git pull origin main

# Update private configurations:
cd ~/.fenix/private
git pull origin main

# Reinstall if major updates:
curl -s https://raw.githubusercontent.com/nixfred/fenix/main/bootstrap.sh | bash
```

---

## 📞 Getting Help

### Documentation Locations
- **This Complete Runbook:** Right here in this README
- **Local CLAUDE.md:** `/home/pi/fenix/CLAUDE.md` (AI assistant instructions)
- **GitHub Issues:** https://github.com/nixfred/fenix/issues

### Self-Diagnosis Commands
```bash
# System health check
fenix status

# Configuration verification  
source ~/.bashrc && echo "Shell config OK"

# SSH connectivity test
ssh -T git@github.com

# Container status
docker ps --format "table {{.Names}}\t{{.Status}}"
```

### Recovery Commands
```bash
# Emergency: Restore from backup
fenix restore

# Emergency: Fresh FeNix installation
curl -s https://raw.githubusercontent.com/nixfred/fenix/main/bootstrap.sh | bash

# Emergency: Manual SSH key restoration
# (Keep a copy of your private key in secure location outside of FeNix)
```

---

## 🎯 Key Takeaways

1. **Same SSH keys everywhere** - This is what makes FeNix seamless
2. **Ron is always the center** - Main workstation, others connect to it
3. **Git is your backup** - Everything important is in Git repositories
4. **Test before deploying** - Use containers to validate changes
5. **One command resurrection** - Complete environment in <10 minutes

**FeNix Philosophy:** Your entire digital life should be reproducible from a single command. No exceptions, no manual steps, no "I forgot how to set that up."

---

**🔥 Rise from the ashes, stronger than before. 🔥**

**[⬆ Back to top](#-fenix-phoenix-system---complete-runbook)**