#!/bin/bash
#
# Helper methods for the install scripts.
#
# Much of the functionality in this file has been taken from:
# https://github.com/holman/dotfiles/blob/master/script/bootstrap
#

set -e

export DOTFILES_ROOT=$(pwd -P)

info() {
  printf "\r  [ \033[00;34m..\033[0m ] $1\n"
}

user() {
  printf "\r  [ \033[0;33m??\033[0m ] $1\n"
}

success() {
  printf "\r\033[2K  [ \033[00;32mOK\033[0m ] $1\n"
}

fail() {
  printf "\r\033[2K  [\033[0;31mFAIL\033[0m] $1\n"
  echo ''
  exit 1
}

link_file() {
  local src=$1 dst=$2

  local overwrite= backup= skip=
  local action=

  if [ -f "$dst" -o -d "$dst" -o -L "$dst" ]; then

    if [ "$overwrite_all" == "false" ] && [ "$backup_all" == "false" ] && [ "$skip_all" == "false" ]; then

      local currentSrc="$(readlink $dst)"

      if [ "$currentSrc" == "$src" ]; then

        skip=true

      else

        user "File already exists: $dst ($(basename "$src")), what do you want to do?\n\
        [s]kip, [S]kip all, [o]verwrite, [O]verwrite all, [b]ackup, [B]ackup all?"
        read -n 1 action

        case "$action" in
        o)
          overwrite=true
          ;;
        O)
          overwrite_all=true
          ;;
        b)
          backup=true
          ;;
        B)
          backup_all=true
          ;;
        s)
          skip=true
          ;;
        S)
          skip_all=true
          ;;
        *) ;;

        esac

      fi

    fi

    overwrite=${overwrite:-$overwrite_all}
    backup=${backup:-$backup_all}
    skip=${skip:-$skip_all}

    if [ "$overwrite" == "true" ]; then
      rm -rf "$dst"
      success "Removed $dst"
    fi

    if [ "$backup" == "true" ]; then
      # Only backup if the $dst file isn't a symlink.
      if [ -L "$dst" ]; then
        rm -f "$dst"
      else
        mv "$dst" "${dst}.backup"
        success "Moved $dst to ${dst}.backup"
      fi
    fi

    if [ "$skip" == "true" ]; then
      success "Skipped $src"
    fi
  fi

  if [ "$skip" != "true" ]; then # "false" or empty
    ln -s "$1" "$2"
    success "Sym linked $1 to $2"
  fi
}

setup_nvim() {
  info "Setting up nvim configuration..."

  local nvim_config_dir="$HOME/.config/nvim"
  local init_vim="$nvim_config_dir/init.vim"
  local vimrc_src="$DOTFILES_ROOT/vim/vimrc.symlink"

  # Create nvim config directory if it doesn't exist
  if [ ! -d "$nvim_config_dir" ]; then
    mkdir -p "$nvim_config_dir"
    success "Created $nvim_config_dir"
  fi

  # Link init.vim to vimrc.symlink
  if [ -L "$init_vim" ]; then
    local currentSrc="$(readlink $init_vim)"
    if [ "$currentSrc" == "$vimrc_src" ]; then
      success "nvim init.vim already linked correctly"
      return
    fi
  fi

  if [ -f "$init_vim" ] && [ ! -L "$init_vim" ]; then
    mv "$init_vim" "${init_vim}.backup"
    success "Backed up existing init.vim"
  fi

  ln -sf "$vimrc_src" "$init_vim"
  success "Linked nvim init.vim to vimrc.symlink"
}

symlink_dotfiles() {
  info "Symlinking dotfiles..."

  local overwrite_all=false backup_all=true skip_all=false

  for src in $(find -H "$DOTFILES_ROOT" -maxdepth 2 -name '*.symlink' -not -path '*.git*'); do
    dst="$HOME/.$(basename "${src%.*}")"
    link_file "$src" "$dst"
  done

  success "Symlinking dotfiles complete"

  # Setup nvim configuration
  setup_nvim
}
