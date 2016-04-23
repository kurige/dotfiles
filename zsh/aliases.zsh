# Modeline {
#    vi: foldmarker={,} foldmethod=marker foldlevel=0 tabstop=4 filetype=sh
# }

alias timestamp='date +%s'

# XCode {
    alias xcdd='rm -rf ~/Library/Developer/Xcode/DerivedData/*'

    simctl-clearall () {
      osascript -e 'tell application "iOS Simulator" to quit'
      xcrun simctl list devices | grep -v '^[-=]' | cut -d "(" -f2 | cut -d ")" -f1 | xargs -I {} xcrun simctl erase "{}"
    }
# }

# 'pbcopy' without the trailing newline character
# Note: This requires the homebrew package 'coreutils' to be installed. The
# version of 'head' that comes with OSX does not allow for negative byte counts.
alias copy='ghead -c -1 | pbcopy'
