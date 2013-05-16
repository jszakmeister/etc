# create a zkbd compatible hash;
# to add other keys to this hash, see: man 5 terminfo
typeset -A key

# Home and End seem to be empty on the Mac
key[Home]=${terminfo[khome]}
key[End]=${terminfo[kend]}
key[Insert]=${terminfo[kich1]}
key[Delete]=${terminfo[kdch1]}
key[Up]=${terminfo[kcuu1]}
key[Down]=${terminfo[kcud1]}
key[Left]=${terminfo[kcub1]}
key[SLeft]=${terminfo[kLFT]}
key[CLeft]=${terminfo[kLFT5]}
key[Right]=${terminfo[kcuf1]}
key[SRight]=${terminfo[kRIT]}
key[CRight]=${terminfo[kRIT5]}
key[PageUp]=${terminfo[kpp]}
key[PageDown]=${terminfo[knp]}

for k in ${(k)key} ; do
    # $terminfo[] entries are weird in ncurses application mode...
    [[ ${key[$k]} == $'\eO'* ]] && key[$k]=${key[$k]/O/[}
done
unset k

# default to emacs bindings, just like bash
bindkey -e

# Set up tab completion to use only the prefix.
bindkey "^I" expand-or-complete-prefix

# setup key accordingly
[[ -n "${key[Delete]}"  ]]  && bindkey  "${key[Delete]}"  delete-char
[[ -n "${key[Up]}"      ]]  && bindkey  "${key[Up]}"      history-beginning-search-backward
[[ -n "${key[Down]}"    ]]  && bindkey  "${key[Down]}"    history-beginning-search-forward
[[ -n "${key[Left]}"    ]]  && bindkey  "${key[Left]}"    backward-char
[[ -n "${key[CLeft]}"   ]]  && bindkey  "${key[CLeft]}"   backward-word
[[ -n "${key[Right]}"   ]]  && bindkey  "${key[Right]}"   forward-char
[[ -n "${key[CRight]}"  ]]  && bindkey  "${key[CRight]}"  forward-word
[[ -n "${key[Home]}"    ]]  && bindkey  "${key[Home]}"    beginning-of-line
[[ -n "${key[End]}"     ]]  && bindkey  "${key[End]}"     end-of-line

# Other potential entries for Home/End
bindkey "\eOH" 	beginning-of-line
bindkey "\e[H" 	beginning-of-line
bindkey "\e[1~" beginning-of-line
bindkey "\eOF" 	end-of-line
bindkey "\e[F" 	end-of-line
bindkey "\e[4~" end-of-line

# Other potential entries for Ctrl-Left/Right
bindkey "\e[1;5C" forward-word
bindkey "\e[1;5D" backward-word
bindkey "\e[5C"   forward-word
bindkey "\e[5D"   backward-word
bindkey "\e\e[C"  forward-word
bindkey "\e\e[D"  backward-word

bindkey -s "\C-o\C-o" "^E | less^M"
