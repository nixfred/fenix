# Fenix

Ephemeral Linux containers from your shell.

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

## How it works

- `f mybox` → container named `mybox`
- First run pulls image and creates container
- Subsequent runs enter immediately
- `/home/pi` is shared between host and containers
- System changes inside container don't affect host
- `fx mybox` destroys it completely
