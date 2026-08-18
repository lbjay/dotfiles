# Dotfiles Repository Instructions

## Architecture Overview

This is a **symlink-based dotfiles manager** forked from [michaeltelford/dotfiles](https://github.com/michaeltelford/dotfiles). The core principle: configuration files are stored in this repo with `.symlink` extensions and automatically linked to `~/.{basename}` during installation.

**Key mechanism**: `install_helpers.sh::symlink_dotfiles()` finds all `*.symlink` files (max depth 2) and creates symbolic links in `$HOME` by stripping the `.symlink` extension.

Example: `bash/bashrc.symlink` → `~/.bashrc`

## Installation & Workflow

**Primary installation**: `make dotfiles` (or `./install.sh` for GitHub Codespaces)
- Runs `symlink_dotfiles()` with interactive prompts for conflicts
- Default behavior: backup existing files to `{file}.backup`
- Supports skip/overwrite modes via user prompts

**No full bootstrap**: This repo only handles dotfiles, not system packages or tools installation.

## File Organization Conventions

### Directory Structure Pattern
```
{category}/
  ├── {config_name}.symlink    # Symlinked to ~/.{config_name}
  └── ...
```

**Categories in use**:
- `bash/` - Bash configuration (7 symlinks: bashrc, bash_profile, aliases, exports, functions, etc.)
- `git/` - Git configuration (gitconfig, gitignore_global, gitattributes)
- `vim/` - Vim configuration (vimrc)
- `editor_config/` - EditorConfig settings
- `bin/` - Utility scripts (not symlinked, referenced via PATH in bashrc)
- `manual/` - Configs requiring manual setup (e.g., i3 window manager)

### Naming Convention
All symlinkable files MUST end with `.symlink` extension.

## Terminal Workflow

- Single gnome-terminal window with GNU screen session (`se` alias to start/resume) — the primary daily driver
- A second, parallel workflow uses Ghostty + tmux (`tm` alias; config at `~/.config/tmux/tmux.conf`, sourced from `tmux/tmux.conf`) for Claude Code work. It mirrors the screen key bindings for continuity (C-e prefix, matching the `se` alias's `screen -e^Ee` — not screen's C-a default); gnome-terminal + screen are left untouched. See `tmux-setup.md`.
- `set_prompt` in `bash/bashrc.symlink` embeds OSC 133 escape sequences (`\e]133;D/A/B\a` in PS1, `\e]133;C\a` in PS0) — these are semantic prompt marks consumed by tmux's `C-a O` last-output pager and Ghostty; do not remove them as noise.
- Almost black terminal background with simple color scheme
- Unlimited shell history for reference
- Editor: vim (planning to migrate to nvim)
- Multiple AWS profiles configured in `~/.aws/config`, switched via AWS_PROFILE env var

## Environment-Specific Patterns

### Bash Configuration Architecture
**Modular loading in `bashrc.symlink`**:
1. Sources function/alias/export files conditionally (`test -f ~/.bash_* && source`)
2. Supports local overrides via `~/.bash_local_specific` (not in repo)
3. Conditionally loads docker functions only if Docker is installed
4. Manages multiple version managers (pyenv, nodenv) with dedicated sections
5. Simple colored prompt (green for user, red for root, blue for path)
6. Unlimited history with append mode

### Python Environment Setup (pyenv-centric)
- `mkv` alias: Creates virtualenv named after current directory + sets `.python-version`
- Command: `pyenv virtualenv $(basename $(pwd)) && echo $(basename $(pwd)) > .python-version && pip install -U pip`
- Cleanup: `rmvirtualenv` alias deletes virtualenv and `.python-version` file

### AWS/Cloud Patterns
- Multiple AWS profiles via aliases: `aws-prod` → `aws --profile prod`
- ECR login shortcut: `ecr-login` uses hardcoded account ID `542186135646` for us-east-1

### Git Workflow Conventions (from gitconfig.symlink)
- `git br` - Shows branches sorted by commit date (most recent first)
- `git lg` - Pretty graph log with relative dates
- Force push uses `--force-with-lease` (safer alternative)
- Always rebases on pull (`autosetuprebase = always`)

## Key Utilities & Functions

### Bash Functions (bash_functions.symlink)
Run `bashfuncs` or `shellfuncs` in terminal to see all available functions with examples.

**Workflow helpers**:
- `refresh` - Fetches all remotes, checks out master/sit, pulls
- `loadenv [file]` - Exports .env file into current shell (defaults to `./.env`)
- `workon <project>` - CD to `~/projects/<project>` with bash completion
- `dbash <container_name>` - Quick docker exec into running container
- `findhere <pattern>` - Find files in current directory
- `search <pattern>` - Grep recursively in current directory
- `dir <name>` - Create directory and cd into it
- `zipit <dir>` - Zip a directory
- `sshi <host>` - SSH using ~/.ssh/id_rsa identity file
- `lports` - List all open ports and PIDs

### PATH Management
Order matters in bashrc.symlink:
1. `~/bin` (this repo's scripts)
2. `~/.local/bin`
3. `~/go/bin`
4. Version manager shims (pyenv, nodenv) - prepended via eval

## Editing Dotfiles

**To modify configurations**:
1. Edit the `.symlink` file in this repo
2. Changes take effect on next shell launch (for bash) or immediately if sourced
3. No need to re-run `make dotfiles` unless adding NEW symlink files

**Adding new dotfiles**:
1. Create `{category}/{name}.symlink` file
2. Run `make dotfiles` to create the symlink
3. Commit the new `.symlink` file to repo

## Testing & Validation

No automated tests exist. Manual verification:
```bash
finddot  # Lists all dotfile symlinks in $HOME to verify installation
```

## Notes for AI Agents

- **Don't suggest removing `.symlink` extensions** - they're essential to the installation mechanism
- **Personal context**: Hardcoded paths reference `/home/jluker/` (original user)
- **AWS account specifics**: us-east-1, account 542186135646 appear in aliases
- **GitHub Codespaces support**: `install.sh` is auto-detected and run by Codespaces
- **No secrets in repo**: Local-specific configs go in `~/.bash_local_specific` (not tracked)
