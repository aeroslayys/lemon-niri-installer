#!/bin/bash

# --- Configuration ---
REPO_URL="https://github.com/aeroslayys/lemon-niri-installer"
WALLPAPER_URL="https://github.com/JaKooLit/Wallpaper-Bank"
DOTFILES_DIR="$HOME/lemon-niri-installer"
WALLPAPER_DIR="$HOME/Pictures/Wallpaper-Bank"
BACKUP_DIR="$HOME/dotfiles_backup_$(date +%Y%m%d_%H%M%S)"

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
        echo -e "${MAGENTA}[DRY-RUN] Executing:${NC} $@"
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
# Usage: radio_menu "Title" "Subtitle" ITEMS_ARRAY
# Sets global: RADIO_RESULT (the chosen tag)
# ─────────────────────────────────────────────
radio_menu() {
    local title="$1"
    local subtitle="$2"
    shift 2
    local items=("$@")   # flat: tag desc tag desc ...
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

        # Read a single keypress (handles arrow keys which are 3-byte sequences)
        IFS= read -rsn1 key </dev/tty
        if [[ "$key" == $'\x1b' ]]; then
            read -rsn2 -t 0.1 key2 </dev/tty
            key="$key$key2"
        fi

        case "$key" in
            'k'|$'\x1b[A')  # up
                (( cursor > 0 )) && (( cursor-- ))
                ;;
            'j'|$'\x1b[B')  # down
                (( cursor < count-1 )) && (( cursor++ ))
                ;;
            '')  # enter
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
# CHECKLIST MENU  (multi select, j/k or arrows, space to toggle)
# Usage: check_menu "Title" "Subtitle" ITEMS_ARRAY
# Items flat: tag desc default(ON/OFF) tag desc default ...
# Sets global: CHECK_RESULT (space-separated selected tags)
# ─────────────────────────────────────────────
check_menu() {
    local title="$1"
    local subtitle="$2"
    shift 2
    local items=("$@")   # flat: tag desc ON/OFF ...
    local count=$(( ${#items[@]} / 3 ))
    local cursor=0
    local selected=()

    # Initialise selected state from defaults
    for (( i=0; i<count; i++ )); do
        if [[ "${items[$((i*3+2))]}" == "ON" ]]; then
            selected[$i]=1
        else
            selected[$i]=0
        fi
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
            'k'|$'\x1b[A')  # up
                (( cursor > 0 )) && (( cursor-- ))
                ;;
            'j'|$'\x1b[B')  # down
                (( cursor < count-1 )) && (( cursor++ ))
                ;;
            ' ')  # space — toggle
                if [[ "${selected[$cursor]}" -eq 1 ]]; then
                    selected[$cursor]=0
                else
                    selected[$cursor]=1
                fi
                ;;
            '')  # enter — confirm
                CHECK_RESULT=""
                for (( i=0; i<count; i++ )); do
                    if [[ "${selected[$i]}" -eq 1 ]]; then
                        CHECK_RESULT+="${items[$((i*3))]} "
                    fi
                done
                CHECK_RESULT="${CHECK_RESULT% }"  # trim trailing space
                return 0
                ;;
            'e'|'E')
                echo -e "\n${RED}Installer cancelled.${NC}"
                exit 1
                ;;
        esac
    done
}

# --- 2. Ensure deps ---
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
    Lemon) ACTIVE_HEX="#FFED29"; LOGO="lemon.png";      SELECTED_FLAVOR="Lemon" ;;
    Lime)  ACTIVE_HEX="#32CD32"; LOGO="green1.png";     SELECTED_FLAVOR="Lime"  ;;
    Blue)  ACTIVE_HEX="#00B4D8"; LOGO="blue-lemon.png"; SELECTED_FLAVOR="Blue"  ;;
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

# --- 5. Installation ---

# Niri
if [[ $CHOICES == *"Niri"* ]]; then
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
    case $OS in
        fedora)
            run_cmd sudo dnf install -y --nogpgcheck \
                --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' \
                terra-release
            run_cmd sudo dnf install -y noctalia-shell
            ;;
        arch)  run_cmd $AUR_HELPER -S --needed --noconfirm noctalia-shell ;;
        ubuntu|debian) echo -e "${RED}Warning: Noctalia may require manual build on Debian-based systems.${NC}" ;;
    esac
fi

# Tools
if [[ $CHOICES == *"Tools"* ]]; then
    case $OS in
        fedora)        run_cmd sudo dnf install -y alacritty fuzzel fastfetch chafa bibata-cursor-themes ;;
        arch)          run_cmd sudo pacman -S --needed --noconfirm alacritty fuzzel fastfetch chafa bibata-cursor-theme-bin ;;
        ubuntu|debian) run_cmd sudo apt install -y alacritty fuzzel fastfetch chafa ;;
    esac
fi

