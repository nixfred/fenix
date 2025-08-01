# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is the **FeNix Phoenix System** - a comprehensive Git-based Infrastructure-as-Code solution for portable development environments. FeNix enables complete digital workspace resurrection from a fresh Linux machine in under 10 minutes using a single bootstrap command.

**Core Philosophy**: *"If my machine dies, I'm back to 100% productivity in under 10 minutes"*

## Architecture Overview

### Multi-Host Infrastructure
FeNix operates across a scalable distributed architecture:
- **Main Host** (Primary workstation) ↔ **Multiple Remote Clients** (Development, testing, production environments)
- **Unlimited scalability**: Add any number of remote clients with role-based management
- **Cross-architecture compatibility**: ARM64 + x86_64 + any Linux distribution
- **Automatic host discovery and configuration**: Dynamic client registration and management
- **Role-based deployment**: Deploy containers based on client roles (development, testing, production, mobile)
- **Bidirectional file synchronization and container orchestration**
- **Backward compatible**: Existing ron/pi5 setups automatically migrate to new architecture

### Repository Ecosystem
```
/home/pi/
├── fenix/                  # Master system repository
│   ├── bootstrap.sh        # One-command installation
│   ├── testing/           # Multi-distro chaos testing
│   ├── CLAUDE.md          # System documentation
│   ├── README.md          # Complete user runbook
│   └── edc                # Container access tool
├── .fenix/                 # Multi-host configuration system
│   ├── hosts.conf          # Host configuration and relationships
│   ├── host-manager.sh     # Host management library functions
│   ├── setup-remote-client.sh  # Add new remote clients
│   ├── monitor-clients.sh  # Multi-client status dashboard
│   ├── deploy-container.sh # Deploy containers to multiple clients
│   ├── client-workflows.md # Documentation for client workflows
│   └── integration-test.sh # Test suite for multi-host system
├── fenix-dotfiles/        # Public shell configurations
│   ├── CLAUDE.md          # Dotfiles development guide
│   ├── install.sh         # Multi-stage installation
│   └── bin/               # Utility scripts
├── fenix-private/         # SSH keys and secrets (private)
│   ├── configs/           # Host-specific configurations
│   ├── secrets/           # API keys and tokens
│   └── ssh/               # SSH key management
├── docker/                # Multi-tier container management
│   ├── universal/         # Universal Container Creator (JSON templates)
│   ├── ubuntu-vm/         # Ubuntu development containers (V1/V2)
│   ├── kali/             # Security testing environments
│   └── CLAUDE.md          # Container architecture guide
└── dotfiles/              # Additional container utilities
```

## Key Components

### 1. Bootstrap System (`fenix/bootstrap.sh`)
Three-stage deployment architecture:
- **Stage 1**: Public repository setup (no authentication)
- **Stage 2**: SSH key configuration wizard
- **Stage 3**: Private repository deployment and container setup

**Usage patterns**:
```bash
# Full installation
curl -s https://raw.githubusercontent.com/nixfred/fenix/main/bootstrap.sh | bash

# Public-only mode
curl -s ... | bash -s -- --public-only

# Work machine mode (minimal changes)
curl -s ... | bash -s -- --work-machine
```

### 2. Dynamic Shell Environment (`fenix-dotfiles/`)
Portable bash configuration with intelligent adaptation:
- **Dynamic path detection**: No hardcoded paths, auto-discovers tools and directories
- **Multi-host awareness**: Smart SSH routing (`pp` command), container synchronization
- **Cross-platform compatibility**: Works on Ubuntu, Debian, Fedora, Arch, Alpine, CentOS

### 3. Universal Container Creator (`docker/universal/`)
Sophisticated Docker orchestration system with modular bash architecture:
- **Template-driven deployment**: JSON templates generate optimized Dockerfiles/docker-compose.yml
- **Multi-host container deployment**: Automatic sync and deployment to ron + pi5
- **Profile management**: Complete container configurations stored as JSON for redeployment
- **Health monitoring**: Real-time resource tracking and status dashboards
- **Interactive wizards**: Guided container creation with template selection
- **Docker Hub integration**: Search and discover images with API integration

### 4. FeNix Testing Labs (`fenix/testing/`)
Comprehensive validation system:
- **Multi-distro testing**: Automated testing across 6+ Linux distributions
- **Chaos engineering**: Network failures, disk space, broken dependencies
- **Performance benchmarking**: Target <10 minutes for complete system restoration

## Common Commands

### System Management
```bash
# Reload shell configuration
sb

# Jump to projects directory (dynamic detection)
j proj

# Smart SSH routing between hosts
pp

# System health dashboard
neo

# Create system snapshot
ts "backup description"
```

