#!/usr/bin/env bash
# ==============================================================================
# ✨ ALL-IN-ONE PINK TERMINAL SETUP FOR MACOS ✨
# ------------------------------------------------------------------------------
# 1. Backs up all existing shell files (.zshrc, .zprofile, aliases, etc.)
# 2. Automatically preserves & migrates her existing aliases and custom exports
# 3. Resets Terminal.app settings to default
# 4. Installs MesloLGS NF (Nerd Font) for Powerlevel10k icons
# 5. Installs Oh My Zsh + Powerlevel10k + Pink-themed Plugins
# 6. Sets up your custom Powerlevel10k configuration (Pink As Hell Edition)
# 7. Imports & activates the "Pink Paradise" macOS Terminal theme
# ==============================================================================

set -e

# --- Pretty Pink ANSI Colors for Installer ---
C_RESET="\033[0m"
C_BOLD="\033[1m"
C_HOT_PINK="\033[38;5;205m"
C_PASTEL_PINK="\033[38;5;218m"
C_ROSE="\033[38;5;211m"
C_DEEP_PINK="\033[38;5;198m"
C_MINT="\033[38;5;121m"
C_LAVENDER="\033[38;5;183m"

print_banner() {
  echo -e "${C_HOT_PINK}"
  echo "  ╭─────────────────────────────────────────────────────────────╮"
  echo "  │   🌸 ✨  MACOS TERMINAL - PINK AS HELL SETUP  ✨ 🌸        │"
  echo "  │       Powerlevel10k + Nerd Fonts + Aesthetic Pink UI       │"
  echo "  ╰─────────────────────────────────────────────────────────────╯"
  echo -e "${C_RESET}"
}

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
  echo -e "   ${C_LAVENDER}⚠️  $1${C_RESET}"
}

# --- Check Operating System ---
if [[ "$(uname -s)" != "Darwin" ]]; then
  echo -e "${C_HOT_PINK}⚠️  Notice: This script is tailored for macOS.${C_RESET}"
  echo -e "Proceeding with shell & font setup, skipping macOS-only defaults."
  IS_MAC=false
else
  IS_MAC=true
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
BACKUP_DIR="$HOME/.terminal_pink_backup_${TIMESTAMP}"

print_banner

# ==============================================================================
# STEP 1: SAFETY BACKUP, AUTOMATED ALIAS PRESERVATION & TERMINAL RESET
# ==============================================================================
log_step "Step 1/5: Safety backup & automatic preservation of her settings..."

mkdir -p "$BACKUP_DIR"

# 1. Back up all potential existing shell configurations
FILES_TO_BACKUP=(
  ".zshrc" ".zprofile" ".zshenv" ".zlogin"
  ".aliases" ".zsh_aliases" ".bash_profile" ".bashrc" ".p10k.zsh"
)

for file in "${FILES_TO_BACKUP[@]}"; do
  if [[ -f "$HOME/$file" ]]; then
    cp "$HOME/$file" "$BACKUP_DIR/"
    log_sub "Backed up ~/$file to $BACKUP_DIR/"
  fi
done

# 2. Automated Alias Harvesting: Extract any inline aliases she had in old files
ALIAS_DEST="$HOME/.zsh_aliases"
TMP_ALIASES="$(mktemp)"

for src in "$BACKUP_DIR/.zshrc" "$BACKUP_DIR/.zprofile" "$BACKUP_DIR/.bash_profile" "$BACKUP_DIR/.bashrc"; do
  if [[ -f "$src" ]]; then
    grep -E '^[[:space:]]*alias[[:space:]]+' "$src" >> "$TMP_ALIASES" 2>/dev/null || true
  fi
done

if [[ -s "$TMP_ALIASES" ]]; then
  # Header if creating new ~/.zsh_aliases
  if [[ ! -f "$ALIAS_DEST" ]]; then
    echo "# ==============================================================================" > "$ALIAS_DEST"
    echo "# 🌸 PRESERVED USER ALIASES (Automatically Migrated) 🌸" >> "$ALIAS_DEST"
    echo "# ==============================================================================" >> "$ALIAS_DEST"
  fi
  # Append unique aliases only
  awk '!seen[$0]++' "$TMP_ALIASES" >> "$ALIAS_DEST"
  COUNT=$(grep -c '^[[:space:]]*alias' "$TMP_ALIASES" || true)
  log_success "Preserved $COUNT aliases automatically into ~/.zsh_aliases!"
else
  log_sub "No inline aliases found in old shell configs (or already in dedicated file)."
fi
rm -f "$TMP_ALIASES"

# 3. Automated Custom Exports Harvesting (PATHs, API keys, custom environment variables)
LEGACY_DEST="$HOME/.zsh_custom_legacy"
TMP_EXPORTS="$(mktemp)"