# Zsh
if [[ $CHOICES == *"Zsh"* ]]; then
    case $OS in
        fedora)        run_cmd sudo dnf install -y zsh ;;
        arch)          run_cmd sudo pacman -S --needed --noconfirm zsh ;;
        ubuntu|debian) run_cmd sudo apt install -y zsh ;;
    esac
    # ... rest of zsh logic
fi

# Wallpapers
if [[ $CHOICES == *"Wallpapers"* ]]; then
    echo -e "${CYAN}Cloning wallpaper bank...${NC}"
    [ ! -d "$WALLPAPER_DIR" ] && run_cmd git clone "$WALLPAPER_URL" "$WALLPAPER_DIR"
fi

#!/bin/bash
# [All your radio_menu, check_menu, and dependency logic goes here...]
# --- 6. Symlinks & Theming (The Final Step) ---
if [[ $CHOICES == *"Symlinks"* ]]; then
    echo -e "${CYAN}Cloning & applying configurations...${NC}"
    
    # Ensure the repo exists
    if [ ! -d "$DOTFILES_DIR" ]; then
        run_cmd git clone "$REPO_URL" "$DOTFILES_DIR"
    else
        echo -e "${YELLOW}Repo already exists, pulling latest changes...${NC}"
        run_cmd git -C "$DOTFILES_DIR" pull
    fi

    if [ "$DRY_RUN" = false ] || [ -d "$DOTFILES_DIR" ]; then
        # 1. Inject Theme into Config Files (Repo Side)
        echo -e "${CYAN}Injecting $SELECTED_FLAVOR flavor into configurations...${NC}"
        
        # Theme Niri Focus Ring
        sed -i "s/active-color \".*\"/active-color \"$ACTIVE_HEX\"/g" "$DOTFILES_DIR/niri/config.kdl"
        
        # Theme Fastfetch Config (if using jsonc)
        if [ -f "$DOTFILES_DIR/fastfetch/config.jsonc" ]; then
            sed -i "s|\"source\": \".*\"|\"source\": \"~/lemon-niri-installer/$LOGO\"|g" "$DOTFILES_DIR/fastfetch/config.jsonc"
        fi

        # Theme Zshrc (Injecting Logo and Agnoster Colors into the repo file)
        if [ -f "$DOTFILES_DIR/zshrc" ]; then
            # Set the Agnoster Colors
            case $SELECTED_FLAVOR in
                Lemon) FG="yellow"; BG="red" ;;
                Lime)  FG="green";  BG="black" ;;
                Blue)  FG="blue";   BG="white" ;;
            esac
            
            sed -i "s/CURRENT_FG=\".*\"/CURRENT_FG=\"$FG\"/g" "$DOTFILES_DIR/zshrc"
            sed -i "s/CURRENT_BG=\".*\"/CURRENT_BG=\"$BG\"/g" "$DOTFILES_DIR/zshrc"
            
            # Update the hardcoded fastfetch line in zshrc
            sed -i "s|--logo .*/.*.png|--logo ~/lemon-niri-installer/$LOGO|g" "$DOTFILES_DIR/zshrc"
        fi

        # 2. Setup Directories
        [ "$DRY_RUN" = false ] && mkdir -p "$HOME/.config" "$BACKUP_DIR"

        # 3. Apply Zshrc Symlink
        if [ -f "$DOTFILES_DIR/zshrc" ]; then
            echo -e "${CYAN}Backing up and linking .zshrc...${NC}"
            # Only backup if it's a real file, don't backup existing symlinks to avoid clutter
            [ "$DRY_RUN" = false ] && [ -f "$HOME/.zshrc" ] && [ ! -L "$HOME/.zshrc" ] && mv "$HOME/.zshrc" "$BACKUP_DIR/.zshrc.bak"
            run_cmd ln -sf "$DOTFILES_DIR/zshrc" "$HOME/.zshrc"
        fi

        # 4. Apply Config Folders
        for cfg in "niri" "alacritty" "fuzzel" "noctalia" "fastfetch"; do
            if [ -d "$DOTFILES_DIR/$cfg" ]; then
                echo -e "${CYAN}Linking $cfg config...${NC}"
                # Remove existing directory/link to prevent nested folder bugs
                [ "$DRY_RUN" = false ] && rm -rf "$HOME/.config/$cfg"
                run_cmd ln -sf "$DOTFILES_DIR/$cfg" "$HOME/.config/"
            fi
        done
    fi
fi

# --- Final Check ---
if systemd-detect-virt | grep -q "oracle"; then
    echo -e "\n${YELLOW}VirtualBox detected. Ensure 3D Acceleration is ON.${NC}"
fi

echo -e "\n${GREEN}Installation complete!${NC}"
echo -e "${CYAN}Flavor: ${YELLOW}$SELECTED_FLAVOR${NC}"
echo -e "${DIM}Logout or reboot to see all changes take effect.${NC}"

# --- Done ---
echo -e "\n${GREEN}Installation complete!${NC}"
echo -e "${CYAN}Selected Flavor: ${YELLOW}$SELECTED_FLAVOR${NC}"