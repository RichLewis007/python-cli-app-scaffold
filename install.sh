#!/usr/bin/env bash

# file: install.sh
# Author: Rich Lewis - GitHub @RichLewis007
# Description: Install this CLI tool system-wide using uv

set -e  # Exit on error

# Configuration file for storing default installation mode
CONFIG_FILE="$HOME/.python_cli_scaffold_config"

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored messages
print_error() {
    echo -e "${RED}Error: $1${NC}" >&2
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ $1${NC}" >&2
}

# Function to check if uv is installed
check_uv() {
    if ! command -v uv &> /dev/null; then
        print_error "uv is not installed or not in PATH"
        echo "Please install uv first:"
        echo "  curl -LsSf https://astral.sh/uv/install.sh | sh"
        exit 1
    fi
    print_success "uv is installed"
}

# Function to ensure Python 3.14.2 is available
ensure_python() {
    print_info "Checking for Python 3.14.2..."
    
    # Check if Python 3.14.2 is installed
    if ! uv python find 3.14.2 &> /dev/null; then
        print_info "Python 3.14.2 not found. Installing..."
        uv python install 3.14.2
        print_success "Python 3.14.2 installed"
    else
        print_success "Python 3.14.2 is available"
    fi
}

# Function to read default installation mode from config file
read_default_mode() {
    if [ -f "$CONFIG_FILE" ]; then
        cat "$CONFIG_FILE"
    else
        echo ""
    fi
}

# Function to save default installation mode to config file
save_default_mode() {
    local mode=$1
    echo "$mode" > "$CONFIG_FILE"
    print_success "Default installation mode set to: $mode"
}

# Function to get installation mode
get_installation_mode() {
    local mode=""
    
    # Check for command line arguments
    case "$1" in
        --editable|-e)
            mode="editable"
            ;;
        --normal|-n)
            mode="normal"
            ;;
        --set-default)
            if [ -z "$2" ]; then
                print_error "--set-default requires a mode (editable or normal)"
                exit 1
            fi
            if [ "$2" != "editable" ] && [ "$2" != "normal" ]; then
                print_error "Mode must be 'editable' or 'normal'"
                exit 1
            fi
            save_default_mode "$2"
            exit 0
            ;;
        "")
            # No argument provided, check config file or prompt
            local default=$(read_default_mode)
            if [ -n "$default" ]; then
                print_info "Using saved default mode: $default"
                mode="$default"
            else
                # Prompt user - output to stderr so it's not captured by command substitution
                echo "" >&2
                echo "Installation mode:" >&2
                echo "  1) Editable (recommended for development) - changes reflect immediately" >&2
                echo "  2) Normal (production) - static installation" >&2
                echo "" >&2
                # Use printf instead of echo -n for better portability and explicit flushing
                printf "Choose mode [1=Editable, 2=Normal] (default: 1): " >&2
                read -r choice < /dev/tty
                case "${choice:-1}" in
                    1)
                        mode="editable"
                        ;;
                    2)
                        mode="normal"
                        ;;
                    *)
                        print_error "Invalid choice"
                        exit 1
                        ;;
                esac
            fi
            ;;
        *)
            print_error "Unknown option: $1"
            echo "Usage: $0 [--editable|-e|--normal|-n|--set-default <mode>]"
            exit 1
            ;;
    esac
    
    echo "$mode"
}

# Function to install the tool
install_tool() {
    local mode=$1
    
    print_info "Installing CLI tool in $mode mode..."
    
    cd "$SCRIPT_DIR"
    
    if [ "$mode" = "editable" ]; then
        # Editable install - creates a symlink
        uv tool install --editable .
    else
        # Normal install - copies the package
        uv tool install .
    fi
    
    print_success "Tool installed successfully"
}

# Function to update shell configuration for PATH
update_shell() {
    print_info "Updating shell configuration to ensure tool directory is in PATH..."
    
    # Run uv tool update-shell to add the tool directory to PATH
    if uv tool update-shell &> /dev/null; then
        print_success "Shell configuration updated"
        print_info "You may need to restart your terminal or run: source ~/.bashrc (or ~/.zshrc)"
    else
        print_info "Could not automatically update shell configuration"
        print_info "Make sure the tool directory is in your PATH:"
        echo "  $(uv tool dir --bin)"
    fi
}

# Function to get command name from pyproject.toml
get_command_name() {
    local pyproject_file="$SCRIPT_DIR/pyproject.toml"
    if [ -f "$pyproject_file" ]; then
        # Extract the command name from [project.scripts] section
        # Format: command_name = "package.module:app"
        grep -A 1 "^\[project.scripts\]" "$pyproject_file" | grep -v "^\[project.scripts\]" | head -1 | sed -E 's/^[[:space:]]*([^[:space:]]+)[[:space:]]*=.*/\1/'
    else
        echo "mycli"  # Fallback default
    fi
}

# Function to show installation summary
show_summary() {
    local mode=$1
    local cmd_name=$(get_command_name)
    
    echo ""
    print_success "Installation complete!"
    echo ""
    echo "Installation details:"
    echo "  Mode: $mode"
    echo "  Tool environment: $(uv tool dir)"
    echo "  Executable directory: $(uv tool dir --bin)"
    echo ""
    echo "The CLI tool should now be available in your PATH."
    echo "Try running: $cmd_name --help"
    echo ""
    
    if [ "$mode" = "editable" ]; then
        print_info "Editable mode: Changes to source code will be reflected immediately"
    else
        print_info "Normal mode: Reinstall to apply source code changes"
    fi
}

# Main execution
main() {
    echo "=========================================="
    echo "  CLI Tool Installation Script"
    echo "=========================================="
    echo ""
    
    # Check prerequisites
    check_uv
    ensure_python
    
    # Get installation mode
    INSTALL_MODE=$(get_installation_mode "$1" "$2")
    
    # Install the tool
    install_tool "$INSTALL_MODE"
    
    # Update shell configuration
    update_shell
    
    # Show summary
    show_summary "$INSTALL_MODE"
}

# Run main function
main "$@"
