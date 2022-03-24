#!/bin/bash

SHELL := /bin/bash
DOTFILES_ROOT := `pwd -P`

.PHONY: help dotfiles

help:
	@echo ""
	@echo "Dotfiles"
	@echo "--------"
	@echo ""
	@echo "dotfiles - Installs dotfile symlinks."
	@echo ""

dotfiles:
	@source "$(DOTFILES_ROOT)/install_helpers.sh" && symlink_dotfiles
