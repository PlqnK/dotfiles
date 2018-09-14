#!/bin/sh

export EDITOR="vim"
export TERM="urxvt"
export BROWSER="firefox"

# Needed for KeePassXC SSH Agent
export $SSH_AUTH_SOCK="${XDG_RUNTIME_DIR}/ssh-agent.socket"

# Start X if i3 isn't running when logging in on the first tty
if [[ "$(tty)" = "/dev/tty1" ]]; then
	pgrep -x i3 || exec startx
fi
