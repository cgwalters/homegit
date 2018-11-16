#!/usr/bin/bash
set -euo pipefail

for f in dotfiles/*; do \
	  bn=$(basename $f)
    target=$HOME/.$bn
	  if test -f $target -a '!' -L $target; then
	      echo "error: $target exists; remove it to opt-in to installation, then"
	      echo "  rerun make install-dotfiles"
	  else
	      echo "Installing $target"
	      ln -sf $(pwd)/dotfiles/$bn $target
	  fi;
done
