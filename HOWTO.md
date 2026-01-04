# Fenix HOWTO for Claude Code

Guide for AI assistants (Claude Code) to use fenix containers.

## Available Commands

| Command | Interactive | Use |
|---------|-------------|-----|
| `fl` | No | List containers (colored) |
| `fe <name> <cmd>` | No | Execute command in container |
| `fxq <name>` | No | Destroy container (no prompt) |
| `finfo <name>` | No | Show container info |
| `f <name>` | Yes | Create/enter Ubuntu (humans only) |
| `k <name>` | Yes | Create/enter Kali (humans only) |
| `fx <name>` | Yes | Destroy with prompt (humans only) |

**Claude Code can only use:** `fl`, `fe`, `fxq`, `finfo`

## When to Use Containers

**USE containers for:**
- Running untrusted or experimental code
- Installing packages without polluting host
- Testing in clean environments
- Security tools (Kali)
- Reproducible test scenarios
- Services that shouldn't run on host

**DON'T need containers for:**
- Normal file editing
- Git operations
- Reading/analyzing code
- Most development tasks
- Anything that works fine on host

## Usage Examples

### List containers
```bash
fl
```

### Get container info
```bash
finfo packages
```

### Run command in container
```bash
fe myenv ls -la
fe myenv cat /etc/os-release
fe myenv pwd
```

### Run Python script
```bash
fe myenv python3 /home/pi/Projects/script.py
```

### Install package and use it
```bash
fe myenv apt update
fe myenv apt install -y curl
fe myenv curl https://example.com
```

### Multi-command
```bash
fe myenv "cd /home/pi/Projects && ls -la"
```

### Destroy when done
```bash
fxq myenv
```

### Error handling
```bash
# This fails cleanly if container doesn't exist:
fe nonexistent echo hello
# Error: container 'nonexistent' does not exist. Create with: f nonexistent
```

## Container Characteristics

- **Shared home**: `/home/pi` is same as host
- **Isolated system**: Package installs don't affect host
- **Persistent**: Survives reboots until destroyed
- **Ubuntu 24.04** (via `f`) or **Kali** (via `k`)
- **Host network**: Containers share box's network
- **SSH enabled**: Each container has sshd on unique port (2201-2299)

## Typical Workflow

1. User creates container: `f testenv`
2. User sets up environment (optional): `apt install python3-pip`
3. User exits: `exit`
4. Claude Code uses container:
   ```bash
   fe testenv pip install requests
   fe testenv python3 myscript.py
   ```
5. When done: `fxq testenv`

## Limitations

- Claude Code cannot use `f`, `k`, `fx` (interactive)
- First command in new container may be slow (initialization)
- Container must exist before `fe` can use it
- Commands run as user `pi` inside container
- SSH timeout is 5 seconds (fails fast if box offline)

## Alternative: Direct Host Execution

For most tasks, just run on host:

```bash
python3 script.py
npm install
git status
```

Only use containers when isolation is specifically needed.
