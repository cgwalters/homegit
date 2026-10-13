Colin's dotfiles and misc. scripts
----------------------------------

I keep basic config files like `~/.emacs` and `~/.bashrc` in git.
There might be something useful in there for you.  I also have a
collection of miscellaneous scripts in `bin/`, mostly git wrappers.

If you like this repository, you might also find my personal
Ansible https://github.com/cgwalters/ansible-personal repository
useful.

## Agent configuration

This repository also contains [AGENTS.md](AGENTS.md), my default system prompt for agents.

## MacOS

`dotfiles/` targets my Linux machines. MacOS-specific overrides live in
`macos-csb/`; `make install-macos-csb` installs the base dotfiles and
then layers that overlay on top.
