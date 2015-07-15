
is_linux () { [[ $('uname') == 'Linux'  ]]; }
is_osx () { [[ $('uname') == 'Darwin' ]]; }

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

joinstr () {
    -joinstr \* "$@"
}

-joinstr () {
    local IFS="$1"
    shift
    echo "$*"
}

# An experimental alternative to `proj` that uses fuzzy filename expansion
fcd () {
    cd "$(joinstr $(echo "$*" | fold -w1))*"
}

fproj () {
    local all_args_as_single_string="${(j. .)${(z)@}}"
    for char in $all_args_as_single_string; do
        print -l $char
    done
}
