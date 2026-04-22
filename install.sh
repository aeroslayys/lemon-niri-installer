#!/bin/bash

# --- Configuration ---
REPO_URL="https://github.com/aeroslayys/lemon-niri-installer"
WALLPAPER_URL="https://github.com/JaKooLit/Wallpaper-Bank"
DOTFILES_DIR="$HOME/lemon-niri-installer"
WALLPAPER_DIR="$HOME/Pictures/Wallpaper-Bank"
BACKUP_DIR="$HOME/dotfiles_backup_$(date +%Y%m%d_%H%M%S)"
FLAVOR_FILE="$HOME/.config/lemon-niri/flavor"

# Colors
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
MAGENTA='\033[0;35m'
RED='\033[0;31m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

# --- Dry Run Logic ---
DRY_RUN=false
[[ "$1" == "--dry-run" ]] && DRY_RUN=true && echo -e "${MAGENTA}--- DRY RUN MODE ENABLED ---${NC}\n"

run_cmd() {
    if [ "$DRY_RUN" = true ]; then
        echo -e "${MAGENTA}[DRY-RUN] Executing:${NC} $*"
    else
        "$@"
    fi
}

# --- 1. Distro Detection ---
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
    OS_LIKE=$ID_LIKE
else
    OS="unknown"
fi

# ─────────────────────────────────────────────
# RADIO MENU  (single select, j/k or arrows)
# Sets global: RADIO_RESULT
# ─────────────────────────────────────────────
radio_menu() {
    local title="$1"
    local subtitle="$2"
    shift 2
    local items=("$@")
    local count=$(( ${#items[@]} / 2 ))
    local cursor=0

    while true; do
        clear
        echo -e "${BOLD}${CYAN}  $title${NC}"
        echo -e "${DIM}  $subtitle${NC}"
        echo
        for (( i=0; i<count; i++ )); do
            local tag="${items[$((i*2))]}"
            local desc="${items[$((i*2+1))]}"
            if [ "$i" -eq "$cursor" ]; then
                echo -e "  ${YELLOW}${BOLD}▶  $tag${NC}  ${DIM}$desc${NC}"
            else
                echo -e "     $tag  ${DIM}$desc${NC}"
            fi
        done
        echo
        echo -e "${DIM}  [j/k or ↑↓] Move   [ENTER] Confirm   [e] Exit${NC}"

        IFS= read -rsn1 key </dev/tty
        if [[ "$key" == $'\x1b' ]]; then
            read -rsn2 -t 0.1 key2 </dev/tty
            key="$key$key2"
        fi

        case "$key" in
            'k'|$'\x1b[A') (( cursor > 0 )) && (( cursor-- )) ;;
            'j'|$'\x1b[B') (( cursor < count-1 )) && (( cursor++ )) ;;
            '')
                RADIO_RESULT="${items[$((cursor*2))]}"
                return 0
                ;;
            'e'|'E')
                echo -e "\n${RED}Installer cancelled.${NC}"
                exit 1
                ;;
        esac
    done
}

