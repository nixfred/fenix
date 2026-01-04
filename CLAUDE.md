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
└── {name}  # kalilinux/kali-rolling (via k)
```

## Container Naming

Container name = what you pass in. No prefixes.

- `f dev` → container named `dev`
- `k hack` → container named `hack`

## Key Flags

```bash
distrobox create \
  -i ubuntu:24.04 \      # image
  -n {name} \            # container name
  --home /home/pi \      # mount home
  --hostname {name} \    # prompt hostname
  --yes                  # no prompts
```

## Files

- `fenix.bashrc` - f, k, fx functions
- `README.md` - user docs
- `CLAUDE.md` - this file

## Environment

- `FENIX_DB` - distrobox path (default: ~/.local/bin/distrobox)
