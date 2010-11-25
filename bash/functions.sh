function cdt
{
    local new_dir=`pwd | sed "s|\(.*/projects/[^/]*\).*|\1|"`
    cd $new_dir
}
