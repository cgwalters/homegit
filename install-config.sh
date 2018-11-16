#!/usr/bin/bash
set -euo pipefail

mkdir -p ~/.config
cp -a --reflink=auto dot-config/* ~/.config/
mkdir -p ~/.ssh
cp -a --reflink=auto dot-ssh/* ~/.ssh/
