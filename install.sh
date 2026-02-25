#!/bin/bash

# --- Configuration ---
REPO_URL="https://github.com/aeroslayys/niri-dotfiles"
WALLPAPER_URL="https://github.com/JaKooLit/Wallpaper-Bank"
DOTFILES_DIR="$HOME/niri-dotfiles"
WALLPAPER_DIR="$HOME/Pictures/Wallpaper-Bank"
BACKUP_DIR="$HOME/dotfiles_backup_$(date +%Y%m%d_%H%M%S)"
NOCTALIA_CONF="$HOME/.config/noctalia/colors.json"

# Colors
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
MAGENTA='\033[0;35m'
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
else
    OS="unknown"
fi

# --- 2. Pre-flight Checks (The "Survival" Tools) ---
echo -e "${CYAN}Performing pre-flight checks...${NC}"
case $OS in
    fedora)
        # Ensure git and basic build tools exist
        if ! command -v git &> /dev/null || ! rpm -q dnf-plugins-core &> /dev/null; then
            echo -e "${YELLOW}Installing git and DNF plugins...${NC}"
            run_cmd sudo dnf install -y git dnf-plugins-core
        fi
        ;;
    arch)
        # Ensure git and base-devel exist (essential for AUR)
        if ! command -v git &> /dev/null || ! pacman -Qs base-devel &> /dev/null; then
            echo -e "${YELLOW}Installing git and base-devel...${NC}"
            run_cmd sudo pacman -S --needed --noconfirm git base-devel
        fi
        # Check for yay, install if missing
        if ! command -v yay &> /dev/null; then
            echo -e "${YELLOW}yay not found. Installing yay...${NC}"
            run_cmd git clone https://aur.archlinux.org/yay.git /tmp/yay
            if [ "$DRY_RUN" = false ]; then
                cd /tmp/yay && makepkg -si --noconfirm && cd - && rm -rf /tmp/yay
            fi
        fi
        ;;
esac

# --- 3. Special Package Handlers ---

install_niri() {
    echo -e "${CYAN}Installing Niri...${NC}"
    case $OS in
        fedora)
            run_cmd sudo dnf copr enable -y yalter/niri-git
            run_cmd sudo dnf install -y niri
            ;;
        arch)
            run_cmd yay -S --needed --noconfirm niri-git
            ;;
    esac
}

install_noctalia() {
    echo -e "${CYAN}Installing Noctalia...${NC}"
    case $OS in
        fedora)
            if ! rpm -q terra-release &> /dev/null; then
                run_cmd sudo dnf install -y --nogpgcheck --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' terra-release
            fi
            run_cmd sudo dnf install -y noctalia-shell
            ;;
        arch)
            run_cmd yay -S --needed --noconfirm noctalia-shell
            ;;
    esac
}

install_gtk4() {
    case $OS in
        fedora) if ! rpm -q gtk4 &> /dev/null; then run_cmd sudo dnf install -y gtk4; fi ;;
        arch) if ! pacman -Qs gtk4 &> /dev/null; then run_cmd sudo pacman -S --needed --noconfirm gtk4; fi ;;
    esac
}

# --- 4. Interactive Installation ---
confirm() {
    read -p "Install $1? [y/N]: " choice
    [[ "$choice" =~ ^[Yy]$ ]] && return 0 || return 1
}

echo -e "${YELLOW}Select components to install:${NC}"

install_gtk4
confirm "Niri (Window Manager)" && install_niri
confirm "Noctalia (Status Bar/Shell)" && install_noctalia

PACKAGES=()
confirm "Fuzzel (App Launcher)" && PACKAGES+=("fuzzel")
confirm "Alacritty (Terminal)" && PACKAGES+=("alacritty")
confirm "Fastfetch & Chafa (Lemon Logo)" && PACKAGES+=("fastfetch" "chafa")
confirm "Zsh Shell" && PACKAGES+=("zsh")