# ─────────────────────────────────────────────
# CHECKLIST MENU  (multi select, space to toggle)
# Sets global: CHECK_RESULT
# ─────────────────────────────────────────────
check_menu() {
    local title="$1"
    local subtitle="$2"
    shift 2
    local items=("$@")
    local count=$(( ${#items[@]} / 3 ))
    local cursor=0
    local selected=()

    for (( i=0; i<count; i++ )); do
        [[ "${items[$((i*3+2))]}" == "ON" ]] && selected[$i]=1 || selected[$i]=0
    done

    while true; do
        clear
        echo -e "${BOLD}${CYAN}  $title${NC}"
        echo -e "${DIM}  $subtitle${NC}"
        echo
        for (( i=0; i<count; i++ )); do
            local tag="${items[$((i*3))]}"
            local desc="${items[$((i*3+1))]}"
            local check=" "
            [[ "${selected[$i]}" -eq 1 ]] && check="${GREEN}✓${NC}"

            if [ "$i" -eq "$cursor" ]; then
                echo -e "  ${YELLOW}${BOLD}▶ [${check}${YELLOW}${BOLD}] $tag${NC}  ${DIM}$desc${NC}"
            else
                echo -e "    [${check}] $tag  ${DIM}$desc${NC}"
            fi
        done
        echo
        echo -e "${DIM}  [j/k or ↑↓] Move   [SPACE] Toggle   [ENTER] Confirm   [e] Exit${NC}"

        IFS= read -rsn1 key </dev/tty
        if [[ "$key" == $'\x1b' ]]; then
            read -rsn2 -t 0.1 key2 </dev/tty
            key="$key$key2"
        fi

        case "$key" in
            'k'|$'\x1b[A') (( cursor > 0 )) && (( cursor-- )) ;;
            'j'|$'\x1b[B') (( cursor < count-1 )) && (( cursor++ )) ;;
            ' ')
                [[ "${selected[$cursor]}" -eq 1 ]] && selected[$cursor]=0 || selected[$cursor]=1
                ;;
            '')
                CHECK_RESULT=""
                for (( i=0; i<count; i++ )); do
                    [[ "${selected[$i]}" -eq 1 ]] && CHECK_RESULT+="${items[$((i*3))]} "
                done
                CHECK_RESULT="${CHECK_RESULT% }"
                return 0
                ;;
            'e'|'E')
                echo -e "\n${RED}Installer cancelled.${NC}"
                exit 1
                ;;
        esac
    done
}

# ─────────────────────────────────────────────
# SYMLINK HELPER
# Creates a symlink, backing up any existing file/dir first
# Usage: make_link <source> <target>
# ─────────────────────────────────────────────
make_link() {
    local src="$1"
    local dst="$2"

    # Source must exist
    if [ ! -e "$src" ]; then
        echo -e "${YELLOW}  Skipping $dst — source not found: $src${NC}"
        return
    fi

    if [ "$DRY_RUN" = true ]; then
        echo -e "${MAGENTA}[DRY-RUN] ln -sf $src → $dst${NC}"
        return
    fi

    # Backup if something already exists at destination (and isn't already our symlink)
    if [ -e "$dst" ] || [ -L "$dst" ]; then
        if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
            echo -e "${DIM}  Already linked: $dst${NC}"
            return
        fi
        mkdir -p "$BACKUP_DIR"
        mv "$dst" "$BACKUP_DIR/$(basename "$dst").bak"
        echo -e "${DIM}  Backed up existing $(basename "$dst")${NC}"
    fi

    # Ensure parent dir exists
    mkdir -p "$(dirname "$dst")"
    ln -sf "$src" "$dst"
    echo -e "${GREEN}  ✓ Linked: $dst → $src${NC}"
}

# --- 2. Ensure base deps ---
if ! command -v git &>/dev/null || ! command -v curl &>/dev/null; then
    echo -e "${CYAN}Bootstrapping requirements for $OS...${NC}"
    case $OS in
        fedora)        run_cmd sudo dnf install -y git curl ;;
        arch)          run_cmd sudo pacman -S --needed --noconfirm git curl ;;
        ubuntu|debian) run_cmd sudo apt update && run_cmd sudo apt install -y git curl build-essential ;;
    esac
fi

# --- 3. Flavor Selection ---
radio_menu \
    "Pick Your Flavor" \
    "Choose the primary theme color:" \
    "Lemon" "Classic Yellow" \
    "Lime"  "Fresh Green" \
    "Blue"  "Blue Lemonade"

FLAVOR="$RADIO_RESULT"
clear
echo -e "${CYAN}Flavor selected: ${YELLOW}$FLAVOR${NC}"

case "$FLAVOR" in
    Lemon) ACTIVE_HEX="#FFED29"; LOGO="lemon.png";      FF_COLOR="yellow"; FG="white"; BG="yellow"; SELECTED_FLAVOR="Lemon" ;;
    Lime)  ACTIVE_HEX="#32CD32"; LOGO="green1.png";     FF_COLOR="green";  FG="white"; BG="green";  SELECTED_FLAVOR="Lime"  ;;
    Blue)  ACTIVE_HEX="#00B4D8"; LOGO="blue-lemon.png"; FF_COLOR="blue";   FG="white"; BG="blue";   SELECTED_FLAVOR="Blue"  ;;
