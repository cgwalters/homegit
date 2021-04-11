alias g-am='git commit -a --amend --no-edit'
alias g-amr='git commit -a --amend'
alias make='chrt --idle 0 make -j (getconf _NPROCESSORS_ONLN)'
alias fedpkg='chrt --idle 0 fedpkg'
alias rhpkg='chrt --idle 0 rhpkg'
alias mk-autoconf='./autogen.sh --prefix=/usr --libdir=/usr/lib64 --sysconfdir=/etc'
alias c='cp --reflink=auto'
alias devshell='sudo runuser -u root -- podman run --net=host --rm -ti --privileged -v {$XDG_RUNTIME_DIR}/keyring:{$XDG_RUNTIME_DIR}/keyring -v /srv:/srv:rslave -v /run/libvirt:/run/libvirt:rslave -v /var/tmp:/var/tmp:rslave -v /srv/walters/containers/home:/home/walters -v /srv/walters/containers/roothome:/var/roothome'

set PATH $PATH /usr/sbin
for d in $HOME/.local/bin
    if test -d $d
        set PATH $d $PATH
    end
end

if command -v pazi >/dev/null
    status --is-interactive; and pazi init fish | source
end

# For some reason in https://github.com/cgwalters/coretoolbox
# umask is ending up as 077 which causes issues particularly
# when using "sudo" as then root-owned files can't be read
# by the user.
umask 022

if test -d /srv/walters/src
    set GOPATH (realpath /srv/walters)
    export GOPATH
end
