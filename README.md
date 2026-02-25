# 🍋 Lemon Niri Installer

![Preview of my Lemon Niri Setup](preview.png)

A citrus-themed Wayland desktop installer built around **Niri** with proportional tiling and bold yellow accents.

Minimal. Bright. Functional.

---

# 📸 Preview

> This setup uses `fastfetch` rendered through `chafa` for the custom lemon logo.

---

# 🚀 Installation

## 📦 Clone Repository

```bash
git clone https://github.com/aeroslayys/lemon-niri-installer
cd lemon-niri-installer
```

---

## ▶ Run Installer

```bash
bash install.sh
```

Preview changes safely:

```bash
bash install.sh --dry-run
```

---

# ⚠️ Supported Distributions

- Fedora
- Arch Linux

---

# 🧠 What the Installer Does

## ✔ Distro Detection

- Detects system using `/etc/os-release`
- Fedora → `dnf`
- Arch → `pacman`

---

## ✔ Pre-Flight Checks

### Fedora
- Ensures `git` is installed
- Installs `dnf-plugins-core` if missing

### Arch
- Ensures `git`
- Ensures `base-devel`
- Installs AUR helper automatically if missing

---

## 🏔 Arch Linux & AUR Helpers

The installer is designed to be **AUR-helper agnostic**.

It will prioritize existing helpers such as:

- `yay`
- `paru`
- `aurutils`

If none of these are detected, the installer will automatically install `yay` to complete the environment setup.

This ensures a smooth experience while respecting existing Arch workflows.

---

## ✔ Special Package Handling

### Niri
- Fedora → Enables COPR `yalter/niri-git`
- Arch → Installs `niri-git` from AUR

### Noctalia
- Fedora → Enables Terra repository automatically
- Arch → Installs via detected AUR helper

### GTK4
- Automatically installs if missing

---

## ✔ Interactive Component Selection

You can choose to install:

- Niri (Window Manager)
- Noctalia (Status Bar / Shell)
- Fuzzel (App Launcher)
- Alacritty (Terminal)
- Fastfetch & Chafa
- Zsh
- Wallpaper Bank (~1GB)
- Gruvbox Theme Injection

Nothing installs without confirmation.

---

## ✔ Safe Dotfile Handling

- Clones dotfiles repository if missing
- Creates timestamped backup:

```
~/dotfiles_backup_YYYYMMDD_HHMMSS
```

- Backs up existing configs
- Creates clean symlinks

---

## ✔ VirtualBox Detection

If running inside VirtualBox, the installer recommends:

### Fedora
```bash
sudo dnf install virtualbox-guest-additions
```

### Arch
```bash
sudo pacman -S virtualbox-guest-utils
```

---

# 🛠️ Components Overview

| Category      | Tool        |
|--------------|------------|
| Compositor   | Niri       |
| Terminal     | Alacritty  |
| Status Bar   | Noctalia   |
| Launcher     | Fuzzel     |
| System Info  | Fastfetch  |
| ASCII Render | Chafa      |
| Shell        | Zsh        |

---

# ⚙️ Key Specs

- **Window Ratio:** 0.5 default column width  
- **Theme:** Gruvbox-inspired citrus contrast  
- **Layout:** Proportional tiling  
- **Bar:** Noctalia (GTK4-based)  
- **Installer:** Interactive with dry-run support  

---

# 🍋 Philosophy

A high-contrast, proportional Wayland workflow with citrus identity.

Designed for clarity, speed, and simplicity.

---

# 🤝 Credits & Appreciations

- **[Niri](https://github.com/niri-wm/niri)** — The scrollable Wayland compositor that makes this all possible.  
- **[Noctalia](https://noctalia.dev/)** — For the beautiful, customizable bar and shell.  
- **[JaKooLit](https://github.com/JaKooLit)** — Inspiration for the interactive installation flow and the Wallpaper-Bank.  
- **[Bibata Cursor](https://github.com/ful1e5/bibata)** — For the sleek Modern Ice cursor theme.  
- **The Fedora and Arch Communities** — For maintaining the repositories and COPR/AUR infrastructure.

---

Enjoy your Lemon Niri setup 🍋
