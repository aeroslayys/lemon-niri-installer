# 🍋 Lemon Niri Installer

A citrus-themed Wayland desktop installer built around **Niri** with proportional tiling and bold accent colors.

Minimal. Bright. Functional.

---

# 🎨 Pick Your Flavor

Choose your accent color when the installer launches:

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
bash <(curl -sSL https://gist.githubusercontent.com/aeroslayys/48301affed815e0ed09d492c48f3322a/raw/install.sh) --dry-run
```

Execute installer:

```bash
bash <(curl -sSL https://gist.githubusercontent.com/aeroslayys/48301affed815e0ed09d492c48f3322a/raw/install.sh)
```

---

# ⚠️ Interactive Auto Installer

✔ Supports:
- Fedora
- Arch
- Ubuntu / Debian *(experimental — not fully tested, expect rough edges)*

✔ Fully interactive custom TUI (no external dependencies)
✔ Navigate with `j`/`k` or arrow keys
✔ `SPACE` to toggle components, `ENTER` to confirm, `e` to exit at any time
✔ Safe backups
✔ `--dry-run` support
✔ Optional wallpaper installation (~1GB)

> **Note:** Ubuntu and Debian support is present in the installer but has **not been tested**. Some packages (particularly Noctalia) may require manual compilation on Debian-based systems. Fedora and Arch are the primary supported targets.

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

The installer uses a fully custom terminal UI — no `whiptail` or external TUI libraries required.

You can choose to install:

- Niri (Window Manager)
- Noctalia (Status Bar)
- Bibata Cursor (Modern Ice)
- Tools — Fuzzel, Alacritty, Fastfetch, Chafa
- Zsh + Oh My Zsh
- Wallpaper Bank (~1GB, off by default)
- Symlinks & Theming

**Controls:**

| Key | Action |
|-----|--------|
| `j` / `↓` | Move down |
| `k` / `↑` | Move up |
| `SPACE` | Toggle component (checklist) |
| `ENTER` | Confirm selection |
| `e` | Exit installer immediately |

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

| Category      | Tool              |
|--------------|-------------------|
| Compositor   | Niri              |
| Terminal     | Alacritty         |
| Status Bar   | Noctalia          |
| Launcher     | Fuzzel            |
| System Info  | Fastfetch         |
| ASCII Render | Chafa             |
| Shell        | Zsh               |
| Cursor       | Bibata Modern Ice |

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