
local _JAVA_HOME_BIN="/usr/libexec/java_home"

-jdk-has-java-home () {
  if [[ ! -x "$_JAVA_HOME_BIN" ]]; then
    echo "Jdk: Could not find java_home executable: $_JAVA_HOME_BIN" >&2
    return 1
  else
    return 0
  fi
}

jdk-ls () {
  if -jdk-has-java-home; then
    "$_JAVA_HOME_BIN" -V 2>&1 | grep -E "\d\.\d\.\d(_\d+)?.*," | cut -d , -f 1 | cut -c 5-
  fi
}

jdk-set () {
  if -jdk-has-java-home; then
    if [[ -z $1 ]]; then
      export JAVA_HOME=$("$_JAVA_HOME_BIN")
    else
      export JAVA_HOME=$("$_JAVA_HOME_BIN" -v "$1")
    fi
  fi
}

jdk-init () {
  jdk-set
}

# Syntactic sugar to avoid the `-` when calling jdk commands. With this
# function, you can write `jdk-ls` as `jdk ls`.
jdk () {
  local cmd="$1"
  if [[ -z "$cmd" ]]; then
    echo "Jdk: Please give a command to run." >&2
    return 1
  fi
  shift

  if functions "jdk-$cmd" > /dev/null; then
    "jdk-$cmd" "$@"
  else
    echo "Jdk: Unknown command: $cmd" >&2
  fi
}