### Container Operations
```bash
# Interactive container menu
edc

# Direct container access
edc <number>

# Universal container management
cd docker/universal
./manage.sh start              # Interactive creation wizard
./manage.sh quick python-dev    # Quick template deployment
./manage.sh deploy <name>       # Multi-host deployment
./manage.sh list               # List all containers
./manage.sh monitor <name>     # Real-time monitoring
./manage.sh profiles           # Profile management
./manage.sh templates          # Template management
./manage.sh search <term>      # Docker Hub search
```

### Multi-Host Management
```bash
# Add new remote client
./setup-remote-client.sh pi-lab 192.168.1.150 development

# Monitor all clients
./monitor-clients.sh

# Deploy containers to specific clients
./deploy-container.sh python-dev pi-dev server-prod

# Deploy to all clients with specific role
./deploy-container.sh kali-security --role testing

# Deploy to all clients
./deploy-container.sh node-web --all

# Connect to remote clients
pp pi-dev                    # Connect to specific client
pp-role development "sb"     # Run command on all development clients
pp-all "docker ps"           # Run command on all clients
```

### Configuration Sync
```bash
# Push dotfiles to GitHub
bashup

# Pull dotfiles from GitHub (with backup)
bashdown

# Check dotfiles status
bashstat
```

### Testing and Validation
```bash
# Multi-distro compatibility test
cd fenix/testing
./multi-distro-test.sh

# Chaos engineering scenarios
./chaos-engineering.sh --scenario network_failure

# Performance benchmarking
./performance-bench.sh --target-time 600s

# Multi-host system integration tests
cd ~/.fenix
./integration-test.sh

# Test host management functions
./test-hosts.sh
```

## Architecture Patterns

### Dynamic Path Detection
All scripts use intelligent discovery instead of hardcoded paths:
```bash
# Tool detection pattern
for tool_path in "/usr/local/bin/edc" "$HOME/bin/edc" "$HOME/.local/bin/edc"; do
    if [ -f "$tool_path" ]; then
        alias edc="$tool_path"
        break
    fi
done

# Directory discovery pattern
for proj_dir in "$HOME/projects" "$HOME/Projects" "$HOME/workspace" "$HOME/docker"; do
    if [ -d "$proj_dir" ]; then
        cd "$proj_dir"
        return 0
    fi
done
```

### Multi-Host Operations
All remote operations follow sync-first pattern:
1. Sync files to remote host
2. Execute command remotely via SSH
3. Return results to local host

### Container Management Architecture
```
docker/universal/manage.sh (Unified interface)
├── config.sh (Host detection, path configuration, defaults)
├── interactive-config.sh (Interactive container creation wizard)
├── template-manager.sh (JSON templates → Dockerfile/Compose generation)
├── container-builder.sh (Docker build engine with progress tracking)
├── profile-manager.sh (Save/load complete container configurations)
├── health-monitor.sh (Real-time monitoring and resource tracking)
├── docker-search.sh (Docker Hub API integration)
└── test-system.sh (System validation and testing)

docker/ubuntu-vm/ and docker/kali/ (Specialized containers)
├── manage.sh (Container-specific interface)
├── start.sh, destroy.sh (Lifecycle management)
├── bootstrap.sh (Tool installation and configuration)
└── sync.sh (Multi-host file synchronization)
```

### Error Handling Philosophy
- **Graceful degradation**: Missing tools don't break functionality
- **Clear feedback**: Users know what's happening and why
- **Fallback options**: Alternative approaches when primary method fails
- **Atomic operations**: Prevent partial state corruption

## Security Considerations

### Repository Security Model
- **Public repos** (`fenix`, `fenix-dotfiles`): Sanitized configurations, no secrets
- **Private repos** (`fenix-private`): SSH keys, API tokens, host-specific configs
- **Same SSH keys everywhere**: Enables seamless multi-host operation

### Shell Configuration Security
- **Input validation**: All user inputs validated against safe character sets
- **No hardcoded credentials**: All sensitive data in private repository
- **Safe defaults**: Functions fail safely in unexpected environments

## Development Guidelines

### Making Changes to FeNix
1. **Test first**: Use Testing Labs to validate across distributions
2. **Maintain portability**: No hardcoded paths, use dynamic detection
3. **Document changes**: Update relevant CLAUDE.md files
4. **Security review**: Ensure no secrets in public repositories
5. **Multi-host validation**: Test on both ARM64 and x86_64

### Container Development
1. **Use templates**: Start with existing JSON templates in `docker/universal/templates/`
2. **Test in isolation**: Create containers before deploying to hosts
3. **Follow naming conventions**: Container names should be descriptive and unique
4. **Include health checks**: All containers should have proper health monitoring

### Testing New Features
```bash
# Test on pristine container
docker run -it ubuntu:22.04 /bin/bash
curl -s https://raw.githubusercontent.com/nixfred/fenix/main/bootstrap.sh | bash

# Multi-distro validation
cd fenix/testing && ./multi-distro-test.sh

# Chaos engineering
./chaos-engineering.sh --scenario <scenario_name>
```

