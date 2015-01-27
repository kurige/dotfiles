
abspath () {
    if [[ -d "$1" ]]
    then
        pushd "$1" >/dev/null
        pwd
        popd >/dev/null
    elif [[ -e $1 ]]
    then
        pushd "$(dirname "$1")" >/dev/null
        echo "$(pwd)/$(basename "$1")"
        popd >/dev/null
    else
        echo "$1" does not exist! >&2
        return 127
    fi
}

is_linux () { [[ $('uname') == 'Linux'  ]]; }
is_osx   () { [[ $('uname') == 'Darwin' ]]; }

proj () {
    # Do a breadth-first search of the filesystem to jump to a directory.
    # Default starting location is $HOME, but this can be overridden using the $PROJ_ROOT environment variable.
    local max_depth=10 depth=0 result=""

    local start_dir="$PROJ_ROOT"
    [ -z "$start_dir" ] && start_dir="$HOME"

    # This is a horrible hack that approximates depth-first search by abusing
    # the 'find' command's -{min,max}depth arguments.
    while result=$(find -s $start_dir -type d -mindepth $depth -maxdepth $depth -iname "*$1*" -print -quit) && [ -z "$result" ] && [ "$depth" -le "$max_depth" ]; do
        ((depth++))
    done

    if [ -n "$result" ]; then
        cd $result
        echo $(pwd)
    else
        echo "No results found"
    fi
}