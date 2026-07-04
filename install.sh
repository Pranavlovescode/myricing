#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
FONT_DIR="$HOME/.local/share/fonts/JetBrainsMonoNerdFont"
FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"

if ! command -v pacman >/dev/null 2>&1; then
	echo "This installer is intended for Arch Linux systems with pacman." >&2
	exit 1
fi

if [[ $EUID -eq 0 ]]; then
	PACMAN=(pacman)
else
	if ! command -v sudo >/dev/null 2>&1; then
		echo "sudo is required to install system packages." >&2
		exit 1
	fi
	PACMAN=(sudo pacman)
fi

echo "Installing required packages..."
"${PACMAN[@]}" -S --needed --noconfirm \
	i3-wm \
	xorg-server \
	xorg-xinit \
	polybar \
	kitty \
	dmenu \
	dex \
	xss-lock \
	i3lock \
	network-manager-applet \
	libpulse \
	curl \
	unzip

echo "Downloading and installing JetBrains Mono Nerd Font..."
tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

curl -L --fail --silent --show-error "$FONT_URL" -o "$tmp_dir/JetBrainsMono.zip"
mkdir -p "$FONT_DIR"
unzip -o "$tmp_dir/JetBrainsMono.zip" -d "$FONT_DIR" >/dev/null
fc-cache -f "$HOME/.local/share/fonts" >/dev/null

install -d "$CONFIG_HOME/i3" "$CONFIG_HOME/polybar"
install -m 644 "$SCRIPT_DIR/i3/config" "$CONFIG_HOME/i3/config"
install -m 644 "$SCRIPT_DIR/polybar/config.ini" "$CONFIG_HOME/polybar/config.ini"
install -m 755 "$SCRIPT_DIR/polybar/launch.sh" "$CONFIG_HOME/polybar/launch.sh"

echo "Done. Log out and start an i3 session to use the new configuration."
