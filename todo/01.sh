#! /bin/bash
set -euo pipefail

# Create config directories
mkdir -p ~/.config/niri
mkdir -p ~/.config/fuzzel

# Copy Niri and Fuzzel configs from repo
cp -f sxbox/user/.config/niri/config.kdl ~/.config/niri/config.kdl
cp -f sxbox/user/.config/fuzzel/fuzzel.ini ~/.config/fuzzel/fuzzel.ini

# Optional: set default locale to Russian with UTF-8 (requires root)
echo "[i] To enable Russian system locale, as root do:"
echo "    sed -i 's/^#\s*ru_RU.UTF-8/ru_RU.UTF-8/' /etc/locale.gen && locale-gen"
echo "    echo 'LANG=ru_RU.UTF-8' > /etc/locale.conf"

echo "[i] Done. Start a Niri session from the login manager or run 'niri --session' from a TTY."