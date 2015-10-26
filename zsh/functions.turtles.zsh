
###
## This is a version that works on Mac OS X, but the columns don't always line
## up since I'm using 'ps' to print one line at a time.
###
turtles () {
  local ppid=$$
  local first=true
  while [[ $ppid -ne 0 ]]; do
    local line=$(ps -p $ppid -o pid=,command= 2>/dev/null)
    if [[ "$first" == true ]]; then
      first=false
      echo " >> $line"
    else
      echo "    $line"
    fi
    ppid=$(ps -p $ppid -o ppid=)
  done

  # Adorable turtle ASCII art by "jgs" and nicked from:
  # http://www.retrojunkie.com/asciiart/animals/turtles.htm
  cat << "EOF"
       _.._    _ 
     ."\__/"./`_\
   _/__<__>__\/
 `"/_/""""\_\\"
EOF
}

###
## I'm upset I can't use this method, but it seems that ps in general insists
## on sorting the list of pids you provide it, even if you don't want to, and
## on macs ps doesn't even support the '--sort' flag so there's no chance of
## fixing it without some kind of awk black magick.
###
# turtles () {
#   echo "-----------------"
#   # Collect list of parent pids as an array
#   local pids=()
#   # Using a zsh int automagically trims problematic whitespace
#   typeset -i ppid=$$
#   while [[ $ppid -ne 0 ]]; do
#     pids+=$ppid
#     ppid=$(ps -p $ppid -o ppid=)
#   done
#   ps -p $pids

#   cat << "EOF"
# -----------------
#        _.._    _ 
#      ."\__/"./`_\
#    _/__<__>__\/
#  `"/_/""""\_\\"
# EOF
# }
