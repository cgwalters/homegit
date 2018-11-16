all:
	echo "Targets: install install-bin install-dotfiles"

install: install-bin install-dotfiles

install-bin:
	./install-bin.sh

install-dotfiles:
	./install-dotfiles.sh

install-config:
	./install-config.sh

