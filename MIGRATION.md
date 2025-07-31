# FeNix Container Command Migration

## Overview
This documents the migration of Ubuntu container management commands from the ubuntu-vm directory structure to the FeNix ecosystem.

## Changes Made

### System Command Wrappers Updated
The following system-wide commands have been updated to redirect to FeNix versions:

#### `/usr/local/bin/start`
- **Before:** Direct execution of `/home/pi/docker/ubuntu-vm/start.sh`
- **After:** Wrapper that executes `/home/pi/fenix-dotfiles/bin/ubuntu-start`
- **Fallback:** Original ubuntu-vm functionality if FeNix version not found

#### `/usr/local/bin/destroy` 
- **Before:** Direct execution of `/home/pi/docker/ubuntu-vm/destroy.sh`
- **After:** Wrapper that executes `/home/pi/fenix-dotfiles/bin/ubuntu-destroy`
- **Fallback:** Original ubuntu-vm functionality if FeNix version not found

### New FeNix Commands
Added to `fenix-dotfiles/bin/` directory:

#### `ubuntu-start [hostname]`
- **Purpose:** Creates and bootstraps Ubuntu 22.04 development containers
- **Features:**
  - Embedded bootstrap script with 40+ development tools
  - America/New_York timezone configuration
  - Custom FeNix shell configuration
  - Help documentation and error handling
  - Docker availability checks

#### `ubuntu-destroy`
- **Purpose:** Interactive container removal tool
- **Features:**
  - Visual selection menu with Ubuntu container highlighting
  - Safe confirmation for non-ubuntu containers
  - Automatic cleanup of unused Docker resources
  - Cancel option and comprehensive help

### PATH Integration
- Updated `fenix-dotfiles/.bashrc` to include `fenix-dotfiles/bin` in PATH
- Commands accessible from any shell session after FeNix installation

## Benefits of Migration

### Consistency
- All container commands now follow FeNix naming conventions
- Unified help system and error handling
- Consistent branding and user experience

### Maintainability
- Version controlled with FeNix dotfiles
- Single source of truth for container logic
- Embedded bootstrap eliminates external file dependencies

### Compatibility
- Backward compatibility maintained through wrapper scripts
- Existing workflows continue to work unchanged
- Graceful fallback to original functionality

### Integration
- Seamless integration with existing FeNix ecosystem (`edc`, bootstrap)
- PATH-based command discovery
- Follows FeNix dynamic path detection philosophy

## Command Equivalency

| Old Command | New Command | Wrapper Command | Notes |
|-------------|-------------|-----------------|-------|
| `cd /home/pi/docker/ubuntu-vm && ./start.sh` | `ubuntu-start` | `start` | System wrapper redirects |
| `cd /home/pi/docker/ubuntu-vm && ./destroy.sh` | `ubuntu-destroy` | `destroy` | System wrapper redirects |
| N/A | `ubuntu-start --help` | `start --help` | New help functionality |
| N/A | `ubuntu-destroy --help` | `destroy --help` | New help functionality |

## Usage Examples

### Starting Containers
```bash
# All of these now use FeNix ubuntu-start:
start                    # System wrapper → ubuntu-start
ubuntu-start            # Direct FeNix command
start myproject         # Custom hostname via wrapper
ubuntu-start myproject  # Custom hostname direct
```

### Destroying Containers
```bash
# All of these now use FeNix ubuntu-destroy:
destroy                 # System wrapper → ubuntu-destroy
ubuntu-destroy          # Direct FeNix command
```

### Accessing Containers
```bash
# Existing FeNix integration continues to work:
edc                     # Interactive container access
edc 1                   # Direct container access
```

## Migration Verification

To verify the migration was successful:

```bash
# Check wrapper redirection
start --help            # Should show FeNix ubuntu-start help
destroy --help          # Should show FeNix ubuntu-destroy help

# Check direct commands
ubuntu-start --help     # Should show FeNix help
ubuntu-destroy --help   # Should show FeNix help

# Check PATH integration
which ubuntu-start      # Should show fenix-dotfiles/bin path
which ubuntu-destroy    # Should show fenix-dotfiles/bin path
```

## Rollback Procedure

If rollback is needed, replace wrapper contents in `/usr/local/bin/start` and `/usr/local/bin/destroy` with the original ubuntu-vm functionality (preserved in the fallback sections of the current wrappers).

## Future Enhancements

- Consider adding more container types (kali, alpine, etc.)
- Enhance bootstrap script with user-specific customizations
- Add container networking and volume management features
- Integrate with FeNix multi-host synchronization capabilities

---

*Migration completed: 2025-07-31*  
*FeNix Container Management v2.0*