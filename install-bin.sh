#!/usr/bin/bash
set -euo pipefail

mkdir -p $HOME/.local/bin
for f in bin/*; do
    if ! test -x ${f}; then continue; fi
    ln -sfr ${f} ~/.local/bin
done
