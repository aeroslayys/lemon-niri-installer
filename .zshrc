# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="agnoster"

plugins=(git zsh-autosuggestions)

# ─────────────────────────────────────────────
# FLAVOR PERSISTENCE
# The installer writes the chosen flavor to this file.
# The flavor() function updates it live.
# ─────────────────────────────────────────────
FLAVOR_FILE="$HOME/.config/lemon-niri/flavor"
CURRENT_FLAVOR="lemon"
[ -f "$FLAVOR_FILE" ] && CURRENT_FLAVOR=$(cat "$FLAVOR_FILE")

# Map flavor name → prompt BG and FG colors
_flavor_prompt_colors() {
    case "$1" in
        lemon) echo "yellow white" ;;
        lime)  echo "green  white" ;;
        blue)  echo "blue   white" ;;
        *)     echo "yellow white" ;;
    esac
}

# Redefine agnoster segments using current flavor colors.
# Called once at startup and again live inside flavor().
_apply_prompt_colors() {
    local colors
    colors=($(_flavor_prompt_colors "$1"))
    local bg="${colors[1]}"
    local fg="${colors[2]}"

    prompt_context() {
        if [[ "$USER" != "$DEFAULT_USER" || -n "$SSH_CLIENT" ]]; then
            prompt_segment $bg $fg "%(!.%{%F{red}%}.)$USER@%m"
        fi
    }

    prompt_dir() {
        prompt_segment $bg $fg '%~'
    }

    prompt_git() {
        local ref dirty
        if $(git rev-parse --is-inside-work-tree >/dev/null 2>&1); then
            dirty=$(git_prompt_status)
            ref=$(git symbolic-ref HEAD 2>/dev/null) \
                || ref="➦ $(git show-ref --head -s --abbrev HEAD | head -n1)"
            prompt_segment $bg $fg "${ref#refs/heads/}${dirty:+ $dirty}"
        fi
    }
}

# Apply on shell start before sourcing OMZ so segments are ready
_apply_prompt_colors "$CURRENT_FLAVOR"

source $ZSH/oh-my-zsh.sh

# ─────────────────────────────────────────────
# THE FLAVOR ENGINE
# Usage: flavor [lemon|lime|blue]
# Updates: prompt colors, Niri border, fastfetch logo/colors
# Everything persists across sessions via $FLAVOR_FILE
# ─────────────────────────────────────────────
flavor() {
    local choice="$1"
    local hex logo ff_color

    case "$choice" in
        lemon) hex="#FFED29"; logo="lemon.png";      ff_color="yellow" ;;
        lime)  hex="#32CD32"; logo="green1.png";     ff_color="green"  ;;
        blue)  hex="#00B4D8"; logo="blue-lemon.png"; ff_color="blue"   ;;
        *)
            echo "Usage: flavor [lemon|lime|blue]"
            echo ""
            echo "  lemon  🍋  Yellow  #FFED29"
            echo "  lime   🍈  Green   #32CD32"
            echo "  blue   🫐  Blue    #00B4D8"
            return 1
            ;;
    esac

    # 1. Persist the choice — startup will read this next time
    mkdir -p "$(dirname "$FLAVOR_FILE")"
    echo "$choice" > "$FLAVOR_FILE"
    CURRENT_FLAVOR="$choice"

    # 2. Apply agnoster prompt colors immediately in this shell
    _apply_prompt_colors "$choice"

    # 3. Update Niri border color
    local niri_cfg="$HOME/.config/niri/config.kdl"
    if [ -f "$niri_cfg" ]; then
        sed -i "s/active-color \".*\"/active-color \"$hex\"/g" "$niri_cfg"
    fi

    # 4. Update fastfetch logo + colors in the config
    local ff_cfg="$HOME/.config/fastfetch/config.jsonc"
    if [ -f "$ff_cfg" ]; then
        sed -i "s|\"source\":[[:space:]]*\".*\"|\"source\": \"~/lemon-niri-installer/$logo\"|g" "$ff_cfg"
        sed -i "s/\"keys\":[[:space:]]*\".*\"/\"keys\": \"$ff_color\"/g"                        "$ff_cfg"
        sed -i "s/\"title\":[[:space:]]*\".*\"/\"title\": \"$ff_color\"/g"                      "$ff_cfg"
    fi

    # 5. Reload Niri config
    if command -v niri &>/dev/null; then
        niri msg action reload-config 2>/dev/null && echo -e "✓ Niri reloaded"
    fi

    echo -e "Switched to \033[1m$choice\033[0m flavor 🍋"
    echo -e "\033[2mOpen a new terminal to see fastfetch changes.\033[0m"
}

# ─────────────────────────────────────────────
# USER CONFIGURATION
# ─────────────────────────────────────────────

# export MANPATH="/usr/local/man:$MANPATH"
# export LANG=en_US.UTF-8
# export EDITOR='nvim'
# export ARCHFLAGS="-arch $(uname -m)"

# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# ─────────────────────────────────────────────
# TERMINAL GREETING
# ─────────────────────────────────────────────
clear
echo ""
fastfetch --config ~/.config/fastfetch/config.jsonc
