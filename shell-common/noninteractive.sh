if [ -n "$_etc_noninteractive_sourced" ]
then
    return
fi

_etc_noninteractive_sourced=1

. "$ETC_HOME/shell-common/noninteractive.sh"
# Non-interactive shell setup can go here.
. "$ETC_HOME/shell-common/platform.sh"
. "$ETC_HOME/shell-common/core-functions.sh"
. "$ETC_HOME/shell-common/exports.sh"
. "$ETC_HOME/shell-common/functions.sh"

__etc_source_user_file noninteractive.sh
