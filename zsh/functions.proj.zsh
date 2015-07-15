
proj-find () {
    # Do a breadth-first search of the filesystem to jump to a directory.
    # Default starting location is $HOME, but this can be overridden using the $PROJ_ROOT environment variable.
    local max_depth=10 depth=1 result=""

    local start_dir="$PWD"

    local all_args_as_single_string="${(j. .)${(z)@}}"
    local search_glob="*$(echo "$*")*"
    # local search_glob="*$(joinstr $(echo "$*" | fold -w1))*"

    echo "Searching for: '$search_glob'..."

    # This is a horrible hack that approximates depth-first search by abusing
    # the 'find' command's -{min,max}depth arguments.
    while result=$(find -s $start_dir -not -path '*/\.*' -type d -mindepth $depth -maxdepth $depth -iwholename "$search_glob" -print -quit) && [ -z "$result" ] && [ "$depth" -le "$max_depth" ]; do
        ((depth++))
    done

    if [[ -n "$result" ]]; then
        cd $result
        echo $(pwd)
    else
        echo "No results found"
    fi
}

proj-unused-images () {
    # Can't seem to make proj_files var local. "Not valid in this context."
    # I'm really starting to have zsh. Well, shell scripting in general.
    proj_files=$(find . \( -name '*.xib' -o -name '*.[mh]' \) ! \( -path '*.framework/*' -o -path '*/Pods/*' \))
    
    # Find all png images, strip (@3x.png, @2x.png, .png, etc.) prefix and make sure the results are stored in a proper ZSH array.
    png_files=("${(@f)$(find . -name '*.png' ! \( -path '*.framework/*' -o -path '*/Pods/*' \) | sed 's/@.*//g' | sort -u)}")

    for png in $png_files; do
        name="$(basename $png)"
        if ! grep -qhs "$name" "$proj_files"; then
            echo "$png"
        fi
    done

    unset proj_files
    unset png_files
}

proj-root () {
    cd $(git rev-parse --show-toplevel || echo ".")
}

# Syntactic sugar to avoid the `-` when calling proj commands. With this
# function, you can write `proj-root` as `proj root`.
proj () {
  local cmd="$1"
  if [[ -z "$cmd" ]]; then
    echo "proj: Please give a command to run." >&2
    return 1
  fi
  shift

  if functions "proj-$cmd" > /dev/null; then
    "proj-$cmd" "$@"
  else
    echo "proj: Unknown command: $cmd" >&2
  fi
}

# Several convenience aliases
alias j=proj-find
