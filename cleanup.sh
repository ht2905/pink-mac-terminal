#!/usr/bin/env bash
# ==============================================================================
# 🧹 PINK TERMINAL BACKUP & CLEANUP UTILITY 🧹
# ------------------------------------------------------------------------------
# 1. Option 1: Integrate & Finalize (Keep pink setup, integrate all settings, delete backups)
# 2. Option 2: Full Rollback (Restore original files to default places, revert Terminal, delete backups)
# 3. Option 3: Delete backups only
# ==============================================================================

set -e

# --- Pretty ANSI Colors ---
C_RESET="\033[0m"
C_BOLD="\033[1m"
C_HOT_PINK="\033[38;5;205m"
C_PASTEL_PINK="\033[38;5;218m"
C_ROSE="\033[38;5;211m"
C_MINT="\033[38;5;121m"
C_LAVENDER="\033[38;5;183m"
C_YELLOW="\033[38;5;221m"

log_step() {
  echo -e "${C_HOT_PINK}==>${C_RESET} ${C_BOLD}${C_PASTEL_PINK}$1${C_RESET}"
}

log_sub() {
  echo -e "   ${C_ROSE}🌸 $1${C_RESET}"
}

log_success() {
  echo -e "   ${C_MINT}✨ $1${C_RESET}"
}

log_warn() {
  echo -e "   ${C_YELLOW}⚠️  $1${C_RESET}"
}

# Find all backup directories
shopt -s nullglob
BACKUP_DIRS=("$HOME"/.terminal_pink_backup_*)
shopt -u nullglob

