alias g-am='git commit -a --amend --no-edit'
alias g-amr='git commit -a --amend'
alias make='chrt --idle 0 make -j (getconf _NPROCESSORS_ONLN)'
alias mk-autoconf='./autogen.sh --prefix=/usr --libdir=/usr/lib64 --sysconfdir=/etc'

if command -v pazi >/dev/null
    status --is-interactive; and pazi init fish | source
end
