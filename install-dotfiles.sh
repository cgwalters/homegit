#!/usr/bin/bash
set -euo pipefail

rsync -rlv dotfiles/ ~