if [ ${#PACKAGES[@]} -ne 0 ]; then
    case $OS in
        fedora) run_cmd sudo dnf install -y "${PACKAGES[@]}" ;;
        arch)   run_cmd sudo pacman -S --needed --noconfirm "${PACKAGES[@]}" ;;
    esac
fi

# --- 5. Wallpaper Bank ---
if confirm "Download Wallpaper-Bank (~1GB)?"; then
    run_cmd mkdir -p "$HOME/Pictures"
    if [ ! -d "$WALLPAPER_DIR" ]; then
        echo -e "${CYAN}Cloning Wallpapers...${NC}"
        run_cmd git clone --depth 1 "$WALLPAPER_URL" "$WALLPAPER_DIR"
    fi
fi

# --- 6. Apply Gruvbox JSON to Noctalia ---
if confirm "Apply Gruvbox Theme to Noctalia?"; then
    [ "$DRY_RUN" = false ] && mkdir -p "$(dirname "$NOCTALIA_CONF")"
    run_cmd bash -c "cat <<EOF > $NOCTALIA_CONF
{
    \"mError\": \"#fb4934\",
    \"mHover\": \"#83a598\",
    \"mOnError\": \"#282828\",
    \"mOnHover\": \"#282828\",
    \"mOnPrimary\": \"#282828\",
    \"mOnSecondary\": \"#282828\",
    \"mOnSurface\": \"#fbf1c7\",
    \"mOnSurfaceVariant\": \"#ebdbb2\",
    \"mOnTertiary\": \"#282828\",
    \"mOutline\": \"#57514e\",
    \"mPrimary\": \"#b8bb26\",
    \"mSecondary\": \"#fabd2f\",
    \"mShadow\": \"#282828\",
    \"mSurface\": \"#282828\",
    \"mSurfaceVariant\": \"#3c3836\",
    \"mTertiary\": \"#83a598\"
}
EOF"
fi

# --- 7. Repository & Symlinking ---
if [ ! -d "$DOTFILES_DIR" ]; then
    run_cmd git clone "$REPO_URL" "$DOTFILES_DIR"
fi

[ "$DRY_RUN" = false ] && mkdir -p "$HOME/.config" "$BACKUP_DIR"

for cfg in "niri" "alacritty" "fuzzel"; do
    if [ -d "$DOTFILES_DIR/$cfg" ]; then
        target="$HOME/.config/$cfg"
        if [ -d "$target" ] && [ ! -L "$target" ]; then
            run_cmd mv "$target" "$BACKUP_DIR/"
        fi
        run_cmd ln -sf "$DOTFILES_DIR/$cfg" "$HOME/.config/"
    fi
done

# --- 8. Zshrc Integration ---
if [ -f "$DOTFILES_DIR/zshrc" ]; then
    if [ "$DRY_RUN" = false ] && ! grep -q "lemon" "$HOME/.zshrc" 2>/dev/null; then
        cat "$DOTFILES_DIR/zshrc" >> "$HOME/.zshrc"
    fi
fi

# --- 9. VirtualBox Check ---
echo -e "\n${CYAN}Checking for VirtualBox environment...${NC}"
if systemd-detect-virt | grep -q "oracle"; then
    echo -e "${MAGENTA}------------------------------------------------------------${NC}"
    echo -e "${YELLOW}NOTICE: VirtualBox detected!${NC}"
    echo -e "For better screen resolution and performance, please install:"
    case $OS in
        fedora) echo -e "${CYAN}sudo dnf install -y virtualbox-guest-additions${NC}" ;;
        arch)   echo -e "${CYAN}sudo pacman -S --needed virtualbox-guest-utils${NC}" ;;
    esac
    echo -e "${MAGENTA}------------------------------------------------------------${NC}"
fi

echo -e "\n${GREEN}Lemon Niri setup complete! Reboot or Logout To apply changes. Github : aeroslayys${NC}"
