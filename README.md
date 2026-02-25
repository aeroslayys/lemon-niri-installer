# 🍋 Lemon Niri Dotfiles

![Preview of my Lemon Niri Setup](preview.png)

My custom Wayland desktop environment featuring a bold yellow **"Citrus"** aesthetic and proportional tiling powered by Niri.

Minimal. Bright. Functional.

---

## 📸 Preview

> [!TIP]
> This setup uses `fastfetch` with a custom lemon graphic rendered via `chafa` for that signature look.

---

# 🚀 Installation

## ✅ Recommended: Manual Installation

Manual installation is **strongly recommended** so you:

- Understand every change being made  
- Control your backups  
- Avoid unexpected package conflicts  
- Learn how your environment is structured  

---

### 1️⃣ Install Core Dependencies

Install what you need using your distro’s package manager.

**Core:**
- `niri`
- `alacritty`
- `fastfetch`
- `chafa`
- `zsh`
- JetBrains Mono Nerd Font
- `git`

Example:

**Fedora**
```bash
sudo dnf install niri alacritty fastfetch chafa zsh jetbrains-mono-fonts-all git
```

**Arch**
```bash
sudo pacman -S --needed niri alacritty fastfetch chafa zsh ttf-jetbrains-mono-nerd git
```

**Ubuntu / Debian / Pop!_OS**
```bash
sudo apt update
sudo apt install niri alacritty fastfetch chafa zsh git
```

> Nerd Font may require manual installation on Debian-based systems.

---

### 2️⃣ Clone Repository

```bash
git clone https://github.com/aeroslayys/niri-dotfiles ~/niri-dotfiles
```

---

### 3️⃣ Backup Existing Configs (Important)

```bash
mkdir -p ~/dotfiles_backup
mv ~/.config/niri ~/dotfiles_backup/
mv ~/.config/alacritty ~/dotfiles_backup/
```

---

### 4️⃣ Symlink Configurations

```bash
mkdir -p ~/.config
ln -sf ~/niri-dotfiles/niri ~/.config/
ln -sf ~/niri-dotfiles/alacritty ~/.config/
```

---

### 5️⃣ Zsh Setup

Append the provided configuration:

```bash
cat ~/niri-dotfiles/zshrc >> ~/.zshrc
```

Ensure `lemon.png` is placed in:

```
~/Downloads
```

---

## ⚠️ Auto Installer (Use at Your Own Risk)

An interactive installer script is included for convenience.

⚠️ **Manual installation is preferred.**  
⚠️ Review the script before running.  
⚠️ You are responsible for changes made to your system.

---

### Dry Run (Recommended First)

```bash
bash <(curl -sSL https://raw.githubusercontent.com/aeroslayys/niri-dotfiles/main/install.sh) --dry-run
```

---

### Execute Installer

```bash
bash <(curl -sSL https://raw.githubusercontent.com/aeroslayys/niri-dotfiles/main/install.sh)
```

---

## 🧠 What the Auto Installer Does

### ✔ 1. Detects Your Distro
Uses `/etc/os-release` and supports:

- Fedora → `dnf`
- Arch → `pacman`
- Ubuntu / Debian / Pop!_OS → `apt`

If unsupported, it exits and requires manual install.

---

### ✔ 2. Interactive Component Selection

You can choose to install:

- Niri (Compositor)
- Alacritty (Terminal)
- Fastfetch & Chafa (Lemon logo tools)
- Zsh
- JetBrains Mono Nerd Font  
  - Fedora → `jetbrains-mono-fonts-all`
  - Arch → `ttf-jetbrains-mono-nerd`

---

### ✔ 3. Repository Handling

- Clones into `~/niri-dotfiles` (if missing)
- Skips clone if already present

---

### ✔ 4. Safe Symlinking

- Only links:
  - `niri`
  - `alacritty`
- Existing directories are backed up to:

```
~/dotfiles_backup_YYYYMMDD_HHMMSS
```

---

### ✔ 5. Zsh Configuration

- Appends repo `zshrc` into your existing `~/.zshrc`
- Supports dry-run preview
- Does **not** overwrite existing `.zshrc`

---

### ✔ 6. Final Reminder

The script reminds you that:

> Manual installation of **Noctalia** is still required.

---

## 🛠️ Components

| Category        | Tool        |
|----------------|------------|
| Compositor     | Niri       |
| Terminal       | Alacritty  |
| Shell          | Zsh        |
| System Info    | Fastfetch  |
| ASCII Renderer | Chafa      |
| Font           | JetBrains Mono Nerd Font |

---

## ⚙️ Key Specs

- **Window Ratio:** 0.5 default column width  
- **Theme:** High-contrast yellow accents  
- **Font:** JetBrains Mono Nerd Font  

---

## 🍋 Philosophy

This setup is intentionally:

- Minimal  
- High-contrast  
- Proportional  
- Fast  

Designed around a clean Wayland workflow with citrus flair.

---

Enjoy your Lemon Niri setup 🍋
