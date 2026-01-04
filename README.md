# Fenix

Ephemeral Linux containers from your shell. No password prompts, instant entry.

## Usage

```bash
f              # list containers
f mybox        # create/enter ubuntu container
k pentest      # create/enter kali container
fx mybox       # destroy container
```

## Setup

```bash
# Add to .bashrc
source ~/Projects/f/fenix.bashrc
```

Requires: [distrobox](https://github.com/89luca89/distrobox) at `~/.local/bin/distrobox`

## How it works

- `f mybox` → creates ubuntu:24.04 container named `mybox`
- `k pentest` → creates kali-last-release container named `pentest`
- First run pulls image and creates container (~1-3 min)
- Subsequent runs enter immediately
- `/home/pi` is shared between host and containers
- Hostname in prompt shows container name
- System changes inside container don't affect host
- `fx mybox` destroys it completely

## Features

- No password prompts on first entry
- Direct container naming (no prefixes)
- Shared home directory
- Correct hostname in prompt

## Images

- Ubuntu: `ubuntu:24.04`
- Kali: `docker.io/kalilinux/kali-last-release`
