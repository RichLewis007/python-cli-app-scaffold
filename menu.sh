#!/usr/bin/env bash

# file: menu.sh
# Author: Rich Lewis - GitHub @RichLewis007

set -e  # Exit on error

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ------------------------------------------------------------
# Colors (from bash-ui.sh)
# ------------------------------------------------------------
COLOR_RED="\033[31m"
COLOR_GREEN="\033[32m"
COLOR_YELLOW="\033[33m"
COLOR_BLUE="\033[34m"
COLOR_MAGENTA="\033[35m"
COLOR_CYAN="\033[36m"
COLOR_BOLD="\033[1m"
COLOR_DIM="\033[2m"
COLOR_RESET="\033[0m"

# ------------------------------------------------------------
# Logging helpers (from bash-ui.sh)
# ------------------------------------------------------------
log_info() {
  printf "%b[INFO]%b %s\n" \
    "${COLOR_BLUE}${COLOR_BOLD}" "${COLOR_RESET}" "$*"
}

log_ok() {
  printf "%b[ OK ]%b %s\n" \
    "${COLOR_GREEN}${COLOR_BOLD}" "${COLOR_RESET}" "$*"
}

log_warn() {
  printf "%b[WARN]%b %s\n" \
    "${COLOR_YELLOW}${COLOR_BOLD}" "${COLOR_RESET}" "$*"
}

log_error() {
  printf "%b[ERROR]%b %s\n" \
    "${COLOR_RED}${COLOR_BOLD}" "${COLOR_RESET}" "$*"
}

# ------------------------------------------------------------
# Confirmation helper (from bash-ui.sh)
# ------------------------------------------------------------
confirm() {
  local prompt="${1:-Are you sure?} [y/N] "
  local reply
  printf "%s" "$prompt"
  read -r reply
  case "$reply" in
    y|Y|yes|YES) return 0 ;;
    *)           return 1 ;;
  esac
}

# ------------------------------------------------------------
# Command detection helpers (from bash-ui.sh)
# ------------------------------------------------------------
_ui_have_cmd() {
  command -v "$1" >/dev/null 2>&1
}

_ui_have_gum() { _ui_have_cmd gum; }
_ui_have_fzf() { _ui_have_cmd fzf; }

# ------------------------------------------------------------
# gum and fzf menus (from bash-ui.sh)
# ------------------------------------------------------------
_ui_menu_gum() {
  local header="$1"; shift
  local prompt_line="$1"; shift
  local options=("$@")

  local combined_header
  if [[ -n "$prompt_line" && "$prompt_line" != "$header" ]]; then
    combined_header="${header}\n${prompt_line}"
  else
    combined_header="$header"
  fi

  # Use -- so options starting with "-" are not treated as flags
  gum choose --header "$combined_header" -- "${options[@]}"
}

_ui_menu_fzf() {
  local header="$1"; shift
  local prompt_line="$1"; shift
  local options=("$@")

  local fzf_header="$header"
  local fzf_prompt="$prompt_line"
  if [[ -z "$fzf_prompt" ]]; then
    fzf_prompt="$fzf_header"
  fi

  printf "%s\n" "${options[@]}" | fzf \
    --header="$fzf_header" \
    --prompt="${fzf_prompt} " \
    --height=100% \
    --border \
    --reverse \
    --info=hidden
}

# ------------------------------------------------------------
# Basic numbered menu (fallback) (from bash-ui.sh)
# ------------------------------------------------------------
menu_basic() {
  local prompt="$1"; shift
  local options=("$@")
  local count=${#options[@]}
  local i choice
  local border="============================================================"

  if (( count == 0 )); then
    log_error "menu_basic called with no options"
    return 1
  fi

  while true; do
    printf "\n%s\n" "$border"
    # Print prompt with newlines (prompt may contain actual newlines)
    printf "%b" "$COLOR_BOLD"
    printf "%b" "$prompt"
    printf "%b\n" "$COLOR_RESET"
    printf "%s\n" "$border"
    for i in "${!options[@]}"; do
      printf "  %b%2d)%b %s\n" "$COLOR_CYAN" "$((i+1))" "$COLOR_RESET" "${options[$i]}"
    done
    printf "  %b q)%b Quit\n" "$COLOR_RED" "$COLOR_RESET"
    printf "%s\n" "$border"

    printf "\nChoose: "
    if ! read -r choice; then
      log_warn "EOF on input, exiting menu."
      return 1
    fi

    case "$choice" in
      q|Q) return 1 ;;
      ''|*[!0-9]*) log_warn "Please enter a number or q."; continue ;;
    esac

    if (( choice >= 1 && choice <= count )); then
      REPLY=$((choice-1))
      return 0
    else
      log_warn "Invalid choice."
    fi
  done
}

