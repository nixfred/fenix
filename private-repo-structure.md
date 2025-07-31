# 🔐 FeNix Private Repository Structure

This defines how to organize your `fenix-private` repository for machine-specific configurations.

## Repository Structure

```bash
fenix-private/
├── README.md                    # Repository documentation
├── CLAUDE.md                   # AI assistant instructions
├── install.sh                  # Installation script with modes
├── ssh/                        # SSH keys and configuration
│   ├── id_rsa                  # Your private SSH key
│   ├── id_rsa.pub              # Your public SSH key
│   ├── config                  # SSH client configuration
│   └── known_hosts             # Trusted SSH hosts
├── configs/
│   ├── main/                   # Main workstation configs (ron)
│   │   ├── .bashrc_main        # Ron-specific bashrc additions
│   │   ├── .bash_aliases_main  # Main workstation aliases
│   │   ├── .gitconfig_main     # Git config for main workstation
│   │   └── hostname_config     # Network and system configs
│   └── remote/                 # Remote environment configs
│       ├── .bashrc_remote      # Remote environment bashrc
│       ├── .bash_aliases_remote # Remote-specific aliases
│       └── .gitconfig_remote   # Git config for remote work
├── secrets/                    # API keys, passwords, tokens
│   ├── api_keys.env           # Environment variables for APIs
│   ├── passwords.gpg          # Encrypted password store
│   └── certificates/          # SSL certificates
└── hosts/                     # Host-specific configurations
    ├── ron/                   # Main workstation specific
    │   ├── crontab            # Scheduled tasks
    │   ├── docker-compose/    # Ron-specific containers
    │   └── services/          # System services config
    └── pi5/                   # Pi5 specific configurations
        ├── gpio_config        # Raspberry Pi GPIO setup
        └── hardware_config    # Pi-specific hardware settings
```

## Machine Roles

### 🏠 Main Workstation (ron)
- **Identity**: Primary machine, other machines connect to it
- **Hostname**: Always "ron" (changes hostname if needed)
- **SSH Keys**: Full access keys for all services
- **Configuration**: Complete environment with all aliases and functions
- **Data**: Primary storage for projects and containers

### 🖥️ Remote Environment (pi5, laptop, etc.)
- **Identity**: Keeps original hostname (pi5, laptop, work-desktop)
- **Hostname**: Preserves current machine name
- **SSH Keys**: Same keys but configured to connect back to ron
- **Configuration**: Synchronized environment but with remote-specific tweaks
- **Data**: Lightweight, syncs with main workstation

## Configuration Files

### .bashrc_main (Main Workstation)
```bash
# Main workstation specific configurations
export FENIX_ROLE="main"
export MAIN_WORKSTATION="ron"

# Aliases for managing remote environments
alias checkremotes='for host in pi5 laptop; do echo "=== $host ==="; ssh $host "uptime; docker ps --format table"; done'
alias synctoremotes='for host in pi5 laptop; do rsync -av ~/projects/ $host:~/projects/; done'

# Container orchestration from main
alias deployeverywhere='docker-compose up -d && ssh pi5 "cd ~/projects && docker-compose up -d"'
```

### .bashrc_remote (Remote Environment)
```bash
# Remote environment specific configurations
export FENIX_ROLE="remote"
export MAIN_WORKSTATION="ron"
export REMOTE_HOST="$(hostname)"

# Aliases for connecting back to main
alias gohome='ssh ron'
alias syncfromhome='rsync -av ron:~/projects/ ~/projects/'
alias homecheck='ssh ron "uptime; docker ps --format table"'

# Lightweight aliases (don't duplicate heavy operations from main)
alias mainbuild='ssh ron "cd ~/projects && make build"'
```

## Installation Modes

### Main Workstation Installation
```bash
./install.sh --main-workstation
```
- Changes hostname to "ron"
- Installs complete SSH key set
- Sets up main workstation aliases and functions
- Configures as primary machine for remote connections

### Remote Environment Installation  
```bash
./install.sh --remote-environment
```
- Keeps current hostname
- Installs SSH keys for connecting to ron
- Sets up remote-specific aliases
- Adds "gohome" alias for easy connection to main

## Security Considerations

### SSH Key Strategy
- **Same keys everywhere**: Allows seamless connection between machines
- **Private repo only**: Keys never in public repositories
- **Proper permissions**: 600 for private keys, 644 for public keys

### Secret Management
- **Environment files**: API keys in .env format
- **GPG encryption**: Sensitive passwords encrypted with GPG
- **Host-specific**: Different secrets for different machine roles

### Network Configuration
- **Main always accessible**: Ron should have static IP or dynamic DNS
- **Remote connects home**: All remotes know how to reach ron
- **VPN consideration**: Tailscale or similar for secure remote access

## Migration Scenarios

### Ron Dies - Replace with New Machine
```bash
# On new machine that will become ron:
curl -s https://nixfred.dev/fenix | bash
# Choose "1) Main Workstation (ron replacement)"
# Result: New machine becomes ron, all remotes still work
```

### Add New Remote Environment
```bash  
# On new laptop/server:
curl -s https://nixfred.dev/fenix | bash
# Choose "2) Remote Environment"  
# Result: Gets synced environment, connects back to ron
```

This structure ensures your main workstation (ron) is always the center of your digital universe, while remote environments provide consistent work environments that sync back to the main system.