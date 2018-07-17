all:
	echo "Targets: install install-bin install-dotfiles"

install: install-bin install-dotfiles

install-bin:
	mkdir -p $$HOME/.local/bin
	for f in bin/*; do if test -x ${f}; then ln -sfr $${f} ~/.local/bin; fi; done

install-dotfiles:
	@for f in dotfiles/*; do \
	  bn=$$(basename $$f); target=$$HOME/.$$bn; \
	  if test -f $$target -a '!' -L $$target; then \
	    echo "error: $$target exists; remove it to opt-in to installation, then"; \
	    echo "  rerun make install-dotfiles"; \
	  else \
	    echo "Installing $$target"; \
	    ln -sf $$(pwd)/dotfiles/$$bn $$target; \
	  fi; \
	done

install-config:
	mkdir -p ~/.config
	cp -a --reflink=auto dot-config/* ~/.config/
	mkdir -p ~/.ssh
	cp -a --reflink=auto dot-ssh/* ~/.ssh/

