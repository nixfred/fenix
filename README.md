# Fenix

Ephemeral Linux containers from any machine. Runs on box, accessible from anywhere.

## Usage

```bash
f              # list containers
f mybox        # create/enter ubuntu container
k pentest      # create/enter kali container
fx mybox       # destroy container
```

Works from box (local), fnix (SSH), or mac (SSH).

## Setup

### On box (Linux host)

Requirements:
- [distrobox](https://github.com/89luca89/distrobox) at `/home/pi/.local/bin/distrobox`
- Docker or Podman

```bash
# Clone repo
git clone <repo> ~/Projects/f

# Create config dir and link
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

1. On box: Add `~/.config/fenix` as shared folder in Syncthing
2. On fnix/mac: Add box as remote device, accept folder share
3. Set sync type to "Send Only" from box (box is source of truth)

Folder ID suggestion: `fenix`

### Manual Sync (alternative)

```bash
# From box, push to remotes
scp ~/.config/fenix/fenix.bashrc fnix:~/.config/fenix/
scp ~/.config/fenix/fenix.bashrc mac:~/.config/fenix/
```

## How it works

- Commands run on box (locally or via SSH from remote machines)
- `f mybox` creates ubuntu:24.04 container named `mybox`
- `k pentest` creates kali container named `pentest`
- First run pulls image (~1-3 min), subsequent runs enter instantly
- `/home/pi` shared between host and containers
- No password prompts on first entry
- `fx mybox` destroys container completely

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `FENIX_HOST` | `box` | Linux host running distrobox |

## Images

| Command | Image |
|---------|-------|
| `f` | `ubuntu:24.04` |
| `k` | `docker.io/kalilinux/kali-last-release` |
