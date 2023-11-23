#!/usr/bin/env bash

if [[ $(hostname) == "toolbox" ]]; then
	if [[ $(ps --no-header --pid=$PPID --format=comm) != "zsh" && -z ${BASH_EXECUTION_STRING} ]]; then
		shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=''
		exec zsh $LOGIN_OPTION
	fi
fi
