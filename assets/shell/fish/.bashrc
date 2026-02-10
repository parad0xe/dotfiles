export PATH="$PATH:$HOME/.local/share/junest/bin:$HOME/.junest/usr/bin_wrappers"

if [ -t 1 ] && command -v fish >/dev/null 2>&1; then
    exec fish
fi
