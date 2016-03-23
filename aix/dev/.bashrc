myroot=`id | grep -w root`
if [ $? -eq 0 ]; then
    PS1="\u@\h:\w # "
else
    PS1="\u@\h:\w $ "
fi

alias l="ls -alrt"
alias ll="ls -alrt"

# some more ls aliases
#alias ll='ls -l'
#alias la='ls -A'
#alias l='ls -CF'
#alias l='ls -al'

alias tail='tail -n 3000 '

export PS1

