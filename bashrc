#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
PS1='[\u@\h \W]\$ '

export PAGER=less
export EDITOR=vim
export BROWSER=firefox
export SSH_ASKPASS=ksshaskpass

exec fish
