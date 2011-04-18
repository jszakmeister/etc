# Point at the location of your bash completion file
if [ -f $HOME/.local/etc/git-completion.bash ]; then
   . $HOME/.local/etc/git-completion.bash
elif [ -f $HOME/.local/etc/completions/git-completion.bash ]; then
   . $HOME/.local/etc/completions/git-completion.bash
fi
