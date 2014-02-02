
export JAVA_HOME="$(/usr/libexec/java_home)"
export EC2_PRIVATE_KEY="$(/bin/ls $HOME/.ec2/pk-*.pem)"
export EC2_CERT="$(/bin/ls $HOME/.ec2/cert-*.pem)"
export EC2_HOME="/usr/local/Cellar/ec2-api-tools/1.5.2.5/jars"

export PATH="./node_modules/.bin:./bin:/usr/local/bin:/usr/local/sbin:$ZSH/bin:$PATH"
export MANPATH="/usr/local/man:/usr/local/mysql/man:/usr/local/git/man:$MANPATH"

# 'Go' setup
export GOROOT=`brew --prefix go`/libexec
export GOPATH=~/src/gocode
export PATH=$PATH:$GOPATH/bin

# Add local project NPM binaries and globally installed NPM binaries to the path
export PATH=./node_modules/.bin:`npm -g bin`:$PATH

# Initialize RVM
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"

