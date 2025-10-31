# Switch to zsh if running in Toolbx or WSL but not when executing in Silverblue "system" shell
if [[ -f /run/.toolboxenv || $(grep -i "WSL" /proc/sys/kernel/osrelease) ]]; then
  if [[ $(ps --no-header --pid=$PPID --format=comm) != "zsh" && -z ${BASH_EXECUTION_STRING} && ${SHLVL} == 1 ]]; then
    shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=''
    exec zsh $LOGIN_OPTION
  fi
fi
