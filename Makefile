all:

install:
	mkdir -p $$HOME/bin 2>/dev/null
	for f in bin/*; do \
	  bn=$$(basename $$f); \
	  ln -sf $$(pwd)/bin/$$bn ~/bin; \
	done
	for f in dotfiles/*; do \
	  bn=$$(basename $$f); \
	  ln -sf $$(pwd)/dotfiles/$$bn ~/.$$bn; \
	done
