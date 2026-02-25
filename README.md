# 🍋 Lemon Niri Installer

![Preview of my Lemon Niri Setup](preview.png)

A citrus-themed Wayland desktop installer built around **Niri** with proportional tiling and bold yellow accents.

Minimal. Bright. Functional.

---

# 📸 Preview

> This setup uses `fastfetch` rendered through `chafa` for the custom lemon logo.

---

# 🚀 Installation

## ✅ Recommended: Manual Installation

Manual installation is strongly recommended so you:

- Understand system changes  
- Control backups  
- Avoid unintended overwrites  
- Learn your environment structure  

---

# 📦 Manual Install Steps

## 1️⃣ Install Core Dependencies

Install the following packages:

- `niri`
- `alacritty`
- `fastfetch`
- `chafa`
- `git`

### Fedora

```bash
sudo dnf install niri alacritty fastfetch chafa git
```

### Arch

```bash
sudo pacman -S --needed niri alacritty fastfetch chafa git
```

---

## 2️⃣ Install Noctalia (Status Bar)

### Arch

Install using your preferred AUR helper:

```bash
<aur-helper> -S noctalia-shell
```

### Fedora

```bash
sudo dnf install --nogpgcheck --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' terra-release
sudo dnf install noctalia-shell
```

---

## 3️⃣ Clone Installer Repository

```bash
git clone https://github.com/aeroslayys/lemon-niri-installer ~/lemon-niri-installer
cd ~/lemon-niri-installer
```

---

## 4️⃣ Run Installer

```bash
chmod +x install.sh
./install.sh

```

Preview changes safely:

```bash
chmod +x install.sh
./install.sh --dry-run 

```

---

## 🌐 Run Directly via Curl (Optional)

Dry-run mode:

```bash
bash <(curl -sSL https://gist.githubusercontent.com/aeroslayys/48301affed815e0ed09d492c48f3322a/raw) --dry-run
```

Execute installer:

```bash
bash <(curl -sSL https://gist.githubusercontent.com/aeroslayys/48301affed815e0ed09d492c48f3322a/raw)
```

---

# ⚠️ Interactive Auto Installer

✔ Supports:
- Fedora  
- Arch  

✔ Fully interactive  
✔ Safe backups  
✔ `--dry-run` support  
✔ Handles AUR helpers automatically  
✔ Optional wallpaper installation (~1GB)  
✔ Optional Gruvbox theme injection  

---

# 🧠 What the Installer Does

## ✔ Distro Detection

- Detects system using `/etc/os-release`
- Fedora → `dnf`
- Arch → `pacman` + detected AUR helper

---

## ✔ Pre-Flight Checks

### Fedora
- Installs `git`
- Installs `dnf-plugins-core` if missing

### Arch
- Installs `git`
- Installs `base-devel`
- Detects existing AUR helper
- Automatically installs one if none is found

---

## 🏔 Arch Linux & AUR Helpers

The installer is designed to be **AUR-helper agnostic**.

It will prioritize existing helpers such as:

- `yay`
- `paru`
- `aurutils`

If none of these are detected, the installer will automatically install yay to complete the environment setup.

This ensures a smooth experience while respecting existing Arch workflows.

---

## ✔ Special Package Handling

### Niri
- Fedora → Enables COPR `yalter/niri-git`
- Arch → Installs `niri-git` from AUR

### Noctalia
- Fedora → Enables Terra repo automatically
- Arch → Installs using detected AUR helper

### GTK4
- Automatically installs if missing

---

## ✔ Interactive Component Selection

You can choose to install:

- Niri (Window Manager)
- Noctalia (Status Bar)
- Fuzzel (App Launcher)
- Alacritty (Terminal)
- Fastfetch & Chafa
- Zsh
- Wallpaper Bank
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

If running in VirtualBox, the installer recommends:

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
