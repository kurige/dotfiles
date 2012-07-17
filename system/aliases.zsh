# Basic directory operations
alias ...='cd ../..'
alias -- -='cd -'

# Super user
alias _='sudo'

# List directory contents
alias lsa='ls -lah'
alias l='ls -la'
alias ll='ls -l'
alias sl=ls # common typo

# Handy 'sha1' alias
alias sha1='openssl dgst -sha1'

# Create bash session with public keys attached to ssh-agent
alias bashagent="ssh-agent sh -c 'ssh-add < /dev/null & bash'"

# Typing 'bundle execute' is a serious PITA
alias be='bundle exec'

# Occasionally necessary to fix XCode silliness
alias ded='rm -rf ~/Library/Developer/Xcode/DerivedData'

