#!/bin/sh
# Install the base dotfiles followed by the macos-csb overlay.
set -e
./install-dotfiles.sh
rsync -rlv macos-csb/ ~
# The base tree ships the Linux (V1-era) opencode.json; remove it so it
# cannot conflict with the V2 opencode.jsonc installed by this overlay.
rm -f "$HOME"/.config/opencode/opencode.json