if [[ -f "$BACKUP_DIR/.zshrc" ]]; then
  # Extract custom non-boilerplate exports/eval lines (skipping Oh-My-Zsh & default boilerplate)
  grep -E '^[[:space:]]*(export[[:space:]]+|eval[[:space:]]+|source[[:space:]]+|path\+=)' "$BACKUP_DIR/.zshrc" \
    | grep -v -E '(ZSH|oh-my-zsh|p10k|ZSH_THEME|plugins=\()' >> "$TMP_EXPORTS" 2>/dev/null || true
fi

if [[ -s "$TMP_EXPORTS" ]]; then
  echo "# ==============================================================================" > "$LEGACY_DEST"
  echo "# 🌸 PRESERVED USER ENVIRONMENT & PATH SETTINGS 🌸" >> "$LEGACY_DEST"
  echo "# ==============================================================================" >> "$LEGACY_DEST"
  awk '!seen[$0]++' "$TMP_EXPORTS" >> "$LEGACY_DEST"
  log_success "Preserved custom PATHs & exports into ~/.zsh_custom_legacy!"
fi
rm -f "$TMP_EXPORTS"

# 4. Reset Terminal defaults on macOS
if [[ "$IS_MAC" == "true" ]]; then
  log_sub "Resetting Terminal.app preferences to factory defaults..."
  killall cfprefsd 2>/dev/null || true
  defaults delete com.apple.Terminal 2>/dev/null || true
  log_success "Terminal settings successfully reset to factory defaults!"
fi

# ==============================================================================
# STEP 2: INSTALL MESLOLGS NF FONTS (REQUIRED FOR P10K ICONS)
# ==============================================================================
log_step "Step 2/5: Installing MesloLGS NF (Nerd Fonts)..."

if [[ "$IS_MAC" == "true" ]]; then
  FONT_DIR="$HOME/Library/Fonts"
else
  FONT_DIR="$HOME/.local/share/fonts"
fi
mkdir -p "$FONT_DIR"

declare -a FONTS=(
  "MesloLGS NF Regular.ttf"
  "MesloLGS NF Bold.ttf"
  "MesloLGS NF Italic.ttf"
  "MesloLGS NF Bold Italic.ttf"
)

FONT_BASE_URL="https://github.com/romkatv/powerlevel10k-media/raw/master"

for font in "${FONTS[@]}"; do
  ENCODED_FONT="${font// /%20}"
  TARGET_PATH="$FONT_DIR/$font"
  if [[ ! -f "$TARGET_PATH" ]]; then
    log_sub "Downloading $font..."
    curl -fsSL "$FONT_BASE_URL/$ENCODED_FONT" -o "$TARGET_PATH"
  else
    log_sub "$font already present, skipping download."
  fi
done

if command -v fc-cache &>/dev/null; then
  fc-cache -f "$FONT_DIR" 2>/dev/null || true
fi
log_success "MesloLGS NF fonts installed into $FONT_DIR!"

# ==============================================================================
# STEP 3: INSTALL OH MY ZSH & PLUGINS
# ==============================================================================
log_step "Step 3/5: Installing Oh My Zsh and plugins..."

if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  log_sub "Installing Oh My Zsh (unattended)..."
  RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  log_success "Oh My Zsh installed!"
else
  log_sub "Oh My Zsh is already installed."
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# 1. Powerlevel10k theme
if [[ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]]; then
  log_sub "Cloning Powerlevel10k..."
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
else
  log_sub "Updating Powerlevel10k..."
  git -C "$ZSH_CUSTOM/themes/powerlevel10k" pull --ff-only 2>/dev/null || true
fi

# 2. zsh-autosuggestions
if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
  log_sub "Cloning zsh-autosuggestions..."
  git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

# 3. zsh-syntax-highlighting
if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]]; then
  log_sub "Cloning zsh-syntax-highlighting..."
  git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

log_success "Oh My Zsh, Powerlevel10k & plugins ready!"

# ==============================================================================
# STEP 4: CONFIGURE POWERLEVEL10K & .ZSHRC
# ==============================================================================
log_step "Step 4/5: Configuring Powerlevel10k (Pink Edition) and ~/.zshrc..."

# Copy .p10k.zsh
if [[ -f "$SCRIPT_DIR/.p10k.zsh" ]]; then
  cp "$SCRIPT_DIR/.p10k.zsh" "$HOME/.p10k.zsh"
  log_sub "Copied custom Pink .p10k.zsh to ~/.p10k.zsh"
fi