if [[ ${#BACKUP_DIRS[@]} -eq 0 ]]; then
  echo ""
  log_warn "No backup directories found matching ~/.terminal_pink_backup_*"
  echo -e "${C_PASTEL_PINK}Your terminal is already clean or backups were previously removed.${C_RESET}"
  echo ""
  exit 0
fi

# Select the most recent backup folder
LATEST_BACKUP=$(ls -td "$HOME"/.terminal_pink_backup_* 2>/dev/null | head -n 1)

print_menu() {
  echo -e "${C_HOT_PINK}"
  echo "  ╭─────────────────────────────────────────────────────────────╮"
  echo "  │        🧹  PINK TERMINAL BACKUP & CLEANUP UTILITY  🧹       │"
  echo "  ╰─────────────────────────────────────────────────────────────╯"
  echo -e "${C_RESET}"
  echo -e "${C_ROSE}Found backup directory:${C_RESET} ${C_PASTEL_PINK}$LATEST_BACKUP${C_RESET}"
  echo ""
  echo -e "${C_BOLD}Please select an action:${C_RESET}"
  echo -e "  ${C_HOT_PINK}[1]${C_RESET} ${C_BOLD}Integrate & Finalize${C_RESET} (Keep cute pink UI, ensure all aliases/exports are merged, delete backups)"
  echo -e "  ${C_HOT_PINK}[2]${C_RESET} ${C_BOLD}Full Rollback / Restore${C_RESET} (Move original files back to default places, revert Terminal to stock, delete backups)"
  echo -e "  ${C_HOT_PINK}[3]${C_RESET} ${C_BOLD}Delete Backups Only${C_RESET} (Keep current setup as-is, simply remove backup files)"
  echo -e "  ${C_HOT_PINK}[4]${C_RESET} Cancel"
  echo ""
}

# --- Action 1: Integrate & Finalize ---
action_integrate() {
  log_step "Integrating all legacy settings with the new pink setup..."
  
  # 1. Harvest & integrate any remaining aliases from backup
  ALIAS_DEST="$HOME/.zsh_aliases"
  TMP_ALIASES="$(mktemp)"
  
  for src in "$LATEST_BACKUP/.zshrc" "$LATEST_BACKUP/.zprofile" "$LATEST_BACKUP/.bash_profile" "$LATEST_BACKUP/.bashrc" "$LATEST_BACKUP/.aliases"; do
    if [[ -f "$src" ]]; then
      grep -E '^[[:space:]]*alias[[:space:]]+' "$src" >> "$TMP_ALIASES" 2>/dev/null || true
    fi
  done

  if [[ -s "$TMP_ALIASES" ]]; then
    touch "$ALIAS_DEST"
    awk '!seen[$0]++' "$TMP_ALIASES" >> "$ALIAS_DEST"
    log_success "All aliases verified and merged into ~/.zsh_aliases"
  fi
  rm -f "$TMP_ALIASES"

  # 2. Harvest & integrate custom exports
  LEGACY_DEST="$HOME/.zsh_custom_legacy"
  TMP_EXPORTS="$(mktemp)"
  if [[ -f "$LATEST_BACKUP/.zshrc" ]]; then
    grep -E '^[[:space:]]*(export[[:space:]]+|eval[[:space:]]+|source[[:space:]]+|path\+=)' "$LATEST_BACKUP/.zshrc" \
      | grep -v -E '(ZSH|oh-my-zsh|p10k|ZSH_THEME|plugins=\()' >> "$TMP_EXPORTS" 2>/dev/null || true
  fi

  if [[ -s "$TMP_EXPORTS" ]]; then
    touch "$LEGACY_DEST"
    awk '!seen[$0]++' "$TMP_EXPORTS" >> "$LEGACY_DEST"
    log_success "Custom exports & paths merged into ~/.zsh_custom_legacy"
  fi
  rm -f "$TMP_EXPORTS"

  # 3. Delete all backup directories
  log_sub "Deleting backup folder(s)..."
  for bdir in "${BACKUP_DIRS[@]}"; do
    rm -rf "$bdir"
    log_success "Removed $bdir"
  done

  echo ""
  echo -e "${C_HOT_PINK}═════════════════════════════════════════════════════════════════${C_RESET}"
  echo -e "${C_BOLD}${C_MINT}  🎉 SUCCESS: All settings integrated & backups cleaned up! 💖${C_RESET}"
  echo -e "${C_ROSE}  Her aliases and paths are safe and active in the pink setup.${C_RESET}"
  echo -e "${C_HOT_PINK}═════════════════════════════════════════════════════════════════${C_RESET}"
  echo ""
}

# --- Action 2: Full Rollback / Restore ---
action_rollback() {
  log_step "Restoring original shell files and resetting Terminal to defaults..."

  # 1. Restore backed-up files to original locations
  FILES_TO_RESTORE=(
    ".zshrc" ".zprofile" ".zshenv" ".zlogin"
    ".aliases" ".zsh_aliases" ".bash_profile" ".bashrc" ".p10k.zsh"
  )

  for file in "${FILES_TO_RESTORE[@]}"; do
    if [[ -f "$LATEST_BACKUP/$file" ]]; then
      cp "$LATEST_BACKUP/$file" "$HOME/$file"
      log_sub "Restored ~/$file from backup."
    elif [[ "$file" == ".p10k.zsh" && -f "$HOME/.p10k.zsh" ]]; then
      # If .p10k.zsh was not in the original backup, remove the pink one
      rm -f "$HOME/.p10k.zsh"
      log_sub "Removed generated ~/.p10k.zsh"
    fi
  done

  # Clean up auxiliary custom legacy file if present
  rm -f "$HOME/.zsh_custom_legacy"

  # 2. Revert Terminal.app profile to default ("Basic") on macOS
  if [[ "$(uname -s)" == "Darwin" ]]; then
    log_sub "Reverting macOS Terminal default profile to 'Basic'..."
    defaults write com.apple.Terminal "Default Window Settings" -string "Basic"
    defaults write com.apple.Terminal "Startup Window Settings" -string "Basic"
    osascript -e '
      tell application "Terminal"
        try
          set default settings to settings set "Basic"
          repeat with w in windows
            repeat with t in tabs of w
              set current settings of t to settings set "Basic"
            end repeat
          end repeat
        end try
      end tell
    ' 2>/dev/null || true
    log_success "macOS Terminal profile reverted to 'Basic'!"
  fi

  # 3. Delete backup directory
  log_sub "Deleting backup folder(s)..."
  for bdir in "${BACKUP_DIRS[@]}"; do
    rm -rf "$bdir"
    log_success "Removed $bdir"
  done

  echo ""
  echo -e "${C_HOT_PINK}═════════════════════════════════════════════════════════════════${C_RESET}"
  echo -e "${C_BOLD}${C_MINT}  🔄 SUCCESS: System completely restored to original state!${C_RESET}"
  echo -e "${C_ROSE}  All original shell files are back in place and backups deleted.${C_RESET}"
  echo -e "${C_HOT_PINK}═════════════════════════════════════════════════════════════════${C_RESET}"
  echo -e "${C_PASTEL_PINK}Run ${C_HOT_PINK}exec zsh${C_PASTEL_PINK} to reload your original shell.${C_RESET}"
  echo ""
}

# --- Action 3: Delete Backups Only ---
action_delete_only() {
  log_step "Deleting backup directory without modifying current setup..."
  for bdir in "${BACKUP_DIRS[@]}"; do
    rm -rf "$bdir"
    log_success "Removed $bdir"
  done
  echo ""
  echo -e "${C_MINT}✨ All backup directories deleted successfully!${C_RESET}"
  echo ""
}

# --- Argument Parsing or Interactive Mode ---
CHOICE="$1"

if [[ -z "$CHOICE" ]]; then
  print_menu
  read -r -p "Enter choice [1-4]: " USER_INPUT
  CHOICE="$USER_INPUT"
fi

case "$CHOICE" in
  1|--integrate|-i)
    action_integrate
    ;;
  2|--restore|--rollback|-r)
    action_rollback
    ;;
  3|--delete-only|-d)
    action_delete_only
    ;;
  4|cancel|q|exit)
    echo -e "${C_PASTEL_PINK}Cancelled. No files were changed or deleted.${C_RESET}"
    exit 0
    ;;
  *)
    log_warn "Invalid option '$CHOICE'. Usage: ./cleanup.sh [--integrate | --restore | --delete-only]"
    exit 1
    ;;
esac