# ------------------------------------------------------------
# Option picker (from bash-ui.sh)
# Uses fzf, then gum, then basic numbered menu
# ------------------------------------------------------------
pick_option() {
  local prompt="$1"; shift
  local options=("$@")
  local choice

  if (( ${#options[@]} == 0 )); then
    log_error "pick_option called with no options"
    return 1
  fi

  # Split into header and prompt_line on first newline
  local header prompt_line
  header="${prompt%%$'\n'*}"
  if [[ "$prompt" == *$'\n'* ]]; then
    prompt_line="${prompt#*$'\n'}"
  else
    prompt_line="$prompt"
  fi

  # Prefer fzf for fuzzy type-to-search menus
  if _ui_have_fzf; then
    choice=$(_ui_menu_fzf "$header" "$prompt_line" "${options[@]}") || return 1
    printf "%s\n" "$choice"
    return 0
  fi

  # Fallback to gum if available (arrow navigation, no fuzzy search)
  if _ui_have_gum; then
    choice=$(_ui_menu_gum "$header" "$prompt_line" "${options[@]}") || return 1
    printf "%s\n" "$choice"
    return 0
  fi

  # Finally, basic numbered menu with border
  if menu_basic "$prompt" "${options[@]}"; then
    printf "%s\n" "${options[$REPLY]}"
    return 0
  else
    return 1
  fi
}

# ------------------------------------------------------------
# Hardcoded menu targets and descriptions
# ------------------------------------------------------------
# Array of menu targets
_MAKE_TARGETS=(
  "help"
  "install"
  "install-editable"
  "sync"
  "test"
  "test-cov"
  "lint"
  "lint-fix"
  "type-check"
  "format"
  "check"
  "clean"
  "quit"
)

# Array of menu descriptions (matching order of targets)
_MAKE_DESCRIPTIONS=(
  "Show this help message"
  "Install the CLI tool (normal mode)"
  "Install the CLI tool (editable mode)"
  "Sync dependencies with uv"
  "Run tests"
  "Run tests with coverage"
  "Run linting with ruff"
  "Fix linting issues with ruff"
  "Run type checking with mypy"
  "Format code with ruff"
  "Run all checks (lint, type-check, test)"
  "Clean up generated files"
  "Exit the menu"
)

# ------------------------------------------------------------
# Execute a target command
# ------------------------------------------------------------
execute_target() {
  local target="$1"
  
  # Handle quit specially
  if [[ "$target" == "quit" ]]; then
    log_info "Exiting menu."
    exit 0
  fi
  
  cd "$SCRIPT_DIR"
  
  case "$target" in
    help)
      echo "Available commands:"
      local i
      for i in "${!_MAKE_TARGETS[@]}"; do
        printf "  \033[36m%-20s\033[0m %s\n" "${_MAKE_TARGETS[$i]}" "${_MAKE_DESCRIPTIONS[$i]}"
      done
      ;;
    install)
      ./install.sh --normal
      ;;
    install-editable)
      ./install.sh --editable
      ;;
    sync)
      uv sync
      ;;
    test)
      uv run pytest
      ;;
    test-cov)
      uv run pytest --cov
      ;;
    lint)
      uv run ruff check .
      ;;
    lint-fix)
      uv run ruff check --fix .
      ;;
    type-check)
      uv run mypy src/
      ;;
    format)
      uv run ruff format .
      ;;
    check)
      uv run ruff check .
      uv run mypy src/
      uv run pytest
      ;;
    clean)
      rm -rf .venv
      rm -rf dist/
      rm -rf build/
      rm -rf *.egg-info
      find . -type d -name __pycache__ -exec rm -r {} + 2>/dev/null || true
      find . -type f -name "*.pyc" -delete
      ;;
    *)
      log_error "Unknown target: $target"
      return 1
      ;;
  esac
}

