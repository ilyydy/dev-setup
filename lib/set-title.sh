# set-the-shells-title https://docs.microsoft.com/en-us/windows/terminal/tutorials/tab-title#set-the-shells-title

settitle () {
    export PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
    echo -ne '\033]0;'"$1"'\a'
}

settitle 'Ubuntu 20-1'