esac

# --- 4. Component Selection ---
check_menu \
    "Lemon Niri Installer" \
    "Select components to install:" \
    "Niri"       "Compositor (Window Manager)"  ON  \
    "Noctalia"   "Status Bar/Shell"             ON  \
    "Bibata"     "Modern Ice Cursor"            ON  \
    "Tools"      "Fuzzel, Alacritty, Fastfetch" ON  \
    "Zsh"        "Zsh + Oh My Zsh Environment"  ON  \
    "Wallpapers" "JaKooLit Wallpaper Bank"      OFF \
    "Symlinks"   "Apply Configs & Theming"      ON

CHOICES="$CHECK_RESULT"
clear

# --- 5. Package Installation ---

# Niri
if [[ $CHOICES == *"Niri"* ]]; then
    echo -e "${CYAN}Installing Niri...${NC}"
    case $OS in
        fedora)
            run_cmd sudo dnf copr enable -y yalter/niri-git
            run_cmd sudo dnf install -y niri
            ;;
        arch)
            [[ -z "$AUR_HELPER" ]] && AUR_HELPER=$(command -v yay || command -v paru)
            run_cmd $AUR_HELPER -S --needed --noconfirm niri-git
            ;;
        ubuntu|debian)
            echo -e "${YELLOW}Installing Niri via Cargo for Debian/Ubuntu...${NC}"
            run_cmd sudo apt install -y cargo libwayland-dev libgbm-dev libinput-dev
            run_cmd cargo install --locked niri
            ;;
    esac
fi

# Noctalia
if [[ $CHOICES == *"Noctalia"* ]]; then
    echo -e "${CYAN}Installing Noctalia...${NC}"
    case $OS in
        fedora)
            run_cmd sudo dnf install -y --nogpgcheck \
                --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' \
                terra-release
            run_cmd sudo dnf install -y noctalia-shell
            ;;
        arch)
            run_cmd $AUR_HELPER -S --needed --noconfirm noctalia-shell
            ;;
        ubuntu|debian)
            echo -e "${RED}Warning: Noctalia may require manual build on Debian-based systems.${NC}"
            ;;
    esac
fi

# Tools
if [[ $CHOICES == *"Tools"* ]]; then
    echo -e "${CYAN}Installing CLI tools...${NC}"
    case $OS in
        fedora)        run_cmd sudo dnf install -y alacritty fuzzel fastfetch chafa bibata-cursor-themes cmatrix ;;
        arch)          run_cmd sudo pacman -S --needed --noconfirm alacritty fuzzel fastfetch chafa bibata-cursor-theme-bin cmatrix ;;
        ubuntu|debian) run_cmd sudo apt install -y alacritty fuzzel fastfetch chafa cmatrix ;;
    esac
fi

# Zsh + Oh My Zsh
if [[ $CHOICES == *"Zsh"* ]]; then
    echo -e "${CYAN}Installing Zsh...${NC}"
    case $OS in
        fedora)        run_cmd sudo dnf install -y zsh ;;
        arch)          run_cmd sudo pacman -S --needed --noconfirm zsh ;;
        ubuntu|debian) run_cmd sudo apt install -y zsh ;;
    esac

    if [ "$DRY_RUN" = false ] && [ ! -d "$HOME/.oh-my-zsh" ]; then
        echo -e "${CYAN}Installing Oh My Zsh...${NC}"
        RUNZSH=no CHSH=no sh -c \
            "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    fi

    if [ "$DRY_RUN" = false ] && [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]; then
        echo -e "${CYAN}Installing zsh-autosuggestions plugin...${NC}"
        git clone https://github.com/zsh-users/zsh-autosuggestions \
            "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
    fi
fi

# Wallpapers
if [[ $CHOICES == *"Wallpapers"* ]]; then
    echo -e "${CYAN}Cloning wallpaper bank (~1GB)...${NC}"
    [ ! -d "$WALLPAPER_DIR" ] && run_cmd git clone "$WALLPAPER_URL" "$WALLPAPER_DIR"
