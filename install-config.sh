#!/usr/bin/bash
set -euo pipefail

mkdir -p ~/.config
cp -a --reflink=auto dot-config/* ~/.config/
mkdir -p -m 0600 ~/.ssh
cp -a --reflink=auto dot-ssh/* ~/.ssh/
