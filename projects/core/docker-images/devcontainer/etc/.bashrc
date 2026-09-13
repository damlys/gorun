#!/bin/bash

PS1='\[\033[0;32m\]$\[\033[00m\] '

if [ -f /etc/bash_completion ]; then
  . /etc/bash_completion
fi

complete -C /usr/local/bin/terraform terraform
complete -C /usr/local/go/bin/gocomplete go

alias kubens="kubectl config set-context --current --namespace"
alias python="python3"