## Important Files

### Configuration Files
- `~/.bashrc`: Main shell configuration (managed by fenix-dotfiles)
- `~/.bash_functions`: Shell functions with utilities (extract, mkcd, genpass, ts, gitcommit)
- `~/.fenix/hosts.conf`: Multi-host configuration (main host, remotes, roles)
- `docker/universal/shared/.bashrc`: Enhanced container shell environment
- `docker/universal/shared/container_config.env`: Container build configurations
- `docker/universal/templates/*.json`: Container creation templates
- `docker/universal/profiles/*.json`: Saved container configurations

### Management Scripts
- `fenix/bootstrap.sh`: Master installation script
- `~/.fenix/host-manager.sh`: Multi-host management library functions
- `~/.fenix/setup-remote-client.sh`: Add and configure new remote clients
- `~/.fenix/monitor-clients.sh`: Real-time multi-client status dashboard
- `~/.fenix/deploy-container.sh`: Deploy containers to multiple clients
- `docker/universal/manage.sh`: Universal container orchestration interface
- `docker/ubuntu-vm/manage.sh`: Ubuntu container management
- `docker/kali/manage.sh`: Kali security container management
- `fenix-dotfiles/install.sh`: Multi-stage dotfiles installation
- `fenix/edc`: Container access tool (copied to system PATH)

### Template and Profile Storage
- `docker/universal/templates/*.json`: Container creation templates (python-dev, node-web, security-kali, etc.)
- `docker/universal/profiles/*.json`: Saved container configurations for redeployment
- `docker/universal/shared/`: Persistent container data, logs, and build directories
- `docker/universal/shared/build_*/`: Container-specific build environments
- `docker/universal/shared/logs/`: Container operation logs

### Testing and Validation Scripts
- `~/.fenix/integration-test.sh`: Comprehensive multi-host system test suite
- `~/.fenix/test-hosts.sh`: Host management system validation tests
- `~/.fenix/client-workflows.md`: Complete documentation of client workflows and patterns

## Performance Targets

- **Complete system restoration**: <10 minutes
- **Bootstrap phase 1** (public setup): <3 minutes
- **SSH key configuration**: <2 minutes
- **Private configuration install**: <3 minutes
- **Container environment setup**: <2 minutes

## Troubleshooting Common Issues

### Bash Function Updates
Recent improvements to `.bash_functions`:
- Enhanced `gitcommit` function with empty commit prevention and status feedback
- All essential functions working: extract, mkcd, genpass, ts (timeshift), gitcommit
- Syntax errors resolved through simplification and character encoding fixes

### SSH Connection Issues
- Verify SSH keys exist: `ls -la ~/.ssh/id_rsa`
- Test GitHub access: `ssh -T git@github.com`
- Regenerate known_hosts if needed

### Container Issues
- Check container logs: `./manage.sh logs <container_name>`
- Monitor resources: `./manage.sh monitor <container_name>`
- Validate JSON templates: `jq . templates/<template>.json`
- Test system health: `./test-system.sh` (in docker/universal/)
- Check container status: `./manage.sh list` or `./manage.sh status`
- Access container shell: `./manage.sh connect <container_name>`

### Multi-Host System Issues
- **Configuration problems**: Run `~/.fenix/test-hosts.sh` to validate host configuration
- **Client connectivity**: Use `~/.fenix/monitor-clients.sh` to check all client status
- **Integration test failures**: Run `~/.fenix/integration-test.sh` for comprehensive validation
- **Host configuration missing**: Run `setup_fenix_hosts` to create initial configuration
- **Legacy migration**: Existing ron/pi5 setups automatically migrate to new system
- **SSH connectivity**: Test with `pp <client>` or check SSH keys on all hosts
- **Container deployment failures**: Verify client has FeNix installed and docker running
- **Role-based deployment issues**: Check host roles with `list_fenix_hosts`

This system represents the evolution from simple dotfiles to complete Infrastructure-as-Code with unlimited scalability. The multi-host architecture enables distributed development environments across any number of clients while maintaining the core FeNix philosophy of <10-minute disaster recovery and complete portability across any Linux environment.

## Multi-Host Architecture Benefits
- **Unlimited Scaling**: Add any number of remote clients with role-based management
- **Backward Compatible**: Existing ron/pi5 setups automatically migrate to new system
- **Role-Based Deployment**: Deploy different container configurations based on client roles
- **Real-Time Monitoring**: Dashboard view of all clients with health and resource monitoring
- **Automated Client Setup**: Single command to add new clients to the FeNix ecosystem
- **Distributed Resilience**: Each client can operate independently while maintaining sync capabilities