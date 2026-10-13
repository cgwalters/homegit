all:
	echo "Targets: install install-bin install-dotfiles install-macos-csb"

install: install-bin install-dotfiles

install-bin:
	./install-bin.sh

install-dotfiles:
	./install-dotfiles.sh

install-macos-csb:
	./install-macos-csb.sh
