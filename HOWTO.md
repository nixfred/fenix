# Fenix HOWTO for Claude Code

Guide for AI assistants (Claude Code) to use fenix containers.

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

## Commands Reference

| Command | Interactive | Description |
|---------|-------------|-------------|
| `fl` | No | List containers |
| `fe <name> <cmd>` | No | Execute command in container |
| `fxq <name>` | No | Destroy container (no prompt) |
| `f <name>` | Yes | Create/enter Ubuntu container |
| `k <name>` | Yes | Create/enter Kali container |
| `fx <name>` | Yes | Destroy container (prompts) |

**Claude Code can only use non-interactive commands:** `fl`, `fe`, `fxq`

## Creating a Container

Containers are created on first use. To prepare a container for Claude Code:

```bash
# User runs interactively (creates container, installs packages):
f myenv
apt update && apt install -y python3 nodejs
exit

# Now Claude Code can use it:
fe myenv python3 --version
fe myenv node --version
```

Or create without entering:

```bash
# This creates but connection closes after setup
f myenv
# Container now exists, Claude Code can use fe
```

## Claude Code Usage Examples

### List available containers
```bash
fl
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

### Multi-command (use && or ;)
```bash
fe myenv "cd /home/pi/Projects && ls -la"
```

### Destroy when done
```bash
fxq myenv
```

## Container Characteristics

- **Shared home**: `/home/pi` is same as host
- **Isolated system**: Package installs don't affect host
- **Persistent**: Survives reboots until destroyed
- **Ubuntu 24.04** (via `f`) or **Kali** (via `k`)

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

## Alternative: Direct Host Execution

For most tasks, just run on host:

```bash
# This works fine without containers:
python3 script.py
npm install
git status
```

Only use containers when isolation is specifically needed.
