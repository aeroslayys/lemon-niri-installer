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

confirm() {
    read -p "$(echo -e "${YELLOW}Install $1? [y/N]: ${NC}")" choice
    [[ "$choice" =~ ^[Yy]$ ]] && return 0 || return 1
}

# --- 1. Distro Detection ---
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
else
    OS="unknown"
fi

# --- 2. Pre-flight Checks & AUR Helper Detection ---
echo -e "${CYAN}Performing pre-flight checks...${NC}"
case $OS in
    fedora)
        run_cmd sudo dnf install -y git dnf-plugins-core curl
        ;;
    arch)
        run_cmd sudo pacman -S --needed --noconfirm git base-devel curl
        
        # Smart AUR Helper Detection
        if command -v yay &> /dev/null; then
            AUR_HELPER="yay"
        elif command -v paru &> /dev/null; then
            AUR_HELPER="paru"
        elif command -v aur &> /dev/null; then
            AUR_HELPER="aur sync -si"
        else
            echo -e "${CYAN}No AUR helper found. Installing yay as fallback...${NC}"
            run_cmd git clone https://aur.archlinux.org/yay.git /tmp/yay
            if [ "$DRY_RUN" = false ]; then
                cd /tmp/yay && makepkg -si --noconfirm && cd - && rm -rf /tmp/yay
            fi
            AUR_HELPER="yay"
        fi
        echo -e "${GREEN}Using AUR Helper: $AUR_HELPER${NC}"
        ;;
esac

# --- 3. Interactive Component Selection ---

# Niri
if confirm "Niri (Window Manager)"; then
    case $OS in
        fedora) run_cmd sudo dnf copr enable -y yalter/niri-git && run_cmd sudo dnf install -y niri ;;
        arch)   run_cmd $AUR_HELPER --needed --noconfirm niri-git ;;
    esac
fi

# Noctalia
if confirm "Noctalia (Status Bar/Shell)"; then
    case $OS in
        fedora) 
            run_cmd sudo dnf install -y --nogpgcheck --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' terra-release
            run_cmd sudo dnf install -y noctalia-shell 
            ;;
        arch) run_cmd $AUR_HELPER --needed --noconfirm noctalia-shell ;;
    esac
fi

# Cursor
if confirm "Bibata Modern Ice Cursor"; then
    case $OS in
        fedora) run_cmd sudo dnf install -y bibata-cursor-themes ;;
        arch)   run_cmd $AUR_HELPER --needed --noconfirm bibata-cursor-theme-bin ;;
    esac
fi

# Standard Packages
PACKAGES=()
confirm "Fuzzel (Launcher)" && PACKAGES+=("fuzzel")
confirm "Alacritty (Terminal)" && PACKAGES+=("alacritty")
confirm "Fastfetch & Chafa (Logos)" && PACKAGES+=("fastfetch" "chafa")
confirm "GTK4 Libraries" && PACKAGES+=("gtk4")

if [ ${#PACKAGES[@]} -ne 0 ]; then
    case $OS in
        fedora) run_cmd sudo dnf install -y "${PACKAGES[@]}" ;;
        arch)   run_cmd sudo pacman -S --needed --noconfirm "${PACKAGES[@]}" ;;
    esac
fi

# --- 4. Zsh Setup ---
if confirm "Zsh + Oh My Zsh (and set as default shell)"; then
    case $OS in
        fedora) run_cmd sudo dnf install -y zsh ;;
        arch)   run_cmd sudo pacman -S --needed --noconfirm zsh ;;
    esac
    
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        run_cmd sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    fi

    ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
    [ ! -d "${ZSH_CUSTOM}/plugins/zsh-autosuggestions" ] && run_cmd git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM}/plugins/zsh-autosuggestions
    [ ! -d "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting" ] && run_cmd git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting
    
    echo -e "${CYAN}Changing default shell to Zsh...${NC}"
    run_cmd sudo chsh -s $(which zsh) $USER
fi

# --- 5. Assets & Wallpapers ---
if confirm "Download Wallpaper-Bank (~1GB)"; then
    run_cmd mkdir -p "$HOME/Pictures"
    [ ! -d "$WALLPAPER_DIR" ] && run_cmd git clone --depth 1 "$WALLPAPER_URL" "$WALLPAPER_DIR"
fi

# --- 6. Repository & Symlinking ---
if [ ! -d "$DOTFILES_DIR" ]; then
    echo -e "${CYAN}Cloning lemon niri installer...${NC}"
    run_cmd git clone "$REPO_URL" "$DOTFILES_DIR"
fi

if confirm "Apply Dotfile Symlinks (Niri, Alacritty, Fuzzel, Zshrc)"; then
    [ "$DRY_RUN" = false ] && mkdir -p "$HOME/.config" "$BACKUP_DIR"

    if [ -f "$DOTFILES_DIR/zshrc" ]; then
        [ "$DRY_RUN" = false ] && [ -f "$HOME/.zshrc" ] && mv "$HOME/.zshrc" "$BACKUP_DIR/.zshrc.bak" 2>/dev/null
        run_cmd ln -sf "$DOTFILES_DIR/zshrc" "$HOME/.zshrc"
    fi

    for cfg in "niri" "alacritty" "fuzzel" "noctalia"; do
        if [ -d "$DOTFILES_DIR/$cfg" ]; then
            run_cmd ln -sf "$DOTFILES_DIR/$cfg" "$HOME/.config/"
        fi
    done
fi

# --- 7. Final Checks ---
if systemd-detect-virt | grep -q "oracle"; then
    echo -e "\n${YELLOW}VirtualBox detected. Ensure 3D Acceleration is ON in VM settings.${NC}"
fi

echo -e "\n${GREEN}Lemon Niri setup complete! Reboot or Logout To apply changes.${NC}"
echo -e "${CYAN}Github : aeroslayys${NC}"