# ------------------------------------------------------------
# Build menu options with two-column format (target + description)
# ------------------------------------------------------------
build_menu_options() {
  local targets=("${_MAKE_TARGETS[@]}")
  local descriptions=("${_MAKE_DESCRIPTIONS[@]}")
  local options=()
  local i
  
  # Find max target length for column alignment
  local max_target_len=0
  for target in "${targets[@]}"; do
    if [ ${#target} -gt $max_target_len ]; then
      max_target_len=${#target}
    fi
  done
  
  # Add padding (at least 20 chars, but more if needed)
  if [ $max_target_len -lt 20 ]; then
    max_target_len=20
  else
    max_target_len=$((max_target_len + 4))
  fi
  
  # Build formatted options array
  for i in "${!targets[@]}"; do
    local target="${targets[$i]}"
    local desc="${descriptions[$i]}"
    # Format as "target    description" with proper spacing
    local formatted=$(printf "%-${max_target_len}s %s" "$target" "$desc")
    options+=("$formatted")
  done
  
  printf "%s\n" "${options[@]}"
}

# ------------------------------------------------------------
# Extract target name from selected menu option
# ------------------------------------------------------------
extract_target_from_option() {
  local selected="$1"
  local targets=("${_MAKE_TARGETS[@]}")
  local i
  
  # The selected option is formatted as "target    description"
  # Match against known targets (handles targets with hyphens like "install-editable")
  for i in "${!targets[@]}"; do
    local target="${targets[$i]}"
    # Check if the selected option starts with this target followed by whitespace
    # This handles both exact matches and formatted strings
    if [[ "$selected" =~ ^"$target"[[:space:]] ]]; then
      printf "%s\n" "$target"
      return 0
    fi
    # Also check for exact match (in case formatting is different)
    if [[ "$selected" == "$target" ]]; then
      printf "%s\n" "$target"
      return 0
    fi
  done
  
  # Fallback: try to extract first word (may not work for hyphenated targets)
  printf "%s\n" "${selected%%[[:space:]]*}"
}

# ------------------------------------------------------------
# Main execution
# ------------------------------------------------------------
main() {
  if [ ${#_MAKE_TARGETS[@]} -eq 0 ]; then
    log_error "No targets defined"
    exit 1
  fi
  
  # Build menu options array
  local menu_options
  mapfile -t menu_options < <(build_menu_options)
  
  while true; do
    local selected_option
    local prompt="Project Menu
Select a command to execute:"
    
    # Use pick_option which will try fzf, then gum, then fallback to numbered menu
    selected_option=$(pick_option "$prompt" "${menu_options[@]}") || {
      log_info "Menu cancelled."
      exit 0
    }
    
    # Extract target name from the selected option
    local selected_target
    selected_target=$(extract_target_from_option "$selected_option")
    
    # Find the description for this target
    local selected_desc=""
    local i
    for i in "${!_MAKE_TARGETS[@]}"; do
      if [[ "${_MAKE_TARGETS[$i]}" == "$selected_target" ]]; then
        selected_desc="${_MAKE_DESCRIPTIONS[$i]}"
        break
      fi
    done
    
    printf "\n"
    log_info "Executing: $selected_target"
    log_info "Description: $selected_desc"
    printf "\n"
    
    execute_target "$selected_target"
    local status=$?
    
    printf "\n"
    if [ $status -eq 0 ]; then
      log_ok "Command completed successfully"
    else
      log_error "Command failed with exit code $status"
    fi
    
    printf "\n"
    printf "Press ENTER to continue..."
    read -r
  done
}

# Run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
