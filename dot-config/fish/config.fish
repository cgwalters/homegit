alias g-am='git commit -a --amend --no-edit'
alias g-amr='git commit -a --amend'
alias make='chrt --idle 0 make -j (getconf _NPROCESSORS_ONLN)'
# This is better than `sudo make install` in that
# just like most package managers, it avoids running
# the Makefile as root, which can cause problems with
# things being *built* as root.
alias makesudoinstall='make; and rm -rf _install; and make install DESTDIR=(pwd)/_install; and sudo rsync -rlv _install/ /; and rm -rf _install'
alias mk-autoconf='./autogen.sh --prefix=/usr --libdir=/usr/lib64 --sysconfdir=/etc'
alias c='cp --reflink=auto'
alias devshell='sudo runuser -u root -- podman run --net=host --rm -ti --privileged -v {$XDG_RUNTIME_DIR}/keyring:{$XDG_RUNTIME_DIR}/keyring -v /srv:/srv:rslave -v /run/libvirt:/run/libvirt:rslave -v /var/tmp:/var/tmp:rslave -v /srv/walters/containers/home:/home/walters -v /srv/walters/containers/roothome:/var/roothome'

if command -v pazi >/dev/null
    status --is-interactive; and pazi init fish | source
end

if test -d /srv/walters/src
    set GOPATH (realpath /srv/walters)
end
