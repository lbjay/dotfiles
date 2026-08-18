# tmux setup (parallel to GNU screen)

Reference notes for a tmux configuration that runs **alongside** a long-standing
`screen` setup, borrowing screen's ergonomics for continuity. This is not a
migration/cutover: gnome-terminal + screen remain the untouched daily driver;
tmux + Ghostty is an additive workflow dedicated to Claude Code work.

Companion file: `tmux/tmux.conf` (symlinked to `~/.config/tmux/tmux.conf`).

Verified against tmux 3.7b.

## Goal

Run tmux without disrupting comfortable screen muscle memory. The config keeps
`C-a` as the prefix and reproduces screen's `C-a C-a` last-window toggle;
nearly everything else is identical or one rebind away.

## Install

The generic dotfiles installer only links `*.symlink` files to `~/.{basename}`,
which cannot produce an XDG path, so the symlink is created manually:

```sh
mkdir -p ~/.config/tmux
ln -s ~/dotfiles/tmux/tmux.conf ~/.config/tmux/tmux.conf
```

The source file is intentionally named `tmux/tmux.conf` (no `.symlink` suffix)
so the generic installer skips it.

## Prefix and nesting

Keep `C-a` as the prefix so existing habits carry over:

```tmux
set -g prefix C-a
unbind C-b
bind a send-prefix        # C-a a  -> literal C-a to the app
bind C-a last-window      # C-a C-a -> toggle previous window
```

For nested sessions (local -> SSH -> remote tmux), tmux does not need a distinct
command character: pressing the prefix twice (`C-a C-a`) sends one literal prefix
to the inner layer. It stacks per level, so the inner layer is reached by
pressing `C-a` once per level then the key.

## Aliases

screen aliases are unchanged and remain the daily driver:

```sh
alias se='screen -e^Ee -S main -DR'
alias s='screen -DR'
```

tmux gets its own alias (`bash/bash_aliases.symlink`):

```sh
alias tm='tmux -u new-session -A -s main'
```

- `new-session -A -s main` attaches to `main` if present, else creates it
  (create-or-attach idempotency)
- `-u` forces UTF-8 (drop if the locale already sets it)

Note: `-A` shares the view if another client is attached; the screen
`-DR` detach-others behavior is intentionally not reproduced here.

## Ghostty + Claude Code

Ghostty reports `TERM=xterm-ghostty`. Truecolor inside tmux:

```tmux
set -g default-terminal "tmux-256color"
set -ag terminal-overrides ",xterm-ghostty:RGB"
```

Claude Code inside tmux needs three settings (official Claude Code docs) or
Shift+Enter submits instead of inserting a newline, and notifications/progress
never reach the outer terminal:

```tmux
set -g allow-passthrough on            # notifications + progress reach outer term
set -s extended-keys on                # distinguish Shift+Enter from Enter
set -as terminal-features 'xterm*:extkeys'
```

`set -sg escape-time 0` is also set to remove Esc-key latency.

Caveat: the `xterm-ghostty` terminfo entry must exist on the machine
(`infocmp xterm-ghostty`). Over SSH the remote host often lacks it; install it
there or fall back to `xterm-256color`.

## Window naming

Instead of the shell-driven title escape (screen's approach, still used by the
gnome-terminal/screen workflow via `bash/bashrc.symlink`), tmux uses native
automatic-rename:

```tmux
setw -g automatic-rename on
setw -g automatic-rename-format '#{pane_current_command}:#{b:pane_current_path}'
```

This yields names like `vim:dotfiles` — active command plus cwd basename,
auto-updating for long-running processes.

## Key mapping (screen -> tmux)

Identical, nothing to do: `c` new window, `n`/`p` next/prev, `0`-`9` select,
`d` detach, `[` copy mode, `]` paste, `?` help.

Different but native (adapt rather than rebind, to avoid clobbering tmux
defaults such as the split keys):

| screen    | tmux native | action              |
|-----------|-------------|---------------------|
| `C-a "`   | `prefix w`  | window list         |
| `C-a A`   | `prefix ,`  | rename window       |
| `C-a k`   | `prefix &`  | kill window         |
| `C-a '`   | `prefix '`  | select window index |
| `C-a Tab` | `prefix o`  | cycle panes         |

Splits (tmux panes are first-class): `prefix %` left/right, `prefix "`
top/bottom.

## Command-line invocation

| screen             | tmux                 |
|--------------------|----------------------|
| `screen -ls`       | `tmux ls`            |
| `screen -S foo`    | `tmux new -s foo`    |
| `screen -r foo`    | `tmux a -t foo`      |
| `screen -d -r foo` | `tmux a -d -t foo`   |
| `screen -x foo`    | `tmux a -t foo`      |

Shared attach differs: two tmux clients on one session share the current window
and tmux sizes to the smallest terminal. For independent current-window views
use a grouped session: `tmux new-session -t foo`, optionally with
`setw -g aggressive-resize on`.

## .screenrc directive mapping

| .screenrc                         | tmux                                          | Notes |
|-----------------------------------|-----------------------------------------------|-------|
| `setenv LC_CTYPE en_US.UTF-8`     | `set-environment -g LC_CTYPE en_US.UTF-8`     | Better set in shell profile. |
| `defutf8 on`                      | (none)                                        | Auto-detected since tmux 2.2; `tmux -u` forces. |
| `term xterm-256color`             | `set -g default-terminal "tmux-256color"`     | `tmux-256color` is the correct modern value. |
| `autodetach on`                   | (default)                                     | Server persists on hangup. |
| `crlf off`                        | (no meaningful equivalent)                    | Not carried over. |
| `deflogin off` / `defshell -/bin/bash` | (default: non-login)                     | See note below. |
| `hardcopy_append on`              | (no direct equivalent)                        | Not carried over. |
| `startup_message off`             | (default)                                     | No startup banner. |
| `vbell off`                       | `set -g visual-bell off`                      | Default off. |
| `defscrollback 10000`             | `set -g history-limit 10000`                  | |
| `silencewait 15`                  | (default: monitoring off)                     | Not carried over. |
| `termcapinfo ... hs/ts/fs/ds`     | `set -g set-titles on`                        | Native title-setting. |
| `defhstatus "$USER@%H | %n | %t"` | `set -g set-titles-string "#(whoami)@#H | #I | #W"` | `%`-escapes were degraded in the source file; reconstructed. |
| `hardstatus off`                  | (default)                                     | tmux has one status line. |
| `caption always " %m%d %c |  %w"` | `status-left`/window list                     | strftime works in status strings. |
| `activity`/`bell`/`vbell_msg`     | (flags only)                                  | tmux exposes only on/off/both; no message strings. |

## Decisions carried from the original notes

1. **Login shell.** The source `.screenrc` is internally inconsistent
   (`deflogin off` vs `defshell -/bin/bash`). tmux windows are left as
   non-login: tmux inherits the already-initialized login environment from the
   shell that launched it, and `.bash_profile` only sources `.bashrc`, so
   aliases/functions still load. `default-command` is therefore not set.

2. **The `~` rebind is dropped.** `prefix ~` is tmux's built-in `show-messages`
   log. The screen `bind ~` only reset a vestigial activity message string, so
   `prefix ~` is left at its default.

3. **Not carried over, by design:** custom `activity`/`bell`/`vbell_msg` text
   (tmux exposes only flags), `hardcopy_append`, `crlf`, and activity/silence
   monitoring (off by default) — none have faithful analogs.

## Validation

Parse-check the config without a live attach:

```sh
tmux -f tmux/tmux.conf new-session -d -s smoke && tmux kill-session -t smoke
```

Clean exit means it parses.
