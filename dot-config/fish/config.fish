alias g-am='git commit -a --amend --no-edit'
alias g-amr='git commit -a --amend'
alias make='chrt --idle 0 make -j (getconf _NPROCESSORS_ONLN)'
# This is better than `sudo make install` in that
# just like most package managers, it avoids running
# the Makefile as root, which can cause problems with
# things being *built* as root.
alias makesudoinstall='make; and rm -rf _install; and make install DESTDIR=(pwd)/_install; and sudo rsync -rlv _install/ /; and rm -rf _install'
alias mk-autoconf='./autogen.sh --prefix=/usr --libdir=/usr/lib64 --sysconfdir=/etc'

if command -v pazi >/dev/null
    status --is-interactive; and pazi init fish | source
end
