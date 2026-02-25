# 🍋 Lemon Niri Dotfiles

![Preview of my Lemon Niri Setup](preview.png)

A citrus-themed Wayland desktop built around **Niri** with proportional tiling and bold yellow accents.

Minimal. Bright. Functional.

---

## 📸 Preview

> [!TIP]
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

## 📦 Manual Install Steps

### 1️⃣ Install Core Dependencies

Install the following packages using your distro’s package manager:

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

### 2️⃣ Install Noctalia (Status Bar)

Noctalia must be built from source.

Clone and build:

```bash
git clone https://github.com/pwn-pht/noctalia
cd noctalia
cargo build --release
sudo cp target/release/noctalia /usr/local/bin/
```

#### Fedora Build Dependencies

```bash
sudo dnf install rust cargo gtk4-devel
```

Arch users should install equivalent Rust + GTK4 packages.

---

### 3️⃣ Clone Dotfiles

```bash
git clone https://github.com/aeroslayys/niri-dotfiles ~/niri-dotfiles
```

---

### 4️⃣ Backup Existing Configs

```bash
mkdir -p ~/dotfiles_backup
mv ~/.config/niri ~/dotfiles_backup/
mv ~/.config/alacritty ~/dotfiles_backup/
```

---

### 5️⃣ Symlink Configurations

```bash
mkdir -p ~/.config
ln -sf ~/niri-dotfiles/niri ~/.config/
ln -sf ~/niri-dotfiles/alacritty ~/.config/
```

---

### 6️⃣ Zsh Lemon Config

```bash
cat ~/niri-dotfiles/zshrc >> ~/.zshrc
```

Ensure `lemon.png` is located in:

```
~/Downloads
```

---

# ⚠️ Auto Installer (Use at Your Own Risk)

An interactive installer script is included.

⚠️ Only supports:
- Fedora
- Arch

⚠️ Review the script before running.  
⚠️ Manual installation is preferred.

---

## Dry Run

```bash
bash <(curl -sSL https://raw.githubusercontent.com/aeroslayys/niri-dotfiles/main/install.sh) --dry-run
```

---

## Execute Installer

```bash
bash <(curl -sSL https://raw.githubusercontent.com/aeroslayys/niri-dotfiles/main/install.sh)
```

---

## 🧠 What the Auto Installer Does

### ✔ Distro Detection
Uses `/etc/os-release` and selects:

- Fedora → `dnf`
- Arch → `pacman`

Exits if unsupported.

---

### ✔ Interactive Component Selection

You can choose:

- Niri
- Alacritty
- Fastfetch & Chafa
- Noctalia (build required)

---

### ✔ Noctalia Build (If Selected)

- Installs build dependencies (Fedora: `rust`, `cargo`, `gtk4-devel`)
- Clones Noctalia into `/tmp`
- Builds with `cargo build --release`
- Installs binary to `/usr/local/bin`
- Cleans up build directory
- Fully supports `--dry-run`

---

### ✔ Safe Symlinking

- Links only:
  - `niri`
  - `alacritty`
- Existing directories are backed up to:

```
~/dotfiles_backup_YYYYMMDD_HHMMSS
```

---

### ✔ Zsh Handling

- Appends lemon config to existing `.zshrc`
- Does **not** overwrite
- Supports dry-run preview

---

## 🛠️ Components

| Category      | Tool        |
|--------------|------------|
| Compositor   | Niri       |
| Terminal     | Alacritty  |
| Status Bar   | Noctalia   |
| System Info  | Fastfetch  |
| ASCII Render | Chafa      |

---

## ⚙️ Key Specs

- **Window Ratio:** 0.5 default column width  
- **Theme:** High-contrast yellow accents  
- **Layout:** Proportional tiling  
- **Bar:** Noctalia (Rust + GTK4)  

---

## 🍋 Philosophy

A high-contrast, proportional Wayland workflow with citrus identity.

Designed for clarity, speed, and simplicity.

---

Enjoy your Lemon Niri setup 🍋
