# Ghostty — Claude Code / SAND setup

Ghostty configuration tuned for running Claude Code with native split panes,
following the **SAND** keybinding scheme (Split · Across · Navigate · Destroy)
from [@dani_avila7's article](https://x.com/dani_avila7/status/2023151176758268349),
adapted for Linux/i3.

This is an **additive** workflow that lives alongside the daily driver
(gnome-terminal) and the tmux config in [`../tmux/`](../tmux/tmux.conf). SAND uses
Ghostty-native splits as an alternative to multiplexer splits — pick whichever fits
the session. `ctrl+shift+*` (Ghostty) and the tmux `C-a` prefix do not collide.

## Install

The repo's `*.symlink` installer only targets `~/.<name>` paths, not XDG paths, so
this file is linked manually (same pattern as the tmux config):

```sh
mkdir -p ~/.config/ghostty
ln -s ~/dotfiles/ghostty/config ~/.config/ghostty/config
```

Validate the config parses:

```sh
ghostty +show-config --changes-only
```

> Note: Ghostty reads `~/.config/ghostty/config`. An older empty
> `~/.config/ghostty/config.ghostty` (if present) is not read by Ghostty and can be
> removed.

## SAND keymap

Modifier is `ctrl+shift` because i3 reserves `Super` (`Mod4`).

| Key | Action |
| --- | --- |
| **S — Split** | |
| `ctrl+shift+d` | split right |
| `ctrl+shift+enter` | split down |
| **A — Across (tabs)** | |
| `ctrl+shift+t` | new tab |
| `ctrl+shift+←` / `→` | previous / next tab |
| **N — Navigate (vim keys)** | |
| `ctrl+shift+h/j/k/l` | focus split left/down/up/right |
| `ctrl+shift+e` | equalize splits |
| `ctrl+shift+f` | toggle split zoom |
| **D — Destroy** | |
| `ctrl+shift+w` | close pane/surface |
| **Utility** | |
| `ctrl+shift+comma` | reload config |
| `ctrl+shift+p` | command palette (Ghostty default) |

## Typical Claude Code layout

Claude in the left pane, `lazygit` in a right split to watch diffs/commits live:

```
ctrl+shift+d          # split right
# run: lazygit
ctrl+shift+h          # focus back to Claude on the left
```

For multiple agents across git worktrees, split again (`ctrl+shift+enter`) and run
a second Claude Code instance in another worktree directory.
