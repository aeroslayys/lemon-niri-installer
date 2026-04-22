# 🍋 Lemon Niri Installer

A citrus-themed Wayland desktop setup built around **Niri**, featuring proportional tiling, bold accent colors, and a dynamic flavor system.

Minimal. Bright. Functional.

---

# 🎨 Pick Your Flavor

Choose your accent color during installation — and switch anytime later.

| Flavor | Color | Hex |
|--------|-------|-----|
| 🍋 Lemon | Classic Yellow | `#FFED29` |
| 🍈 Lime | Fresh Green | `#32CD32` |
| 🫐 Blue | Blue Lemonade | `#00B4D8` |

### 🍋 Lemon
![Lemon Preview](lemonpreview.png)

### 🍈 Lime
![Lime Preview](greenpreview.png)

### 🫐 Blue
![Blue Preview](bluepreview.png)

---

# 🧠 Key Features

✔ Interactive **TUI installer** (no dependencies)  
✔ **Live theme engine** (`flavor` command)  
✔ **Symlink-based dotfiles** (clean & maintainable)  
✔ Safe config handling with automatic backups  
✔ Cross-distro support  
✔ `--dry-run` preview mode  

---

# 🚀 Installation

## ⭐ Recommended: Manual Installation

Manual install is strongly recommended so you:

- Understand system changes  
- Retain full control over configs  
- Avoid unintended overwrites  
- Learn your environment structure  

---

## 📦 Manual Steps

### 1️⃣ Install Core Packages

#### Fedora
```bash
sudo dnf install niri alacritty fastfetch chafa fuzzel git zsh cmatrix
```

#### Arch (requires AUR helper like `yay` or `paru`)
```bash
yay -S niri-git noctalia-shell bibata-cursor-theme-bin
sudo pacman -S --needed alacritty fuzzel fastfetch chafa git zsh cmatrix
```

#### Debian / Ubuntu
```bash
sudo apt update
sudo apt install alacritty fuzzel fastfetch chafa git zsh cmatrix cargo libwayland-dev libgbm-dev libinput-dev
cargo install --locked niri
```

> ⚠ Noctalia and Bibata may require manual setup on Debian-based systems

---

### 2️⃣ Clone Dotfiles

```bash
git clone https://github.com/aeroslayys/lemon-niri-installer ~/lemon-niri-installer
```

---

### 3️⃣ Apply Configs (Symlinks)

```bash
ln -sf ~/lemon-niri-installer/niri ~/.config/niri
ln -sf ~/lemon-niri-installer/alacritty ~/.config/alacritty
ln -sf ~/lemon-niri-installer/fastfetch ~/.config/fastfetch
ln -sf ~/lemon-niri-installer/.zshrc ~/.zshrc
```

---

### 4️⃣ Setup Zsh

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-autosuggestions \
  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
```

---

### 5️⃣ Set Your Flavor

The installer normally handles this automatically.
---

## ⚡ One-Line Install (Quick Setup)

### ▶ Run Installer
```bash
bash <(curl -sSL https://gist.githubusercontent.com/aeroslayys/48301affed815e0ed09d492c48f3322a/raw/install.sh)
```

### 🧪 Dry Run
```bash
bash <(curl -sSL https://gist.githubusercontent.com/aeroslayys/48301affed815e0ed09d492c48f3322a/raw/install.sh) --dry-run
```

> ⚠ Always review scripts before piping to bash.

---

## ⚙️ Local Installer

```bash
chmod +x install.sh
./install.sh
```

Dry run:

```bash
chmod +x install.sh
./install.sh --dry-run
```

---

# 🎮 Interactive Installer

Includes:

- Flavor selection (radio menu)
- Component selection (checklist)
- Safe symlink creation
- Automatic backups
- Theme injection

---

## ⌨ Controls

| Key | Action |
|-----|--------|
| `j` / `↓` | Move down |
| `k` / `↑` | Move up |
| `SPACE` | Toggle |
| `ENTER` | Confirm |
| `e` | Exit |

---

## 🔄 What It Updates

- Zsh prompt (Agnoster-based)
- Niri border color
- Fastfetch logo & colors

✔ Applies instantly  
✔ Persists across sessions  
✔ Reloads Niri automatically when using `flavor`  

---

# ⚙️ What the Installer Does

## ✔ Installs

- Niri
- Noctalia
- Alacritty
- Fuzzel
- Fastfetch
- Chafa
- Bibata Cursor (Arch/Fedora)
- Zsh + Oh My Zsh
- zsh-autosuggestions
- cmatrix

---

## ✔ Dotfile System

- Uses **symlinks (not copies)**
- Keeps configs inside repo
- Allows easy updates via:

```bash
git pull
```

---

## ✔ Safe Symlinking

- Existing configs are backed up
- Existing correct symlinks are preserved
- No silent overwrites

Backups stored at:

```
~/dotfiles_backup_YYYYMMDD_HHMMSS
```

---

## ✔ Theme Injection (Important)

Theme changes are written directly to:

```
~/lemon-niri-installer/
```

Because configs are symlinked:

✔ Changes apply instantly  
✔ No need to recreate links  

---

## ✔ Fastfetch Behavior

Fastfetch uses logos from:

```
~/lemon-niri-installer/
```

Do not move the repo unless you update paths.

---

# 🖼 Wallpaper Pack (Optional)

- Source: JaKooLit Wallpaper Bank  
- Size: ~1GB  

Installed to:

```
~/Pictures/Wallpaper-Bank
```

---

# 🧊 Virtual Machine Support

If running in VirtualBox:

### Fedora
```bash
sudo dnf install virtualbox-guest-additions
```

### Arch
```bash
sudo pacman -S virtualbox-guest-utils
```

---

# 🛠 Components Overview

| Category      | Tool |
|--------------|------|
| Compositor   | Niri |
| Terminal     | Alacritty |
| Bar          | Noctalia |
| Launcher     | Fuzzel |
| System Info  | Fastfetch |
| ASCII        | Chafa |
| Shell        | Zsh + OMZ |
| Plugin       | zsh-autosuggestions |
| Cursor       | Bibata |
| Fun          | cmatrix |

---

# ⚡ Key Specs

- **Layout:** Proportional tiling  
- **Default Ratio:** 0.5  
- **Theme Engine:** Dynamic (flavor-based)  
- **Config System:** Symlink-based  

---

# 🍋 Philosophy

A fast, clean Wayland setup focused on:

- Simplicity  
- Visual clarity  
- Live customization  

---

# ⚠️ Notes

- Use `--dry-run` before installing  
- Debian support is experimental  
- Configs are symlinked and managed centrally  

---

# 🤝 Contributors & Credits

### Core

- **[@aeroslayys](https://github.com/aeroslayys)** — Creator & Developer  

---

### Special Thanks

- **[Niri](https://github.com/niri-wm/niri)**  
- **[Noctalia](https://noctalia.dev/)**  
- **[JaKooLit](https://github.com/JaKooLit)**  
- **[Bibata Cursor](https://github.com/ful1e5/bibata)**  

---

Enjoy your Lemon Niri setup 🍋