#
# ~/.bash_profile
#

export PAGER=less
export EDITOR="$(if [[ -n $DISPLAY ]]; then echo 'kate'; else echo 'vim'; fi)"
export BROWSER=firefox
export SSH_ASKPASS=ksshaskpass

[[ -f ~/.bashrc ]] && . ~/.bashrc
