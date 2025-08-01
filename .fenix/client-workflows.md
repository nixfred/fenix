# FeNix Client/Remote Workflows

## Workflow 1: Container Deployment to Clients

### From Main Host:
```bash
# Deploy to specific client
./deploy-container.sh python-dev pi-dev

# Deploy to all development clients
./deploy-container.sh python-dev --role development

# Deploy to multiple specific clients
./deploy-container.sh python-dev pi-dev rpi-lab laptop-mobile
```

### Process:
1. Main builds container configuration
2. Main syncs files to target clients
3. Clients build/start containers locally
4. Clients report status back to main
5. Main aggregates status display

## Workflow 2: Client Health Monitoring

### Continuous Monitoring:
```bash
# From main host
./monitor-clients.sh

# Output:
# FeNix Client Status Dashboard
# =============================
# pi-dev (development):     ✅ Online | 3 containers | Load: 0.8 | Temp: 45°C
# server-prod (production): ✅ Online | 5 containers | Load: 2.1 | Temp: 62°C  
# laptop-mobile (mobile):   ❌ Offline (last seen: 2h ago)
# rpi-lab (testing):        ⚠️  High load | 2 containers | Load: 3.8 | Temp: 78°C
```

## Workflow 3: Client Configuration Sync

### Dotfiles/Config Sync:
```bash
# Push configs to all clients
bashup --all-clients

# Push to specific client
bashup --client pi-dev

# Pull config from specific client (for debugging)
bashdown --from pi-dev
```

## Workflow 4: Multi-Client Commands

### SSH Command Broadcasting:
```bash
# Run command on all clients
pp-all "docker ps"

# Run on clients with specific role
pp-role development "git pull && sb"

# Interactive session on client
pp pi-dev
```

## Workflow 5: Client Lifecycle Management

### Adding New Client:
```bash
# Method 1: From main (push)
./add-client.sh new-rpi 192.168.1.150 development

# Method 2: From client (pull)  
# On new client:
curl -s https://raw.githubusercontent.com/nixfred/fenix/main/bootstrap.sh | \
  bash -s -- --join-main workstation.local
```

### Removing Client:
```bash
# From main
./remove-client.sh old-laptop

# Cleans up:
# - SSH keys
# - Host configurations  
# - Container deployments
# - Monitoring configs
```

## Workflow 6: Disaster Recovery per Client

### Client Recovery:
```bash
# From main, restore specific client
./restore-client.sh pi-dev

# Or from client itself
curl -s https://raw.githubusercontent.com/nixfred/fenix/main/bootstrap.sh | \
  bash -s -- --restore-from workstation.local
```

### Process:
1. Client pulls latest configs from main
2. Client restores containers from main's specifications
3. Client re-establishes monitoring connections
4. Main validates client is fully operational

## Workflow 7: Client-Specific Operations

### Development Client (pi-dev):
```bash
# Auto-deploy development containers
pp pi-dev "./deploy-dev-stack.sh"

# Sync development code
rsync -avz ~/projects/ pi-dev:~/projects/
```

### Production Client (server-prod):
```bash
# Deploy with production safeguards
pp server-prod "./deploy-prod.sh --validate --backup"

# Health check
pp server-prod "./health-check.sh --full"
```

### Mobile Client (laptop-mobile):
```bash
# Lightweight sync for mobile
pp laptop-mobile "./sync-essential-only.sh"

# Offline-capable setup
pp laptop-mobile "./enable-offline-mode.sh"
```

## Workflow 8: Role-Based Management

### By Role Commands:
```bash
# Update all development clients
update-clients --role development

# Restart all production services
restart-services --role production --confirm

# Backup all testing environments
backup-clients --role testing --to /backup/testing/
```

## Workflow 9: Client Auto-Discovery

### Network Discovery:
```bash
# Scan network for FeNix clients
./discover-clients.sh 192.168.1.0/24

# Output:
# Found FeNix clients:
# 192.168.1.100 - pi-dev (development) - Online
# 192.168.1.150 - new-rpi (unknown) - Requesting join
# 192.168.1.200 - server-prod (production) - Online
```

## Workflow 10: Client Resource Management

### Resource Allocation:
```bash
# Check resource usage across clients
./resource-dashboard.sh

# Rebalance containers based on load
./rebalance-containers.sh --auto

# Scale containers across clients
./scale-service.sh web-app --replicas 5 --spread-across development
```