# Write pristine ~/.zshrc with all integrations
cat << 'EOF' > "$HOME/.zshrc"
# Enable Powerlevel10k instant prompt. Keep this near the top of ~/.zshrc.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# macOS Homebrew initialization (Apple Silicon & Intel)
if [[ -f /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -f /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set Powerlevel10k theme
ZSH_THEME="powerlevel10k/powerlevel10k"

# Standard Oh My Zsh settings
COMPLETION_WAITING_DOTS="true"
DISABLE_UNTRACKED_FILES_DIRTY="false"

# Plugins
plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# Load Powerlevel10k configuration
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# --- Pink Aesthetic Syntax & Suggestions Customization ---
# Cute soft pastel pink autosuggestions
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=218'

# Pink & Pastel syntax highlighting
typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[command]='fg=205,bold'            # Vibrant hot pink
ZSH_HIGHLIGHT_STYLES[builtin]='fg=212,bold'            # Pastel pink builtins
ZSH_HIGHLIGHT_STYLES[alias]='fg=219,bold'              # Lavender pink aliases
ZSH_HIGHLIGHT_STYLES[function]='fg=213,bold'           # Bubblegum pink functions
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=217'     # Soft rose flags
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=217'
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=225'   # Pale cotton candy strings
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=225'
ZSH_HIGHLIGHT_STYLES[back-quoted-argument]='fg=225'
ZSH_HIGHLIGHT_STYLES[path]='fg=211,underline'          # Pretty underline pink paths
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=197,bold'      # Ruby berry when misspelled

# --- User Aliases & Paths (Preserved & Loaded Automatically) ---
[[ -f ~/.zsh_aliases ]] && source ~/.zsh_aliases
[[ -f ~/.aliases ]] && source ~/.aliases
[[ -f ~/.config/zsh/aliases.zsh ]] && source ~/.config/zsh/aliases.zsh
[[ -f ~/.zsh_custom_legacy ]] && source ~/.zsh_custom_legacy

export PATH="$HOME/.local/bin:$PATH"

# --- Cute Pink Welcome Greeting ---
if [[ -o interactive ]]; then
  echo ""
  echo -e "\033[38;5;218m   /\\_/\\  \033[38;5;205m ✨ Welcome back, beautiful! ✨ \033[0m"
  echo -e "\033[38;5;218m  ( o.o ) \033[38;5;212m Everything is set and ready to glow! 🌸 \033[0m"
  echo -e "\033[38;5;218m   > ^ <  \033[38;5;219m Have a lovely coding day 💕 \033[0m"
  echo ""
fi
EOF

log_success "~/.zshrc and ~/.p10k.zsh configured!"

# ==============================================================================
# STEP 5: APPLY PINK THEME TO TERMINAL.APP
# ==============================================================================
log_step "Step 5/5: Setting up Terminal.app UI (Pink Paradise)..."

THEME_DIR="$HOME/.config/terminal-themes"
mkdir -p "$THEME_DIR"

if [[ -f "$SCRIPT_DIR/PinkParadise.terminal" ]]; then
  cp "$SCRIPT_DIR/PinkParadise.terminal" "$THEME_DIR/"
fi
if [[ -f "$SCRIPT_DIR/PastelSakura.terminal" ]]; then
  cp "$SCRIPT_DIR/PastelSakura.terminal" "$THEME_DIR/"
fi
if [[ -f "$SCRIPT_DIR/PinkParadise.itermcolors" ]]; then
  cp "$SCRIPT_DIR/PinkParadise.itermcolors" "$THEME_DIR/"
fi

if [[ "$IS_MAC" == "true" ]]; then
  log_sub "Importing Pink Paradise profile into Terminal.app..."
  
  # Import the .terminal profile
  open "$THEME_DIR/PinkParadise.terminal"
  sleep 1.5

  # Set Pink Paradise as default profile for new windows and startup
  defaults write com.apple.Terminal "Default Window Settings" -string "Pink Paradise"
  defaults write com.apple.Terminal "Startup Window Settings" -string "Pink Paradise"

  # AppleScript to set default and update active windows
  osascript -e '
    tell application "Terminal"
      try
        set default settings to settings set "Pink Paradise"
        repeat with w in windows
          repeat with t in tabs of w
            set current settings of t to settings set "Pink Paradise"
          end repeat
        end repeat
      end try
    end tell
  ' 2>/dev/null || true

  log_success "Pink Paradise is now the active & default Terminal profile!"
fi

echo ""
echo -e "${C_HOT_PINK}═════════════════════════════════════════════════════════════════${C_RESET}"
echo -e "${C_BOLD}${C_HOT_PINK}  🎉 ALL DONE! HER TERMINAL IS NOW PINK AS HELL! 💖${C_RESET}"
echo -e "${C_ROSE}  1. A full backup of her old files was saved to:${C_RESET} ${C_PASTEL_PINK}$BACKUP_DIR${C_RESET}"
echo -e "${C_ROSE}  2. Her aliases were auto-extracted & preserved in:${C_RESET} ${C_PASTEL_PINK}~/.zsh_aliases${C_RESET}"
echo -e "${C_ROSE}  3. MesloLGS NF Nerd Fonts installed directly to ~/Library/Fonts${C_RESET}"
echo -e "${C_ROSE}  4. Powerlevel10k + Pink Gradient theme configured (~/.p10k.zsh)${C_RESET}"
echo -e "${C_ROSE}  5. Pink Paradise Terminal profile activated!${C_RESET}"
echo -e "${C_HOT_PINK}═════════════════════════════════════════════════════════════════${C_RESET}"
echo -e "${C_PASTEL_PINK}To see the changes immediately, open a new Terminal window or run:${C_RESET}"
echo -e "${C_HOT_PINK}  exec zsh${C_RESET}"
echo ""
