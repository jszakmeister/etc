# default to emacs bindings, just like bash
bindkey -e

# Set up tab completion to use only the prefix.
bindkey "^I" expand-or-complete-prefix

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

function _bindkey()
{
    [[ -z "$1" ]] &&
        return

    local app_key="$1"
    local num_key="${app_key/O/[}"

    bindkey "$app_key" "$2"
    bindkey "$num_key" "$2"
}

_bindkey  "${key[Delete]}"  delete-char
_bindkey  "${key[Up]}"      history-beginning-search-backward
_bindkey  "${key[Down]}"    history-beginning-search-forward
_bindkey  "${key[Left]}"    backward-char
_bindkey  "${key[CLeft]}"   backward-word
_bindkey  "${key[Right]}"   forward-char
_bindkey  "${key[CRight]}"  forward-word
_bindkey  "${key[Home]}"    beginning-of-line
_bindkey  "${key[End]}"     end-of-line

# Allow glob patterns to be used in the incremental search.
bindkey "^R" history-incremental-pattern-search-backward
bindkey "^S" history-incremental-pattern-search-forward

# Other potential entries for Home/End
bindkey "\eOH"  beginning-of-line
bindkey "\e[H"  beginning-of-line
bindkey "\e[1~" beginning-of-line
bindkey "\eOF"  end-of-line
bindkey "\e[F"  end-of-line
bindkey "\e[4~" end-of-line

# Other potential entries for Ctrl-Left/Right
bindkey "\e[1;5C" forward-word
bindkey "\e[1;5D" backward-word
bindkey "\e[5C"   forward-word
bindkey "\e[5D"   backward-word
bindkey "\e\e[C"  forward-word
bindkey "\e\e[D"  backward-word

# Allow `Ctrl-x Ctrl-e` to be used to open the current command line
# in an editor (just like Bash).
autoload edit-command-line
zle -N edit-command-line
bindkey '^X^E' edit-command-line

bindkey -s "\C-o\C-o" "^E | less^M"

if _has_executable sk
then
    __etc_sk_widget()
    {
        LBUFFER="${LBUFFER}$( (${SKIM_DEFAULT_COMMAND:-fd --unrestricted || find .}) | sk ) "
        local ret=$?
        zle reset-prompt
        return $ret
    }
    zle -N __etc_sk_widget
    bindkey "^P^P" __etc_sk_widget
fi

# Allow Alt-m to be used to grab a previous argument.  For instance,
# $ git status
# Alt-. Alt-m would result in 'git'
autoload -Uz copy-earlier-word
zle -N copy-earlier-word
bindkey "^[m" copy-earlier-word

if echoti smkx > /dev/null 2>&1
then
    function zle-line-init()
    {
        echoti smkx
    }

    function zle-line-finish()
    {
        echoti rmkx
    }

    zle -N zle-line-init
    zle -N zle-line-finish
fi
