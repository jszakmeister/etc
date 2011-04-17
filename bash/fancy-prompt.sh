function myprompt {
local BK="\[\O33[0;30m\]" 	# black
local BL="\[\033[0;34m\]" 	# blue
local GR="\[\033[0;32m\]"	# green
local CY="\[\033[0;36m\]" 	# cyan
local RD="\[\033[0;31m\]" 	# red
local PL="\[\033[0;35m\]"  	# purple
local BR="\[\033[0;33m\]"  	# brown
local GY="\[\033[1;30m\]"  	# grey
# enhanced
local eGY="\[\033[0;37m\]" 	# light gray
local eBL="\[\033[1;34m\]" 	# light blue
local eGR="\[\033[1;32m\]" 	# light green
local eCY="\[\033[1;36m\]" 	# light cyan
local eRD="\[\033[1;31m\]" 	# light red
local ePL="\[\033[1;35m\]" 	# light purple
local eYW="\[\033[1;33m\]" 	# yellow
local eWT="\[\033[1;37m\]" 	# white
# reset to teminal default
local NRML="\[\033[0;0m\]"	# normal term color

    # what user am i?
    local me=`whoami`
    # setup user-based colors schemes.
    # play around in here for global settings
    # or create ~/.mprc for local override.
    case $me in
        root) # system god
	    local UCHR="# "		# root prompt character
    	    local UCLR=$eYW		# root prompt color
	    local NCLR=$PL		# username color
	    local ATCLR=$CY		# @ sign color
	    local HCLR=$eBL		# host name color
    	    local BRKT=$eBL		# bracket color
	    local PARN=$CY		# parens color
	    local DCLR=$CY		# dash color
	    local SCLR=$CY		# slash color
	    local TCLR=$eBL		# time color
	    local COCLR=$BL		# colon color
	    local DTCLR=$eBL		# date color
	    local DIR=$eCY		# current directory color
	    local TXT=$NRML		# root text color
	    local CCHR="->"		# line continuation character
	    local CCLR=$GY		# line continuation character color
	;;
	*) # mere mortals
	    local UCHR=":: "		# user prompt character
	    local UCLR=$eBL		# user prompt color
            if [ -n "$SSH_TTY" ]; then
                # username color
                local NCLR="\[\e[1;4;33m\]"
                # host name color
	        local HCLR="\[\e[1;4;34m\]"
                # @ sign color
	        local ATCLR="\[\e[1;4;36m\]"
                # Characters to signify that we're remote
                local SRMT="{"
                local ERMT="}"
            else
                local NCLR=$eYW		# username color
	        local HCLR=$eBL		# host name color
	        local ATCLR=$CY		# @ sign color
                local SRMT=""           # Not remote
                local ERMT=""           # Not remote
            fi

	    local BRKT=$eBL		# bracket color
	    local PARN=$CY		# parens color
	    local DCLR=$CY		# dash color
	    local SCLR=$CY		# slash color
	    local TCLR=$eBL		# time color
	    local COCLR=$eBL		# colon color
	    local DTCLR=$eBL		# date color
	    local DIR=$eRD		# current directory color
	    local TXT=$NRML		# user text color
	    local CCHR="-> "		# line continuation character
	    local CCLR=$GY		# line continuation character color
	;;
    esac

    case $TERM in
        xterm*)
            local TITLEBAR='\[\e]0;\u@\h:\w\a\]'
            ;;
        *)
            local TITLEBAR=''
            ;;
    esac
    export PS1="$TITLEBAR$NRML$SRMT$NCLR\u$ATCLR@$HCLR\H$NRML$ERMT$COCLR:$DIR\$(getPWD)\n$eGR\$(parse_git_branch)$UCLR$UCHR$TXT"
    export PS2="$CCLR$CCHR$TXT"
}

function getPWD
{
    # How many characters of the $PWD should be kept
    # courtesy Giles Orr's bash prompt HOWTO (tweaked to be a function)

    if [[ "$COLUMNS" != "" ]]; then
        local pwd_length=$(($COLUMNS-43))
        if [ $(echo -n $PWD | wc -c | tr -d " ") -gt $pwd_length ]
        then
            newPWD=...$(echo -n $PWD | sed -e "s/.*\(.\{$pwd_length\}\)/\1/")
        else
            newPWD=$(echo -n $PWD)
        fi
    else
            newPWD=$(echo -n $PWD)
    fi
    echo $newPWD
}

case $TERM in
	cons25)
	  COLUMNS=80
	;;
	*)
#	  eval `resize`
	;;
esac

myprompt
