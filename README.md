# Fenix

Ephemeral Linux containers from any machine. Runs on box, accessible from anywhere.

## Commands

```bash
# Interactive (humans)
f              # list containers (colored)
f mybox        # create/enter Ubuntu container
k pentest      # create/enter Kali container
fx mybox       # destroy container (prompts)
finfo mybox    # show container info

# Non-interactive (scripts, Claude Code)
fl             # list containers (colored)
fe mybox pwd   # execute command in container
fxq mybox      # destroy container (no prompt)
```

| Command | Interactive | Description |
|---------|-------------|-------------|
| `f` | Yes | List containers |
| `f <name>` | Yes | Create/enter Ubuntu 24.04 container |
| `k <name>` | Yes | Create/enter Kali container |
| `fx <name>` | Yes | Destroy container (confirms) |
| `finfo <name>` | No | Show container info |
| `fl` | No | List containers |
| `fe <name> <cmd>` | No | Execute command in container |
| `fxq <name>` | No | Destroy container (no confirm) |

Works from box (local), fnix (SSH), or mac (SSH).

**Tab completion** supported for all commands.

## Features

- Color-coded container status (green=running, yellow=stopped)
- Tab completion for container names
- 5-second SSH timeout (no hanging if box offline)
- Container info display (status, image, start time)

## Setup

### On box (Linux host)

Requirements:
- [distrobox](https://github.com/89luca89/distrobox) at `/home/pi/.local/bin/distrobox`
- Docker or Podman

```bash
# Clone repo
git clone <repo> ~/Projects/f

# Create config dir and copy
mkdir -p ~/.config/fenix
cp ~/Projects/f/fenix.bashrc ~/.config/fenix/

# Source in .bashrc
echo 'source ~/.config/fenix/fenix.bashrc' >> ~/.bashrc
```

### On fnix/mac (remote machines)

```bash
# Create config dir
mkdir -p ~/.config/fenix

# Source in .bashrc
echo 'source ~/.config/fenix/fenix.bashrc 2>/dev/null' >> ~/.bashrc
```

### Syncthing Setup

Sync `~/.config/fenix/` across all machines:

1. On box: Add `~/.config/fenix` as shared folder
2. On fnix/mac: Accept folder share from box
3. Set sync type to "Send Only" from box

Folder ID: `fenix`

### Manual Sync

```bash
# From box
scp ~/.config/fenix/fenix.bashrc fnix:~/.config/fenix/
scp ~/.config/fenix/fenix.bashrc mac:~/.config/fenix/
```

## How it works

- Commands execute on box (locally or via SSH from remote machines)
- `f mybox` creates Ubuntu 24.04 container named `mybox`
- `k pentest` creates Kali container named `pentest`
- First run pulls image (~1-3 min), subsequent runs enter instantly
- `/home/pi` shared between host and containers
- No password prompts on first entry
- `fx mybox` or `fxq mybox` destroys container

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `FENIX_HOST` | `box` | Linux host running distrobox |
| `_FENIX_TIMEOUT` | `5` | SSH connection timeout (seconds) |

## Images

| Command | Image |
|---------|-------|
| `f` | `ubuntu:24.04` |
| `k` | `docker.io/kalilinux/kali-last-release` |
