#!/bin/sh

export EDITOR="vim"
export TERMINAL="rxvt-unicode"
export BROWSER="firefox"

# Start X if i3 isn't running when logging in on the first tty
if [[ "$(tty)" = "/dev/tty1" ]]; then
	pgrep -x i3 || exec startx
fi
