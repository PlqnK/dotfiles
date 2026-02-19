# Switch to zsh if running in Toolbx or WSL but not when executing in Silverblue "system" shell
if [[ -f /run/.toolboxenv || $(grep -i "WSL" /proc/sys/kernel/osrelease) ]]; then
  if grep -qv 'zsh' /proc/$PPID/comm && [[ ${SHLVL} == [1,2] ]] && [[ $- == *i* ]]; then
    shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=''
    exec zsh $LOGIN_OPTION
  fi
fi
