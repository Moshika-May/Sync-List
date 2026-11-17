#!/bin/sh
# Install syncls and every app it needs on pacman / apt / dnf systems. Run from the repo checkout.
set -eu
cd "$(dirname "$0")"

if command -v pacman >/dev/null; then pm=pacman
elif command -v apt-get >/dev/null; then pm=apt
elif command -v dnf >/dev/null; then pm=dnf
else echo "Unsupported distro: install rsync fzf ssh diff awk tailscale yourself." >&2; exit 1; fi

# command -> package name for this distro
pkg() {
  case "$pm:$1" in
    pacman:ssh) echo openssh ;;
    apt:ssh) echo openssh-client ;;
    dnf:ssh) echo openssh-clients ;;
    pacman:diff|apt:diff|dnf:diff) echo diffutils ;;
    pacman:awk|apt:awk|dnf:awk) echo gawk ;;
    apt:notify-send) echo libnotify-bin ;;
    pacman:notify-send|dnf:notify-send) echo libnotify ;;
    *) echo "$1" ;;
  esac
}

need=""
for c in rsync fzf ssh diff awk notify-send; do
  command -v "$c" >/dev/null || need="$need $(pkg "$c")"
done
if [ -n "$need" ]; then
  echo "Installing:$need"
  case $pm in
    pacman) sudo pacman -S --needed $need ;;
    apt) sudo apt-get update && sudo apt-get install -y $need ;;
    dnf) sudo dnf install -y $need ;;
  esac
fi

if ! command -v tailscale >/dev/null; then
  if [ "$pm" = pacman ]; then
    sudo pacman -S --needed tailscale
  else
    # Debian/Ubuntu/Fedora have no tailscale in the default repos; use the official installer.
    printf 'tailscale is missing. Run the official installer (curl -fsSL https://tailscale.com/install.sh | sh)? [y/N] '
    read -r a
    case $a in y|Y) curl -fsSL https://tailscale.com/install.sh | sh ;; *) echo "Skipped. Install tailscale before using syncls." >&2 ;; esac
  fi
  echo "Remember to run: sudo systemctl enable --now tailscaled && sudo tailscale up"
fi

bin=$HOME/.local/bin
units=$HOME/.config/systemd/user
mkdir -p "$bin" "$units"
install -m755 syncls "$bin/syncls"
sed "s|@BIN@|$bin/syncls|" systemd/syncls.service >"$units/syncls.service"
cp systemd/syncls.timer "$units/"
systemctl --user daemon-reload && systemctl --user enable --now syncls.timer \
  || echo "No systemd user session. Use cron instead: 0 * * * * $bin/syncls --auto"
echo "Installed. Make sure $bin is in PATH, then run: syncls doctor"
