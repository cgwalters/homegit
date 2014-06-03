all:

# We won't nuke people's dotfiles by default
install: install-bin

install-bin:
	mkdir -p $$HOME/bin 2>/dev/null
	for f in bin/*; do \
	  bn=$$(basename $$f); \
	  ln -sf $$(pwd)/bin/$$bn ~/bin; \
	done

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
