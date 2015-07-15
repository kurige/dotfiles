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
