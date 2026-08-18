#!/bin/bash

SHELL := /bin/bash
DOTFILES_ROOT := `pwd -P`

.PHONY: help dotfiles blesh

help:
	@echo ""
	@echo "Dotfiles"
	@echo "--------"
	@echo ""
	@echo "dotfiles - Installs dotfile symlinks."
	@echo "blesh    - Installs/updates ble.sh (bash autosuggestions + syntax highlighting) to ~/.local/share/blesh."
	@echo ""

dotfiles:
	@source "$(DOTFILES_ROOT)/install_helpers.sh" && symlink_dotfiles

blesh:
	curl -fsSL https://github.com/akinomyoga/ble.sh/releases/download/nightly/ble-nightly.tar.xz | tar xJ -C /tmp \
	&& bash /tmp/ble-nightly/ble.sh --install ~/.local/share \
	&& rm -rf /tmp/ble-nightly
