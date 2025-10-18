# Enhanced Dotfiles Makefile
.PHONY: all install clean check-stow list help

# Configuration
DOTFILES_DIR := $(PWD)
STOW := $(shell which stow 2>/dev/null)

# Colors for output
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[1;33m
BLUE := \033[0;34m
NC := \033[0m # No Color

# Function to print colored output
define print_info
	@echo "$(BLUE)[INFO]$(NC) $(1)"
endef

define print_success
	@echo "$(GREEN)[SUCCESS]$(NC) $(1)"
endef

define print_warning
	@echo "$(YELLOW)[WARNING]$(NC) $(1)"
endef

define print_error
	@echo "$(RED)[ERROR]$(NC) $(1)"
endef

# Get all stow packages (directories and hidden directories with content)
PACKAGES := $(shell find $(DOTFILES_DIR) -maxdepth 1 -mindepth 1 -type d -not -name ".git" -exec basename {} \; | sort)

# Default target
all: install

# Check if stow is installed
check-stow:
	@if [ -z "$(STOW)" ]; then \
		echo "$(RED)[ERROR]$(NC) stow is not installed or not in PATH"; \
		echo "Please install stow first:"; \
		echo "  - On macOS: brew install stow"; \
		echo "  - On Ubuntu/Debian: sudo apt-get install stow"; \
		echo "  - On Arch: sudo pacman -S stow"; \
		exit 1; \
	fi
	$(call print_success,"stow is installed at: $(STOW)")

# List all packages that will be processed
list:
	@echo "$(BLUE)Dotfiles packages to be processed:$(NC)"
	@echo ""
	@if [ -n "$(PACKAGES)" ]; then \
		echo "$(YELLOW)All packages:$(NC)"; \
		for package in $(PACKAGES); do \
			echo "  • $$package"; \
		done; \
	fi
	@echo ""
	@echo "$(BLUE)Total: $(words $(PACKAGES)) packages$(NC)"

# Install (stow) dotfiles
install: check-stow
	$(call print_info,"Stowing dotfiles to $(HOME)...")
	@failed=0; \
	for package in $(PACKAGES); do \
		if [ -d "$(DOTFILES_DIR)/$$package" ]; then \
			echo "  → Stowing $$package..."; \
			if stow -v -R -t $(HOME) -d $(DOTFILES_DIR) $$package 2>/dev/null; then \
				echo "$(GREEN)    ✓ $$package stowed successfully$(NC)"; \
			else \
				echo "$(RED)    ✗ Failed to stow $$package$(NC)"; \
				failed=$$((failed + 1)); \
			fi; \
		fi; \
	done; \
	if [ $$failed -eq 0 ]; then \
		echo "$(GREEN)[SUCCESS]$(NC) All dotfiles stowed successfully!"; \
	else \
		echo "$(RED)[ERROR]$(NC) $$failed packages failed to stow. Please check the output above."; \
		exit 1; \
	fi

# Clean (unstow) dotfiles
clean: check-stow
	$(call print_info,"Unstowing dotfiles from $(HOME)...")
	@failed=0; \
	for package in $(PACKAGES); do \
		if [ -d "$(DOTFILES_DIR)/$$package" ]; then \
			echo "  → Unstowing $$package..."; \
			if stow -v -D -t $(HOME) -d $(DOTFILES_DIR) $$package 2>/dev/null; then \
				echo "$(GREEN)    ✓ $$package unstowed successfully$(NC)"; \
			else \
				echo "$(YELLOW)    ⚠ $$package was not stowed or already removed$(NC)"; \
			fi; \
		fi; \
	done; \
	echo "$(GREEN)[SUCCESS]$(NC) Cleanup completed!"


# Enhanced help target
help:
	@echo "$(BLUE)Enhanced Dotfiles Manager$(NC)"
	@echo "$(YELLOW)========================$(NC)"
	@echo ""
	@echo "$(GREEN)Usage:$(NC) make [target]"
	@echo ""
	@echo "$(GREEN)Available targets:$(NC)"
	@echo "  $(YELLOW)all$(NC)            - Install all dotfiles (default target)"
	@echo "  $(YELLOW)install$(NC)        - Stow all dotfiles to your home directory"
	@echo "  $(YELLOW)clean$(NC)          - Unstow all dotfiles from your home directory"
	@echo "  $(YELLOW)list$(NC)           - List all packages that will be processed"
	@echo "  $(YELLOW)check-stow$(NC)     - Verify that stow is installed"
	@echo "  $(YELLOW)help$(NC)           - Display this help message"
	@echo ""
	@echo "$(GREEN)Examples:$(NC)"
	@echo "  make install       # Install all dotfiles"
	@echo "  make clean         # Remove all symlinks"
	@echo "  make list          # See what will be processed"
	@echo "  make help          # Show this help message"
	@echo ""
	@echo "$(GREEN)Package types supported:$(NC)"
	@echo "  • Regular directories (alacritty, bash, nvim, etc.)"
	@echo "  • Hidden directories (.config, .ssh, etc.)"
	@echo "  • Hidden files (.gitconfig, .vimrc, etc.)"
	@echo ""
	@echo "$(YELLOW)Note:$(NC) This Makefile requires GNU stow to be installed."
