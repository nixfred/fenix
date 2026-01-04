# Fenix Architecture

## Overview

Lightweight container management using distrobox. Three functions: `f` (ubuntu), `k` (kali), `fx` (destroy).

## Architecture

```
box (Linux host)
├── ~/.local/bin/distrobox     # container runtime
├── ~/Projects/f/fenix.bashrc  # functions
└── /home/pi                   # shared with containers

Containers
├── {name}  # ubuntu:24.04 (via f)
└── {name}  # kalilinux/kali-last-release (via k)
```

## Container Naming

Container name = what you pass in. No prefixes.

- `f dev` → container named `dev`
- `k hack` → container named `hack`

## Key Implementation Details

### Password Prompt Fix

Distrobox normally prompts for password on first entry. We skip this by mounting a marker file:

```bash
touch /tmp/.nopasswd
--volume /tmp/.nopasswd:/run/.nopasswd:ro
```

This tells distrobox-init to skip password setup (same as `--absolutely-disable-root-password-i-am-really-positively-sure` but works reliably).

### Key Flags

```bash
distrobox create \
  -i ubuntu:24.04 \                        # image
  -n {name} \                              # container name
  --home /home/pi \                        # mount home
  --hostname {name} \                      # prompt hostname
  --volume /tmp/.nopasswd:/run/.nopasswd:ro \  # skip password
  --yes                                    # no prompts
```

## Files

- `fenix.bashrc` - f, k, fx functions
- `README.md` - user docs
- `CLAUDE.md` - this file

## Environment

- `FENIX_DB` - distrobox path (default: ~/.local/bin/distrobox)

## Sync Workflow

```
~/Projects/f/fenix.bashrc     # Edit here (git tracked)
        ↓ (post-commit hook)
~/.config/fenix/fenix.bashrc  # Local copy
        ↓ (scp via post-commit hook)
fnix:~/.config/fenix/         # Auto-synced on commit
```

Post-commit hook (`.git/hooks/post-commit`):
- Copies to local `~/.config/fenix/`
- SCPs to fnix (fails gracefully if offline)

All machines source from `~/.config/fenix/fenix.bashrc`

## Troubleshooting

### Password prompt still appears

The marker file `/var/tmp/.pi.passwd.initialize` triggers the prompt. Fix:

```bash
~/.local/bin/distrobox enter {name} -- rm -f /var/tmp/.pi.passwd.initialize
```

### Container won't start

Check docker logs:

```bash
docker logs {name}
```