fi

# --- 6. Symlinks & Theming ---
if [[ $CHOICES == *"Symlinks"* ]]; then
    echo -e "\n${CYAN}Setting up dotfiles...${NC}"

    # Clone or update repo
    if [ ! -d "$DOTFILES_DIR" ]; then
        echo -e "${CYAN}Cloning dotfiles to $DOTFILES_DIR...${NC}"
        run_cmd git clone "$REPO_URL" "$DOTFILES_DIR"
    else
        echo -e "${YELLOW}Repo already exists — pulling latest changes...${NC}"
        run_cmd git -C "$DOTFILES_DIR" pull
    fi

    if [ "$DRY_RUN" = true ] || [ -d "$DOTFILES_DIR" ]; then
        echo -e "\n${CYAN}Creating symlinks...${NC}"

        # Config directories — each becomes a symlink inside ~/.config/
        for cfg in niri alacritty fastfetch; do
            make_link "$DOTFILES_DIR/$cfg" "$HOME/.config/$cfg"
        done

        # .zshrc symlink at home
        make_link "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"

        # --- Flavor injection into the LIVE symlinked configs ---
        # We write directly to the source files in DOTFILES_DIR so the
        # symlinks pick up changes instantly without re-linking
        if [ "$DRY_RUN" = false ]; then
            echo -e "\n${CYAN}Injecting ${YELLOW}$SELECTED_FLAVOR${CYAN} flavor...${NC}"

            # Save flavor for shell persistence
            mkdir -p "$(dirname "$FLAVOR_FILE")"
            echo "${SELECTED_FLAVOR,,}" > "$FLAVOR_FILE"

            # A. Niri border color
            NIRI_CONF="$DOTFILES_DIR/niri/config.kdl"
            if [ -f "$NIRI_CONF" ]; then
                sed -i "s/active-color \".*\"/active-color \"$ACTIVE_HEX\"/g" "$NIRI_CONF"
                echo -e "${GREEN}  ✓ Niri color set to $ACTIVE_HEX${NC}"
            fi

            # B. Fastfetch logo + colors (fixed dir name)
            FF_CONF="$DOTFILES_DIR/fastfetch/config.jsonc"
            if [ -f "$FF_CONF" ]; then
                sed -i "s|\"source\":[[:space:]]*\".*\"|\"source\": \"~/lemon-niri-installer/$LOGO\"|g" "$FF_CONF"
                sed -i "s/\"keys\":[[:space:]]*\".*\"/\"keys\": \"$FF_COLOR\"/g"                        "$FF_CONF"
                sed -i "s/\"title\":[[:space:]]*\".*\"/\"title\": \"$FF_COLOR\"/g"                      "$FF_CONF"
                echo -e "${GREEN}  ✓ Fastfetch logo and colors updated${NC}"
            fi

            # C. Zsh prompt colors — written to the flavor persistence file
            # The .zshrc reads $FLAVOR_FILE at startup, so no sed on .zshrc needed
            echo -e "${GREEN}  ✓ Flavor '$SELECTED_FLAVOR' saved — prompt colors will apply on next shell${NC}"
        fi
    fi
fi

# --- 7. VirtualBox Warning ---
if command -v systemd-detect-virt &>/dev/null && systemd-detect-virt | grep -q "oracle"; then
    echo -e "\n${YELLOW}⚠ VirtualBox detected. Make sure 3D Acceleration is enabled in VM settings.${NC}"
    case $OS in
        fedora) echo -e "  Run: ${DIM}sudo dnf install virtualbox-guest-additions${NC}" ;;
        arch)   echo -e "  Run: ${DIM}sudo pacman -S virtualbox-guest-utils${NC}" ;;
    esac
fi

# --- Done ---
echo -e "\n${GREEN}✓ Installation complete!${NC}"
echo -e "${CYAN}Flavor:  ${YELLOW}$SELECTED_FLAVOR${NC}"
echo -e "${DIM}Log out or reboot to see all changes take effect.${NC}"