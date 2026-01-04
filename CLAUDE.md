# Fenix Architecture

## Overview

Lightweight container management using distrobox. Runs on box, accessible via SSH from fnix/mac.

## Commands

| Command | Interactive | Description |
|---------|-------------|-------------|
| `f` | Yes | List containers |
| `f <name>` | Yes | Create/enter Ubuntu 24.04 container |
| `k <name>` | Yes | Create/enter Kali container |
| `fx <name>` | Yes | Destroy container (confirms) |
| `fl` | No | List containers |
| `fe <name> <cmd>` | No | Execute command in container |
| `fxq <name>` | No | Destroy container (no confirm) |
| `finfo <name>` | No | Show container info |

**Claude Code**: Use `fl`, `fe`, `fxq`, `finfo` only (non-interactive). See HOWTO.md.

## Architecture

```
box (Linux host)
├── ~/.local/bin/distrobox     # container runtime
├── ~/Projects/f/              # git repo (source of truth)
├── ~/.config/fenix/           # synced config
└── /home/pi                   # shared with containers

fnix/mac (remote machines)
├── ~/.config/fenix/           # synced via Syncthing
└── SSH to box                 # commands execute remotely

Containers (on box)
├── {name}  # ubuntu:24.04 (via f), sshd on port 2201+
└── {name}  # kalilinux/kali-last-release (via k), sshd on port 2201+
```

## Remote Execution

The `_fenix()` helper detects hostname:
- On `box`: runs distrobox locally
- On `fnix`/`mac`: SSH to box with TTY allocation

```bash
_fenix() {
    if [[ "$(hostname)" == "$FENIX_HOST" ]]; then
        eval "$1"
    else
        ssh -t -o ConnectTimeout=$_FENIX_TIMEOUT "$FENIX_HOST" "$1"
    fi
}
```

## Container Naming

Container name = argument passed. No prefixes.

- `f dev` → container named `dev`
- `k hack` → container named `hack`

## Password Prompt Fix

Distrobox prompts for password on first entry. Skip by mounting marker file:

```bash
touch /tmp/.nopasswd
--volume /tmp/.nopasswd:/run/.nopasswd:ro
```

## Auto SSH Setup

New containers automatically get sshd installed on unique ports (2201-2299):

1. `_fenix_next_port()` finds first available port
2. `_fenix_setup_ssh()` installs openssh-server and configures port
3. sshd starts automatically after container creation

Use `finfo {name}` to see the SSH port for a container.

## Key Flags

```bash
distrobox create \
  -i ubuntu:24.04 \                           # image
  -n {name} \                                 # container name
  --home /home/pi \                           # mount home
  --hostname {name} \                         # prompt hostname
  --volume /tmp/.nopasswd:/run/.nopasswd:ro \ # skip password
  --yes                                       # no prompts
```

## Files

| File | Purpose |
|------|---------|
| `fenix.bashrc` | Shell functions |
| `README.md` | User documentation |
| `CLAUDE.md` | Architecture (this file) |
| `HOWTO.md` | Claude Code usage guide |

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `FENIX_HOST` | `box` | Host running distrobox |
| `_FENIX_DB` | `/home/pi/.local/bin/distrobox` | Distrobox path (internal) |
| `_FENIX_TIMEOUT` | `5` | SSH connection timeout (seconds) |

## Sync Workflow

```
~/Projects/f/fenix.bashrc        # Edit here (git tracked)
        ↓ (manual copy or post-commit hook)
~/.config/fenix/fenix.bashrc     # Local config on box
        ↓ (Syncthing)
fnix:~/.config/fenix/            # Synced
mac:~/.config/fenix/             # Synced
```

### Syncthing Configuration

1. **On box**: Share `~/.config/fenix` folder
   - Folder ID: `fenix`
   - Folder Path: `/home/pi/.config/fenix`
   - Share with: fnix, mac devices

2. **On fnix/mac**: Accept folder share from box
   - Folder Path: `~/.config/fenix`

3. **Sync Direction**: Send Only from box (box is source of truth)

### Manual Sync

```bash
# From box
scp ~/.config/fenix/fenix.bashrc fnix:~/.config/fenix/
scp ~/.config/fenix/fenix.bashrc mac:~/.config/fenix/
```

## Troubleshooting

### Password prompt still appears

Remove the marker file inside container:

```bash
~/.local/bin/distrobox enter {name} -- rm -f /var/tmp/.pi.passwd.initialize
```

### Container won't start

```bash
docker logs {name}
```

### SSH connection fails from fnix/mac

Ensure passwordless SSH to box:

```bash
ssh-copy-id box
```

### Commands not found after sync

Re-source the config:

```bash
source ~/.config/fenix/fenix.bashrc
```
